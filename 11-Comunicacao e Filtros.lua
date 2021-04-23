local Recovery, BOOTYBAY    = ...
local Bootybay              = BOOTYBAY.events

BOOTYBAY.Sincronizados      = {}
BOOTYBAY.FiltroOffline      = {}

local PlayerEnviandoItens   = nil
local PlayerEnviandoGB      = nil
local TempoUltimoUpdate     = 0
local ControleGV            = 0
local DataGV                = 0
local blacklist_add         = 0
local blacklist_remove      = 0

local ItensRecebidos        = {}
local TempGuildBank         = {}

local tostring, strjoin     = _G.tostring, _G.strjoin
local tonumber, strsplit    = _G.tonumber, _G.strsplit
local table                 = table


-- COMUNICAÇÃO INTERNA DO ADDON

function BOOTYBAY:Sincronizar(canal, target)
    local sendMessage
    local cd = false

    -- Tempo de cooldown para re-enviar a tabela de Score e GUID no gchat e via whisper
    if canal == "GUILD" then
        -- Avisa a guild que logamos!
        ChatThrottleLib:SendAddonMessage("ALERT","GRASYNC", tostring(BOOTYBAY.VERSION), canal)
        
        if (time() - BOOTYBAY.dbControle.TempoUltimoSyncScore) < 1200 then
            cd = true 
        else
            BOOTYBAY.dbControle.TempoUltimoSyncScore = time()
        end
    elseif canal == "WHISPER" then
        if BOOTYBAY.Sincronizados[target] then
            if (time() - BOOTYBAY.Sincronizados[target]) < 600 then
                cd = true
            else 
                BOOTYBAY.Sincronizados[target] = time()
                BOOTYBAY.FiltroOffline[target] = time()
            end
        else
            BOOTYBAY.Sincronizados[target] = time()
            BOOTYBAY.FiltroOffline[target] = time()
        end
    end
    

    -- Score e GUID
    if not cd then  
        local keys = {}
        local count = 0
        
        -- Remove scores invalidos e envia os 150 scores mais atuais (via whisper) ou os 500 mais atuais se for via guild
        for k, v in pairs(BOOTYBAY.dbData.Score) do
            if v == nil or v["data"] == nil or v["vitoriasBG"] == nil or v["totalBG"] == nil or (v["vitoriasBG"] > v["totalBG"]) then
                BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbData.Score, k)
            elseif BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, k) then
                if v["totalBG"] == 0 then
                    BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbData.Score, k)
                end
            else
                table.insert(keys, k)
            end
        end
        
        table.sort(keys, function(a, b) return (BOOTYBAY.dbData.Score[a]["data"]  > BOOTYBAY.dbData.Score[b]["data"]) end)
            
        for _, k in ipairs(keys) do 
            if (canal == "WHISPER" and count == 150) or count == 500 then break end
            count = count + 1
            sendMessage = strjoin(";", k, tostring(BOOTYBAY.dbData.Score[k]["totalKill"]), tostring(BOOTYBAY.dbData.Score[k]["totalBG"]), tostring(BOOTYBAY.dbData.Score[k]["vitoriasBG"]), tostring(BOOTYBAY.dbData.Score[k]["data"]))
            ChatThrottleLib:SendAddonMessage("BULK","GRASCORE", sendMessage, canal, target)
        end
        
        -- Envia os GUIDS
        if canal == "WHISPER" then
        -- Envia todos os GUIDS que tem historico de rename e mais 550 GUIDS pegos aleatoriamente na database
            local keysguid = {}
            for k,v in pairs(BOOTYBAY.dbData.Guid) do
                if #v > 1 then
                    sendMessage = k
                    for i = 1, #BOOTYBAY.dbData.Guid[k] do
                        sendMessage = sendMessage..";"..BOOTYBAY.dbData.Guid[k][i]
                    end
                    ChatThrottleLib:SendAddonMessage("BULK","GRAGUID", sendMessage, canal, target)
                else
                    table.insert(keysguid, k)
                end
            end
            
            local guid
            count = 0
            while count < 550 and #keysguid > 0 do
                count = count + 1
                guid = table.remove(keysguid, math.random(1,#keysguid))
                sendMessage = guid..";"..BOOTYBAY.dbData.Guid[guid][1]
                ChatThrottleLib:SendAddonMessage("BULK","GRAGUID", sendMessage, canal, target)
            end
        
        elseif canal == "GUILD" then
        -- Envia todos os GUID da database
            for k,v in pairs(BOOTYBAY.dbData.Guid) do
                sendMessage = k
                for i = 1, #BOOTYBAY.dbData.Guid[k] do
                    sendMessage = sendMessage..";"..BOOTYBAY.dbData.Guid[k][i]
                end
                ChatThrottleLib:SendAddonMessage("BULK","GRAGUID", sendMessage, canal, target)
            end
        end
    end
    
    -- Envio do nosso GUID
    ChatThrottleLib:SendAddonMessage("BULK","GRAGUID", ""..BOOTYBAY.PLAYER_GUID..";"..BOOTYBAY.NOME_PLAYER.."", canal, target)
    
    -- Envio do nosso Score pessoal
    sendMessage = strjoin(";", BOOTYBAY.NOME_PLAYER,tostring(tonumber(GetStatistic(588)) or 0), tostring(tonumber(GetStatistic(839)) or 0), tostring(tonumber(GetStatistic(840)) or 0), tostring(time()))
    ChatThrottleLib:SendAddonMessage("BULK","GRASCORE", sendMessage, canal, target)

    -- Envio do controle dos itens de interesse da guild, e dos itens do GV
    ChatThrottleLib:SendAddonMessage("ALERT", "BBSCIR", tostring(BOOTYBAY.dbControle.Itens), "GUILD")
    ChatThrottleLib:SendAddonMessage("ALERT", "BBSCGB", ""..tostring(BOOTYBAY.dbControle.GuildBank)..";"..BOOTYBAY.dbControle.GuildBankData.."", "GUILD")

    -- Envio dos dados contidos no Ranking da guild
    -- nome, killstreakmax, blacklistkills, winstreaksolomax, recordekillsdia, winstreakGrupo, killbg, dmg, heal
    for k, v in pairs(BOOTYBAY.dbChar.MembrosData) do
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, k) then
            sendMessage = strjoin(";",k, tostring(BOOTYBAY.dbChar.MembrosData[k]["killstreak"]), tostring(BOOTYBAY.dbChar.MembrosData[k]["blacklistkills"]), tostring(BOOTYBAY.dbChar.MembrosData[k]["winstreakSolo"]), tostring(BOOTYBAY.dbChar.MembrosData[k]["killsdia"]), tostring(BOOTYBAY.dbChar.MembrosData[k]["winstreakGrupo"]), tostring(BOOTYBAY.dbChar.MembrosData[k]["killbg"]), tostring(BOOTYBAY.dbChar.MembrosData[k]["dmg"]), tostring(BOOTYBAY.dbChar.MembrosData[k]["heal"]))
            ChatThrottleLib:SendAddonMessage("BULK","GRARANKING", sendMessage, canal, target)
        else 
            BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbChar.MembrosData, k) 
        end
    end

    -- Envio da Blacklist da guild
    for k, v in pairs(BOOTYBAY.dbChar.Blacklist) do
        sendMessage = strjoin(";",k,tostring(v))
        ChatThrottleLib:SendAddonMessage("BULK","BBSCB", sendMessage, canal, target)
    end

    -- Envio dos players que devem sair da Blacklist
    for k, v in pairs(BOOTYBAY.dbChar.BlacklistExcluidos) do
        sendMessage = strjoin(";",k,tostring(v))
        ChatThrottleLib:SendAddonMessage("BULK","BBSCE", sendMessage, canal, target)
    end

    -- Envio do controle de officers
    ChatThrottleLib:SendAddonMessage("ALERT", "BBSCCN", "Officer;"..tostring(BOOTYBAY.dbChar.Officer)..";"..tostring(BOOTYBAY.dbControle.Officer).."", "GUILD")

    -- Se a tabela de itens de interesse está vazia e o controle não, zera o controle para receber as informações completas
    if getn(BOOTYBAY.dbChar["Itens"]) == 0 and BOOTYBAY.dbControle.Itens ~= 0 then
        BOOTYBAY.dbControle.Itens = 0
    end
