local Recovery, BOOTYBAY    = ...
local Bootybay              = BOOTYBAY.events
local BootybayTimer         = CreateFrame("Frame")
BootybayTimer.UpdateBgScore = 0
BootybayTimer.UpdateAntiAfk = 0

BOOTYBAY.PLAYER_FACTION     = UnitFactionGroup("player")
BOOTYBAY.PLAYER_FACTION_ID  = 0
BOOTYBAY.Bool_PlayerEmBG    = false
BOOTYBAY.Bool_BgEncerrada   = false
BOOTYBAY.Healers            = {}

local TamanhoDoGrupo        = 0
local UltimoAviso           = 0
local QuemSolicitou         = nil
local Bool_RessAvisado      = false
local PlayersAway           = {}

local select, strjoin       = _G.select, _G.strjoin

if BOOTYBAY.PLAYER_FACTION      == "Horde" then 
    BOOTYBAY.PLAYER_FACTION_ID  = 0
elseif BOOTYBAY.PLAYER_FACTION  == "Alliance" then
    BOOTYBAY.PLAYER_FACTION_ID  = 1
end


-- Finalização de uma BG
function Bootybay:UPDATE_BATTLEFIELD_STATUS(...)
    if not BOOTYBAY.Bool_PlayerEmBG then return end -- pra não rodar dentro de arena (até mesmo spectator)
    if BOOTYBAY.Bool_BgEncerrada then return end -- já estamos processando esse codigo, ignore
    
    local vitoria
    local empate
    
    if GetBattlefieldWinner() == nil then -- a bg nao foi finalizada, o evento foi disparado por outra coisa, entao retorne
        return
    elseif GetBattlefieldWinner() > 1 then -- draw?
        BOOTYBAY.Bool_BgEncerrada = true
        empate = true
    else
        BOOTYBAY.Bool_BgEncerrada = true
        if GetBattlefieldWinner() == BOOTYBAY.PLAYER_FACTION_ID then
            vitoria = true
        else
            vitoria = false
        end
    end

    local MembrosGuild = 0
    
    for i = 1, GetNumBattlefieldScores(), 1 do
        local name, kB, _, _, _, faction, _, _, _, _, dmg, heal = GetBattlefieldScore(i)
        if name then    
        if name ~= BOOTYBAY.NOME_PLAYER then
            if  faction ~= BOOTYBAY.PLAYER_FACTION_ID then
                if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.BgContra, name) then
                    BOOTYBAY.dbData.BgContra[name] = {}
                    BOOTYBAY.dbData.BgContra[name]["vitoria"] = 0
                    BOOTYBAY.dbData.BgContra[name]["total"] = 0
                end
            
                if vitoria then
                    BOOTYBAY.dbData.BgContra[name]["vitoria"] = BOOTYBAY.dbData.BgContra[name]["vitoria"] + 1
                end
            
                BOOTYBAY.dbData.BgContra[name]["total"] = BOOTYBAY.dbData.BgContra[name]["total"] + 1
            else
                if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.BgJunto, name) then
                    BOOTYBAY.dbData.BgJunto[name] = {}
                    BOOTYBAY.dbData.BgJunto[name]["vitoria"] = 0
                    BOOTYBAY.dbData.BgJunto[name]["total"] = 0
                end
            
                if vitoria then
                    BOOTYBAY.dbData.BgJunto[name]["vitoria"] = BOOTYBAY.dbData.BgJunto[name]["vitoria"] + 1
                end
            
                BOOTYBAY.dbData.BgJunto[name]["total"] = BOOTYBAY.dbData.BgJunto[name]["total"] + 1
                
                if BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, name) then
                    MembrosGuild = MembrosGuild + 1
                end
            end
        else
            if dmg > BOOTYBAY.dbChar.MembrosData[name]["dmg"] then
                BOOTYBAY.dbChar.MembrosData[name]["dmg"] = dmg
                local sendMessage = strjoin(";",BOOTYBAY.NOME_PLAYER, "0", "0", "0", "0", "0", "0", tostring(BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["dmg"]), "0")
                ChatThrottleLib:SendAddonMessage("BULK","GRARANKING", sendMessage, "GUILD")
            end
            
            if heal > BOOTYBAY.dbChar.MembrosData[name]["heal"] then
                BOOTYBAY.dbChar.MembrosData[name]["heal"] = heal
                local sendMessage = strjoin(";",BOOTYBAY.NOME_PLAYER, "0", "0", "0", "0", "0", "0", "0", tostring(BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["heal"]))
                ChatThrottleLib:SendAddonMessage("BULK","GRARANKING", sendMessage, "GUILD")
            end
            
            if kB > BOOTYBAY.dbChar.MembrosData[name]["killbg"] then
                BOOTYBAY.dbChar.MembrosData[name]["killbg"] = kB
                local sendMessage = strjoin(";",BOOTYBAY.NOME_PLAYER, "0", "0", "0", "0", "0", tostring(BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["killbg"]), "0", "0")
                ChatThrottleLib:SendAddonMessage("BULK","GRARANKING", sendMessage, "GUILD")
            end
        end
        end
    end

    if empate then 
        ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." empatou uma BG.", "GUILD") 
        return 
    end
    
    if vitoria then
        if TamanhoDoGrupo <= 2 and MembrosGuild <= 1 then
            BOOTYBAY.dbChar.WinStreakSolo = BOOTYBAY.dbChar.WinStreakSolo + 1
            if BOOTYBAY.dbChar.WinStreakSolo % 5 == 0 then
                ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." venceu uma BG Solo/Duo, já são "..BOOTYBAY.dbChar.WinStreakSolo.." seguidas!", "GUILD");
            else
                ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." venceu uma BG Solo/Duo.", "GUILD")
            end
            if BOOTYBAY.dbChar.WinStreakSolo > BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["winstreakSolo"] then
                BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["winstreakSolo"] = BOOTYBAY.dbChar.WinStreakSolo
                local sendMessage = strjoin(";",BOOTYBAY.NOME_PLAYER, "0", "0", tostring(BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["winstreakSolo"]), "0", "0", "0", "0", "0")
                ChatThrottleLib:SendAddonMessage("BULK","GRARANKING", sendMessage, "GUILD")
            end
        else
            BOOTYBAY.dbChar.WinStreakGrupo = BOOTYBAY.dbChar.WinStreakGrupo + 1
            if BOOTYBAY.dbChar.WinStreakGrupo % 5 == 0 then
                ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." venceu uma BG em grupo, já são "..BOOTYBAY.dbChar.WinStreakGrupo.." seguidas!", "GUILD")
            else
                ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." venceu uma BG em grupo.", "GUILD")
            end
            if BOOTYBAY.dbChar.WinStreakGrupo > BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["winstreakGrupo"] then
                BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["winstreakGrupo"] = BOOTYBAY.dbChar.WinStreakGrupo
                local sendMessage = strjoin(";",BOOTYBAY.NOME_PLAYER, "0", "0", "0", "0", tostring(BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["winstreakGrupo"]), "0", "0", "0")
                ChatThrottleLib:SendAddonMessage("BULK","GRARANKING", sendMessage, "GUILD")
            end
        end
    else
        if time() - BOOTYBAY.dbControle.EntradaBG <= 180 then
            BOOTYBAY.dbControle.EntradaBG = 0
            ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." perdeu uma BG que estava quase terminando quando ele entrou, portanto o winstreak não foi alterado.", "GUILD")
        else
            if TamanhoDoGrupo <= 2 and MembrosGuild <= 1 then
                if BOOTYBAY.dbChar.WinStreakSolo >= 5 then
                    ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." perdeu uma BG Solo/Duo, já eram "..BOOTYBAY.dbChar.WinStreakSolo.." vitórias seguidas.", "GUILD")
                else
                    ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." perdeu uma BG Solo/Duo.", "GUILD")
                end
                BOOTYBAY.dbChar.WinStreakSolo = 0
            else
                if BOOTYBAY.dbChar.WinStreakGrupo >= 5 then
                    ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." perdeu uma BG em grupo, já eram "..BOOTYBAY.dbChar.WinStreakGrupo.." vitórias seguidas.", "GUILD")
                else
                    ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." perdeu uma BG em grupo.", "GUILD")
                end
                BOOTYBAY.dbChar.WinStreakGrupo = 0
            end
        end
    end