end

function Bootybay:FRIENDLIST_UPDATE(...)
    if time() - TempoUltimoUpdate > 0.5 then
        TempoUltimoUpdate = time()
        for i=1, GetNumFriends() do
            if select(5,GetFriendInfo(i)) == 1 then
                -- Aviso os amigos da friendlist que estamos on!
                ChatThrottleLib:SendAddonMessage("ALERT","GRASYNC", tostring(BOOTYBAY.VERSION), "WHISPER", tostring(select(1,GetFriendInfo(i))))
            end
        end
    end
end

function Bootybay:RAID_ROSTER_UPDATE(...)
    ChatThrottleLib:SendAddonMessage("ALERT","GRASYNC", tostring(BOOTYBAY.VERSION), "RAID")
end

function Bootybay:PARTY_MEMBERS_CHANGED(...)
    ChatThrottleLib:SendAddonMessage("ALERT","GRASYNC", tostring(BOOTYBAY.VERSION), "PARTY")
end

-- Recebimento de informações de outros usuarios
function Bootybay:CHAT_MSG_ADDON(...)
    -- Informações diversas
    if arg1 == "BBSCI" then
    local tipo, value = strsplit(";", arg2)
        if tipo == "Queue" then
            BOOTYBAY:AcessarInfoQueue(arg4)
        elseif tipo == "heal" then
            if not tContains(BOOTYBAY.Healers, value) then
                tinsert(BOOTYBAY.Healers, value)
            end
        end
    
    -- Recebimento do controle do GV
    elseif arg1 == "BBSCGB" and arg4 ~= BOOTYBAY.NOME_PLAYER and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) then
        if arg4 == PlayerEnviandoGB then return end
        local ctrl, hr = strsplit(";", arg2)
        if tonumber(ctrl) > BOOTYBAY.dbControle.GuildBank then
            TempGuildBank = table.wipe(TempGuildBank)
            ControleGV = tonumber(ctrl)
            DataGV = hr
            PlayerEnviandoGB = arg4
            ChatThrottleLib:SendAddonMessage("ALERT", "BBSCGBK", "ok", "WHISPER", arg4)
        end
    
    -- Alguém solicitou, então enviamos os itens do GV
    elseif arg1 == "BBSCGBK" and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) then
        BOOTYBAY.FiltroOffline[arg4] = time()
        for k, v in pairs(BOOTYBAY.dbChar.GuildBank) do
            ChatThrottleLib:SendAddonMessage("ALERT", "BBSCGBR", ""..k..";"..v.."", "WHISPER", arg4)
        end
        ChatThrottleLib:SendAddonMessage("ALERT", "BBSCGBR", "end", "WHISPER", arg4)
    
    -- Recebemos, após solicitar, a tabela atualizada dos itens da guild
    elseif arg1 == "BBSCGBR" and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) then 
        if arg4 == PlayerEnviandoGB then
            if arg2 == "end" then
                BOOTYBAY.dbChar.GuildBank = table.wipe(BOOTYBAY.dbChar.GuildBank)
                for k,v in pairs(TempGuildBank) do
                        BOOTYBAY.dbChar.GuildBank[k] = v
                end
                PlayerEnviandoGB = nil
                BOOTYBAY.dbControle.GuildBank = ControleGV
                BOOTYBAY.dbControle.GuildBankData = DataGV
            else
                local k,v = strsplit(";", arg2)
                TempGuildBank[k] = v
            end
        end
    
    -- Recebimento do controle da tabela de itens de interesse da guild
    elseif arg1 == "BBSCIR" and arg4 ~= BOOTYBAY.NOME_PLAYER and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) and BOOTYBAY.PLAYER_RANK_GUILD ~= 0 then
        if arg4 == PlayerEnviandoItens then return end
        if (BOOTYBAY.GuildMembers[arg4] == 0) or (tonumber(arg2) > BOOTYBAY.dbControle.Itens) then
            ItensRecebidos = table.wipe(ItensRecebidos)
            tinsert(ItensRecebidos, tonumber(arg2))
            PlayerEnviandoItens = arg4
            ChatThrottleLib:SendAddonMessage("ALERT", "BBSCIS", "ok", "WHISPER", arg4)
        end
    
    -- Alugém solicitou, então enviamos a tabela de itens de interesse
    elseif arg1 == "BBSCIS" and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) then
        BOOTYBAY.FiltroOffline[arg4] = time()
        for _, v in pairs(BOOTYBAY.dbChar.Itens) do
            ChatThrottleLib:SendAddonMessage("ALERT", "BBSCII", ""..v.."", "WHISPER", arg4)
        end
        ChatThrottleLib:SendAddonMessage("ALERT", "BBSCII", "end", "WHISPER", arg4)
    
    -- Recebemos, após solicitar, a tabela atualizada de itens de interesse da guild
    elseif arg1 == "BBSCII" and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) then
        if arg4 == PlayerEnviandoItens then
            if arg2 == "end" then
                BOOTYBAY.dbChar.Itens = table.wipe(BOOTYBAY.dbChar.Itens)
                for k,v in pairs(ItensRecebidos) do
                    if k == 1 then
                        BOOTYBAY.dbControle.Itens = v
                    else 
                        tinsert(BOOTYBAY.dbChar.Itens, v)
                    end
                end
            else
                tinsert(ItensRecebidos, arg2)
            end
        end
    
    -- Queue/Info
    elseif arg1 == "GRAQ" then
        if not tContains(BOOTYBAY.Usuarios, arg4) then tinsert(BOOTYBAY.Usuarios, arg4) end
        DEFAULT_CHAT_FRAME:AddMessage("Bootybay: "..arg2.."",0,1,0);
    
    -- Prefixo muito antigo do addon, mantemos para visualizar mensagens vindas de players com as primeiras versões
    elseif arg1 == "GRAKILL" then
        if not tContains(BOOTYBAY.Usuarios, arg4) then tinsert(BOOTYBAY.Usuarios, arg4) end
        DEFAULT_CHAT_FRAME:AddMessage("Bootybay: "..arg2.."",0,1,0);
    
    -- Killstreak
    elseif arg1 == "BBSCKS" and arg3 == "GUILD" then
        if BOOTYBAY.dbConfig.MostrarKill then
            DEFAULT_CHAT_FRAME:AddMessage("Bootybay: "..arg2.."",0,1,0);
        end
        
    -- Mortes
    elseif arg1 == "BBSCM" and arg3 == "GUILD" then
        if BOOTYBAY.dbConfig.MostrarMortes then
            DEFAULT_CHAT_FRAME:AddMessage("Bootybay: "..arg2.."",0,1,0);
        end
        
    -- Resultado de BGs
    elseif arg1 == "BBSCBG" and arg3 == "GUILD" then
        if BOOTYBAY.dbConfig.MostrarResultadoBGs then
            DEFAULT_CHAT_FRAME:AddMessage("Bootybay: "..arg2.."",0,1,0);
        end
        
    -- Kills da Blacklist da guild
    elseif arg1 == "BBSCBK" and arg3 == "GUILD" then
        if BOOTYBAY.dbConfig.MostrarKillBlacklist then
            DEFAULT_CHAT_FRAME:AddMessage("Bootybay: "..arg2.."",0,1,0);
        end
        
    -- Tempo e cemitério para ress em BG
    elseif arg1 == "BBSCRES" then
        if BOOTYBAY.dbConfig.MostrarAvisoRess then
            DEFAULT_CHAT_FRAME:AddMessage("Bootybay: "..arg2.."",0,1,0);
        end 
        
    -- Recebimento da Blacklist
    elseif arg1 == "BBSCB" and arg4 ~= BOOTYBAY.NOME_PLAYER and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) then
        local nome, id = strsplit(";", arg2)
            if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.Blacklist, nome) then
                if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.BlacklistExcluidos, nome) then
                    if tonumber(id) > BOOTYBAY.dbChar.BlacklistExcluidos[nome] then
                        BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbChar.BlacklistExcluidos, nome)
                        BOOTYBAY.dbChar.Blacklist[nome] = tonumber(id)
                    end
                else
                    BOOTYBAY.dbChar.Blacklist[nome] = tonumber(id)
                end
            end
            
    -- Recebimento dos players que devem sair da Blacklist
    elseif arg1 == "BBSCE" and arg4 ~= BOOTYBAY.NOME_PLAYER and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) then
        local nome, id = strsplit(";", arg2)
            if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.BlacklistExcluidos, nome) then
                if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.Blacklist, nome) then
                    if tonumber(id) > BOOTYBAY.dbChar.Blacklist[nome] then
                        BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbChar.Blacklist, nome)
                        BOOTYBAY.dbChar.BlacklistExcluidos[nome] = tonumber(id)
                    end
                else
                    BOOTYBAY.dbChar.BlacklistExcluidos[nome] = tonumber(id)
                end
            end
            
    -- Recebimento das configurações do guild master
    elseif arg1 == "BBSCCN" and arg4 ~= BOOTYBAY.NOME_PLAYER and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) then
        local config,val,control = strsplit(";", arg2)
        local val, control = tonumber(val), tonumber(control)
        if control >= BOOTYBAY.dbControle[config] then
            BOOTYBAY.dbControle[config] = control
            BOOTYBAY.dbChar[config] = val
        end
        
    -- Recebimento do Score de BG
    elseif arg1 == "GRASCORE" and arg4 ~= BOOTYBAY.NOME_PLAYER and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) then
        local n, k, tbg, vbg, d = strsplit(";", arg2)
        local k, tbg, vbg, d = tonumber(k), tonumber(tbg), tonumber(vbg), tonumber(d)
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.Score, n) then
            if d < BOOTYBAY.dbData.Score[n]["data"] then
                return
            else
                BOOTYBAY.dbData.Score[n]["data"]        = d
                BOOTYBAY.dbData.Score[n]["totalKill"]   = k
                BOOTYBAY.dbData.Score[n]["totalBG"]     = tbg
                BOOTYBAY.dbData.Score[n]["vitoriasBG"]  = vbg
            end
        else
            BOOTYBAY.dbData.Score[n] = 
            {
                ["totalBG"]    = tbg, 
                ["vitoriasBG"] = vbg, 
                ["totalKill"]  = k, 
                ["data"]       = d
            }
        end 
        
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, n) then
            BOOTYBAY.dbData.Score[n]["guild"] = true
        end
    
    -- Recebimento dos GUIDS
    elseif arg1 == "GRAGUID" and arg4 ~= BOOTYBAY.NOME_PLAYER and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) then
        local info = {
                strsplit(";",arg2)
            }
                
        for i = 2, #info do
            BOOTYBAY:AtualizarGuid(info[i], info[1], nil)
        end
    
    -- Informações sobre versão utilizada e solicitação para iniciar sincronização com membro da guild
    elseif arg1 == "GRASYNC" and arg4 ~= BOOTYBAY.NOME_PLAYER then
        if not tContains(BOOTYBAY.Usuarios, arg4) then tinsert(BOOTYBAY.Usuarios, arg4) end
        if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) and arg3 == "GUILD" and GetGuildInfo("player") then BOOTYBAY:LoadGuildInfo() end
        
        local vers, tipo = strsplit(";",arg2)

        if tipo == "resposta" then return end
        
        local vers = tonumber(vers)
        if vers > BOOTYBAY.VERSION and vers > BOOTYBAY.dbConfig.NovaVers then  
            if BOOTYBAY.dbConfig.NovaVers <= BOOTYBAY.VERSION then
                print("|cffff00ffBootybay Alerta: seu addon está desatualizado!")
            end
            BOOTYBAY.dbConfig.NovaVers = vers
        end
        
        if vers < BOOTYBAY.VERSION then
            if BOOTYBAY.dbControle.FiltroDownload[arg4] then
                if (time() - BOOTYBAY.dbControle.FiltroDownload[arg4]) > 3600 then
                    BOOTYBAY.dbControle.FiltroDownload[arg4] = time()
                    ChatThrottleLib:SendAddonMessage("ALERT","GRAKILL", "Atualize o addon para a última versão disponível:\nDownload:|r |cffFFFFFFdiscord.gg/y53pXFKRkG|r", "WHISPER", arg4)
                end
            else
                BOOTYBAY.dbControle.FiltroDownload[arg4] = time()
                ChatThrottleLib:SendAddonMessage("ALERT","GRAKILL", "Atualize o addon para a última versão disponível:\nDownload:|r |cffFFFFFFdiscord.gg/y53pXFKRkG|r", "WHISPER", arg4)
            end
        end
        
        ChatThrottleLib:SendAddonMessage("ALERT","GRASYNC", tostring(BOOTYBAY.VERSION)..";resposta", "WHISPER", arg4)

        if arg3 == "GUILD" then 
            if BOOTYBAY.Bool_GuildLoaded and BOOTYBAY.dbChar.NomeGuild ~= GetGuildInfo("player") then 
                BOOTYBAY:LoadGuildInfo()
            else
                BOOTYBAY:Sincronizar("WHISPER", arg4)
            end
        end
        
    -- Recebimento do Ranking
    elseif arg1 == "GRARANKING" and BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4) then
        -- nome, killstreakmax, blacklistkills, winstreaksolomax, recordekillsdia, winstreakGrupo, killbg, dmg, heal
        local n, k, bk, ws, hk, wg, kb, d, h = strsplit(";", arg2)
        local k, bk, ws, hk, wg, kb, d, h = tonumber(k), tonumber(bk), tonumber(ws), tonumber(hk), tonumber(wg), tonumber(kb), tonumber(d), tonumber(h)
        if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.MembrosData, n) then
            BOOTYBAY.dbChar.MembrosData[n] = 
            {
                ["killstreak"]      = k,
                ["blacklistkills"]  = bk,
                ["winstreakSolo"]   = ws,
                ["killsdia"]        = hk,
                ["winstreakGrupo"]  = wg,
                ["killbg"]          = kb,
                ["dmg"]             = d,
                ["heal"]            = h
            }
        -- resolvi fazer assim, checando um por um, e não via um controle unico por time(), porque pode ocorrer do player perder o arquivo com os dados salvos e acabar resetando seus dados no ranking ao enviar um novo controle zerado
        else
                if BOOTYBAY.dbChar.MembrosData[n]["killstreak"] < k then
                    BOOTYBAY.dbChar.MembrosData[n]["killstreak"] = k
                end
                if BOOTYBAY.dbChar.MembrosData[n]["blacklistkills"] < bk then
                    BOOTYBAY.dbChar.MembrosData[n]["blacklistkills"] = bk
                end
                if BOOTYBAY.dbChar.MembrosData[n]["winstreakSolo"] < ws then
                    BOOTYBAY.dbChar.MembrosData[n]["winstreakSolo"] = ws
                end
                if BOOTYBAY.dbChar.MembrosData[n]["killsdia"] < hk then
                    BOOTYBAY.dbChar.MembrosData[n]["killsdia"] = hk
                end
                if BOOTYBAY.dbChar.MembrosData[n]["winstreakGrupo"] < wg then
                    BOOTYBAY.dbChar.MembrosData[n]["winstreakGrupo"] = wg
                end
                if BOOTYBAY.dbChar.MembrosData[n]["killbg"] < kb then
                    BOOTYBAY.dbChar.MembrosData[n]["killbg"] = kb
                end
                if BOOTYBAY.dbChar.MembrosData[n]["dmg"] < d then
                    BOOTYBAY.dbChar.MembrosData[n]["dmg"] = d
                end
                if BOOTYBAY.dbChar.MembrosData[n]["heal"] < h then
                    BOOTYBAY.dbChar.MembrosData[n]["heal"] = h
                end
        end
        
    -- Resposta para a consulta de versão
    elseif arg1 == "GRACHECK" then
        if not tContains(BOOTYBAY.Usuarios, arg4) then tinsert(BOOTYBAY.Usuarios, arg4) end
        if arg3 == "GUILD" or (arg3 ~= "GUILD" and not BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, arg4)) then
            ChatThrottleLib:SendAddonMessage("ALERT","GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está usando a versão r"..tostring(BOOTYBAY.VERSION).."", "WHISPER", ""..arg4.."")
        end
    end