end

-- Entrada em um novo mapa
function Bootybay:PLAYER_ENTERING_WORLD(self, event, isInitialLogin, isReloadingUi)
    local inInstance, instanceType = IsInInstance()
    BOOTYBAY.Healers = table.wipe(BOOTYBAY.Healers)
    PlayersAway = table.wipe(PlayersAway)

    if inInstance == 1 and instanceType == "pvp" and GetBattlefieldWinner() == nil then -- Entramos numa BG em andamento
        BOOTYBAY.Bool_PlayerEmBG = true
        
        if GetRealNumRaidMembers() ~= 0 then
            TamanhoDoGrupo = GetRealNumRaidMembers()
        else
            TamanhoDoGrupo = GetRealNumPartyMembers() + 1
        end
        
        BOOTYBAY.dbControle.EntradaBG = time()
        ChatThrottleLib:SendAddonMessage("ALERT","GRASYNC", tostring(BOOTYBAY.VERSION), "BATTLEGROUND")
        RequestBattlefieldScoreData()
        return
    end

    if BOOTYBAY.Bool_PlayerEmBG then -- Estavamos em uma BG antes de entrar nesse mapa
        if BOOTYBAY.Bool_BgEncerrada then -- a BG que estavamos já foi finalizada
            BOOTYBAY.Bool_BgEncerrada = false
            BOOTYBAY.Bool_PlayerEmBG = false
        else -- a BG não foi finalizada, então demos leave
            if TamanhoDoGrupo <= 2 then
                if BOOTYBAY.dbChar.WinStreakSolo >= 5 then
                    ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." ABANDONOU uma BG Solo/Duo, já eram "..BOOTYBAY.dbChar.WinStreakSolo.." vitórias seguidas.", "GUILD")
                else
                    ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." ABANDONOU uma BG Solo/Duo.", "GUILD")
                end
                BOOTYBAY.dbChar.WinStreakSolo = 0
            else 
                if BOOTYBAY.dbChar.WinStreakGrupo >= 5 then
                    ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." ABANDONOU uma BG em grupo, já eram "..BOOTYBAY.dbChar.WinStreakGrupo.." vitórias seguidas.", "GUILD")
                else
                    ChatThrottleLib:SendAddonMessage("ALERT","BBSCBG", ""..BOOTYBAY.NOME_PLAYER.." ABANDONOU uma BG em grupo.", "GUILD")
                end
                BOOTYBAY.dbChar.WinStreakGrupo = 0
            end
        BOOTYBAY.Bool_PlayerEmBG = false
        end
        
        local Honor = GetHonorCurrency()
        if Honor == 75000 then
            print("|cffff00ffBootybay Alerta: Você atingiu o CAP de honor!")
            PlaySound("3081", "Master")
        elseif Honor >= 68500 and Honor < 75000 then
            print("|cffff00ffBootybay Alerta: Você está muito próximo do cap de honor")
            PlaySound("3081", "Master")
        end
    end
end

-- Honorable Kills
function Bootybay:PLAYER_PVP_KILLS_CHANGED(...)
    local QuantidadeKillsNoDia = GetPVPSessionStats();

    if QuantidadeKillsNoDia == 1 then -- primeira kill da sessão
        if BOOTYBAY.dbChar.KillsHoje > BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["killsdia"] then -- quebra do recorde
            BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["killsdia"] = BOOTYBAY.dbChar.KillsHoje
            
            local sendMessage = strjoin(";",BOOTYBAY.NOME_PLAYER, "0", "0", "0", tostring(BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["killsdia"]), "0", "0", "0", "0")
            ChatThrottleLib:SendAddonMessage("BULK","GRARANKING", sendMessage, "GUILD")
        end
    elseif QuantidadeKillsNoDia % 100 == 0 and (QuantidadeKillsNoDia ~= UltimoAviso) and QuantidadeKillsNoDia ~= 0 then -- avisar de 100 em 100
        UltimoAviso = QuantidadeKillsNoDia
        ChatThrottleLib:SendAddonMessage("ALERT", "BBSCKS", ""..BOOTYBAY.NOME_PLAYER.." tem "..QuantidadeKillsNoDia.." kills hoje!", "GUILD")
    end
    BOOTYBAY.dbChar.KillsHoje = QuantidadeKillsNoDia