end

-- FILTROS

local function FiltroBootybay(self,event,msg,...)
    -- Erro ao enviar msg pra player offline
    local pattern = string.format(ERR_CHAT_PLAYER_NOT_FOUND_S, "(.-)", "(.-)")
    local player = string.match(msg, pattern)
    
    if player then
        if BOOTYBAY.FiltroOffline[player] then
            if (time() - BOOTYBAY.FiltroOffline[player]) < 360 then
                return true
            else
                BOOTYBAY.FiltroOffline[player] = time()
            end
        else
            BOOTYBAY.FiltroOffline[player] = time()
        end
    end

    -- Antininja
    if string.find(msg, "AntiNinja") or string.find(msg, "NBG") then
        if BOOTYBAY.dbConfig.FiltroNinja then return true end
        if BOOTYBAY.Bool_PlayerEmBG and BOOTYBAY.dbConfig.FiltroNinjaBG then return true end
    end

    return false, msg, ...
end

function Bootybay:UI_INFO_MESSAGE(...)
    -- Anuncios no chat tudo bem, no meio da minha tela não.
    if BOOTYBAY.dbConfig.FiltroLojaUI then
        local arg1 = ...
        local msg1 = (string.format("Ola %s :)",BOOTYBAY.NOME_PLAYER))
        local msg2 = "Acesse a nossa Loja VIP no jogo e receba seu item instantaneamente !"
        local msg3 = "ou va ate o npc que se localiza proximo da AH de Stormwind/Orgrimmar."
        
        if arg1 == msg1 or arg1 == msg2 then
            UIErrorsFrame:Clear()
        elseif string.find(arg1,msg3) then
            UIErrorsFrame:Clear()
            BOOTYBAY.frame:UnregisterEvent("UI_INFO_MESSAGE")
        end
    end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", FiltroBootybay);  