end

-- Acessar informações de placar de BG
function BOOTYBAY:AcessarInfoBG()
    local quantAlly, quantHorda = 0, 0  
    
    for i=1, MAX_BATTLEFIELD_QUEUES do
        local status, map, ID, _, _, size = GetBattlefieldStatus(i)
        
        if status == "active" then
            PanelTemplates_SetTab(WorldStateScoreFrame, 1) -- coloca o painel da BG pra mostrar ambas as facções
            for s=1, GetNumBattlefieldScores() do
                if select(6,GetBattlefieldScore(s)) == 0 then -- facção
                    quantHorda = quantHorda + 1
                else 
                    quantAlly = quantAlly + 1
                end
            end
            
            if map == "Alterac Valley" or map == "Arathi Basin" or map == "Isle of Conquest" then --usam o mesmo formato de informações no topo da tela
                ChatThrottleLib:SendAddonMessage("ALERT", "GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está em "..map..": "..ID.."\nAlliance: "..select(3,GetWorldStateUIInfo(1)).." - "..quantAlly.." players\nHorda: "..select(3,GetWorldStateUIInfo(2)).." - "..quantHorda.." players\nTempo: "..BOOTYBAY.Fn_ConverterTime(GetBattlefieldInstanceRunTime() / 1000).."", "WHISPER", QuemSolicitou)
            elseif map == "Warsong Gulch" then
                ChatThrottleLib:SendAddonMessage("ALERT", "GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está em "..map..": "..ID.."\nAlliance: "..select(3,GetWorldStateUIInfo(2)).." - "..quantAlly.." players\nHorda: "..select(3,GetWorldStateUIInfo(3)).." - "..quantHorda.." players\n"..select(3,GetWorldStateUIInfo(1)).."", "WHISPER", QuemSolicitou)
            elseif map == "Eye of the Storm" then
                ChatThrottleLib:SendAddonMessage("ALERT", "GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está em "..map..": "..ID.."\nAlliance: "..select(3,GetWorldStateUIInfo(2)).." - "..quantAlly.." players\nHorda: "..select(3,GetWorldStateUIInfo(3)).." - "..quantHorda.." players\nTempo: "..BOOTYBAY.Fn_ConverterTime(GetBattlefieldInstanceRunTime() / 1000).."", "WHISPER", QuemSolicitou)
            elseif map == "Strand of the Ancients" then
                    local ataque
                    local quantAtaque
                    local defesa
                    local quantDefesa
                    local round
                if select(2,GetWorldStateUIInfo(2)) == 1 then -- tentar descobrir pq que as vezes falha
                    round = 1
                else 
                    round = 2
                end
                
                if round == 1 then
                    if select(6,GetWorldStateUIInfo(2)) == "Alliance status" then
                        ataque = "Ally"
                        quantAtaque = quantAlly
                        defesa = "Horda"
                        quantDefesa = quantHorda
                    else
                        ataque = "Horda"
                        quantAtaque = quantHorda
                        defesa = "Ally"
                        quantDefesa = quantAlly
                    end
                else
                    if select(6,GetWorldStateUIInfo(6)) == "Alliance status" then
                        ataque = "Ally"
                        quantAtaque = quantAlly
                        defesa = "Horda"
                        quantDefesa = quantHorda
                    else
                        ataque = "Horda"
                        quantAtaque = quantHorda
                        defesa = "Ally"
                        quantDefesa = quantAlly
                    end
                end
            ChatThrottleLib:SendAddonMessage("ALERT", "GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está em "..map..": "..ID.."\nAtacando: "..ataque.." - "..quantAtaque.." players\nDefendendo: "..defesa.." - "..quantDefesa.." players\n"..select(3,GetWorldStateUIInfo(9)).."", "WHISPER", QuemSolicitou) 
            end
            QuemSolicitou = nil -- apaga o nome de quem solicitou essas infos, para não enviar novamente no proximo update
        end
    end
end

-- Acessar informações sobre situação do Queue
function BOOTYBAY:AcessarInfoQueue(arg1)
    local SemQueue = true
    
    if select(1,GetMapInfo()) == "LakeWintergrasp" then
        if select(2,GetWorldStateUIInfo(7)) == 1 then
        SemQueue = false
            if select(2,GetWorldStateUIInfo(5)) == 1 then
                ChatThrottleLib:SendAddonMessage("ALERT", "GRAQ",""..BOOTYBAY.NOME_PLAYER.." está em Wintergrasp:\nControle: Ally\nHorda: "..select(3,GetWorldStateUIInfo(3)).."\nAlly: "..select(3,GetWorldStateUIInfo(4)).."\n"..select(3,GetWorldStateUIInfo(7)).."", "WHISPER", arg1) 
            elseif select(2,GetWorldStateUIInfo(6)) == 1 then
                ChatThrottleLib:SendAddonMessage("ALERT", "GRAQ",""..BOOTYBAY.NOME_PLAYER.." está em Wintergrasp:\nControle: Horda\nHorda: "..select(3,GetWorldStateUIInfo(3)).."\nAlly: "..select(3,GetWorldStateUIInfo(4)).."\n"..select(3,GetWorldStateUIInfo(7)).."", "WHISPER", arg1) 
            end
        end
    end
        
    for i=1, MAX_BATTLEFIELD_QUEUES do
        local status, map, ID, _, _, size = GetBattlefieldStatus(i)
        
        if status == "active" then -- a luta está ativa
            if size == 0 then -- em BG o size é sempre 0
                QuemSolicitou = arg1
                if GetBattlefieldScore(1) ~= nil then -- temos informação disponivel no painel do score
                    BOOTYBAY:AcessarInfoBG()
                    return
                else -- não temos a info disponivel, então vamos solicitar ela
                    SetBattlefieldScoreFaction(nil)
                    RequestBattlefieldScoreData()
                    return
                end
            else -- size 2, 3 e 5 são de arena
                if size == 5 then -- Soloqueue usa a mesma bracket do 5v5
                    ChatThrottleLib:SendAddonMessage("ALERT","GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está lutando ou assistindo a um SoloQ ou 5v5 Skirmish", "WHISPER", arg1)
                    return
                else -- arena 2v2 ou 3v3
                    ChatThrottleLib:SendAddonMessage("ALERT","GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está lutando ou assistindo a uma arena "..size.."v"..size.."", "WHISPER", arg1)
                    return
                end
            end
        elseif status == "queued" then -- está dentro do queue
            if size == 0 then
                ChatThrottleLib:SendAddonMessage("ALERT","GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está no queue para "..map..".\nTempo até agora: "..BOOTYBAY.Fn_ConverterTime(GetBattlefieldTimeWaited(i) / 1000)..".", "WHISPER", arg1)
                SemQueue = false
            elseif size == 5 then
                ChatThrottleLib:SendAddonMessage("ALERT","GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está no queue para SoloQ ou 5v5 Skirmish.\nTempo até agora: "..BOOTYBAY.Fn_ConverterTime(GetBattlefieldTimeWaited(i) / 1000)..".", "WHISPER", arg1)
                SemQueue = false
            else
                ChatThrottleLib:SendAddonMessage("ALERT","GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está no queue para arena "..size.."v"..size..".\nTempo até agora: "..BOOTYBAY.Fn_ConverterTime(GetBattlefieldTimeWaited(i) / 1000)..".", "WHISPER", arg1)
                SemQueue = false
            end
        elseif status == "confirm" then -- o player foi convocado mas ainda não escolheu entrar ou sair
            ChatThrottleLib:SendAddonMessage("ALERT","GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está aguardando confimação para entrar na "..map.." "..ID.."", "WHISPER", arg1)
            SemQueue = false
        end
    end

    if select(2,IsInInstance()) == "raid" then      
        ChatThrottleLib:SendAddonMessage("ALERT", "GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está em "..select(1,GetInstanceInfo()).." ("..select(4,GetInstanceInfo())..")", "WHISPER", arg1)
        return
    end
    
    if UnitDebuff("player", "Deserter") then
        ChatThrottleLib:SendAddonMessage("ALERT","GRAQ", ""..BOOTYBAY.NOME_PLAYER.." está flagado com Deserter, duração: "..BOOTYBAY.Fn_ConverterTime(select(7,UnitDebuff("player", "Deserter")) - GetTime()).."", "WHISPER", arg1)
        return
    end
    
    if SemQueue then
        ChatThrottleLib:SendAddonMessage("ALERT","GRAQ", ""..BOOTYBAY.NOME_PLAYER.." não está em queue.", "WHISPER", arg1)
    end
end

function Bootybay:UPDATE_BATTLEFIELD_SCORE(...)
    if QuemSolicitou ~= nil then
        BOOTYBAY:AcessarInfoBG()
    end
end

function Bootybay:PLAYER_UNGHOST(...)
    if BOOTYBAY.Bool_PlayerEmBG and Bool_RessAvisado then
        Bool_RessAvisado = false
    end
end

function BOOTYBAY:ReportAway()
    for i=1, GetNumRaidMembers() do
        local nome = UnitName("raid" .. i) -- nome do player
        if nome == "Unknown" then return end
        if not PlayersAway[nome] then PlayersAway[nome] = {} end
        local zone = select(7,GetRaidRosterInfo(i))
    
        if not UnitIsConnected("raid" .. i) then -- checa se tem alguém offline a muito tempo
            if not PlayersAway[nome]["off"] then
                PlayersAway[nome]["off"] = true
                PlayersAway[nome]["offtick"] = 1
            else
                PlayersAway[nome]["offtick"] = PlayersAway[nome]["offtick"] + 1
                if PlayersAway[nome]["offtick"] == 30 then
                    print("|cffFFFF55Sistema de report automático da Bootybay:|r |cffff00ff"..nome.." |cffFFFF55foi reportado pois está offline a 30 segundos.|r")
                    ReportPlayerIsPVPAFK("raid" .. i)
                end
            end
        end
    
        if PlayersAway[nome]["off"] and zone and zone ~= "Offline" then -- checa se algum player marcado como offline logou
            PlayersAway[nome]["off"] = false
        end
        
        if UnitIsDeadOrGhost("raid" .. i) then -- checa se tem alguém morto a muito tempo
            if not PlayersAway[nome]["morto"] then
                PlayersAway[nome]["morto"] = true
                PlayersAway[nome]["mortotick"] = 1
            else
                PlayersAway[nome]["mortotick"] = PlayersAway[nome]["mortotick"] + 1
                if PlayersAway[nome]["mortotick"] == 61 then
                    print("|cffFFFF55Sistema de report automático da Bootybay:|r |cffff00ff"..nome.." |cffFFFF55foi reportado pois está morto a mais de 1 minuto.|r")
                    ReportPlayerIsPVPAFK("raid" .. i)
                end
            end
        else
            if PlayersAway[nome]["morto"] then
                PlayersAway[nome]["morto"] = false
            end
        end    
    end
end

BootybayTimer:SetScript("OnUpdate", function(self, elapsed)
    if BOOTYBAY.Bool_PlayerEmBG then
        if UnitIsDeadOrGhost("player") == 1 then
            if not Bool_RessAvisado and GetAreaSpiritHealerTime() ~= 0 then
                Bool_RessAvisado = true
                ChatThrottleLib:SendAddonMessage("ALERT","BBSCRES",""..BOOTYBAY.NOME_PLAYER.." nascerá em "..GetMinimapZoneText().." dentro de "..GetAreaSpiritHealerTime().."s","BATTLEGROUND")
            end
        end
        
        BootybayTimer.UpdateAntiAfk = BootybayTimer.UpdateAntiAfk + elapsed
        
        if BootybayTimer.UpdateAntiAfk >= 1 then
            BootybayTimer.UpdateAntiAfk = 0
            BOOTYBAY:ReportAway()
        end
        
        BootybayTimer.UpdateBgScore = BootybayTimer.UpdateBgScore + elapsed
        
        if BootybayTimer.UpdateBgScore >= 15 then
            if _G.WorldStateScoreFrame:IsVisible() then -- Usuario está lendo a janela de Score, então vamos dar tempo a ele
                BootybayTimer.UpdateBgScore = BootybayTimer.UpdateBgScore - 5
                return
            end
            
            BootybayTimer.UpdateBgScore = 0
            
            SetBattlefieldScoreFaction(nil)
            PanelTemplates_SetTab(WorldStateScoreFrame, 1)
            RequestBattlefieldScoreData()
        end
    end
end)