local Recovery, BOOTYBAY    = ...
local Bootybay              = BOOTYBAY.events

local BootybayTimer         = CreateFrame("Frame")
BootybayTimer.Intervalo     = 0

BOOTYBAY.GuildFactionRadar  = {}
BOOTYBAY.PremadesOld        = {}
BOOTYBAY.PremadesAtual      = {}
BOOTYBAY.MapaNoRadar        = 0

local ExecutarRadarInvasao  = false
local FiltroRadarBG         = 0
local ResultadoWHO          = 0
local QueryText             = nil
local Battlegrounds         = {"Warsong Gulch", "Arathi Basin", "Eye of the Storm", "Alterac Valley", "Isle of Conquest", "Strand of the Ancients", "Wintergrasp"}
local CidadesAlly           = {"Stormwind City", "Elwynn Forest", "Ironforge", "Darnassus", "The Exodar"}
local CidadesHorda          = {"Orgrimmar", "Durotar", "Thunder Bluff", "Undercity", "Silvermoon City"}

local InvasaoCidadesAlly    = 
{
    ["Stormwind City"]      = 0,
    ["Elwynn Forest"]       = 0,
    ["Ironforge"]           = 0,
    ["Darnassus"]           = 0,
    ["The Exodar"]          = 0
}
local CacheInvasaoCidadesAlly   = 
{
    ["Stormwind City"]      = 0,
    ["Elwynn Forest"]       = 0,
    ["Ironforge"]           = 0,
    ["Darnassus"]           = 0,
    ["The Exodar"]          = 0
}
local InvasaoCidadesHorda   = 
{
    ["Orgrimmar"]           = 0,
    ["Durotar"]             = 0,
    ["Thunder Bluff"]       = 0,
    ["Undercity"]           = 0,
    ["Silvermoon City"]     = 0
}
local CacheInvasaoCidadesHorda  = 
{
    ["Orgrimmar"]           = 0,
    ["Durotar"]             = 0,
    ["Thunder Bluff"]       = 0,
    ["Undercity"]           = 0,
    ["Silvermoon City"]     = 0
}


-- PREHOOK
local origSendWho           = SendWho

SendWho = function (...)
    if BOOTYBAY.MapaNoRadar == 0 or (BOOTYBAY.MapaNoRadar ~= 0 and QueryText == ...) then
        return origSendWho(...)
    else
        print("|cffFFFF55Radar Bootybay: o radar está sendo executado neste mesmo instante, e por isso sua solicitação de /who foi bloqueada, tente novamente em 1 segundo.|r")
    return nil
    end
end

function BOOTYBAY:FinalizarRadarPremades()
    -- VER PREMADES QUE SAIRAM DA BG
    for k,v in pairs(BOOTYBAY.PremadesOld) do -- k = guild, v = tabela com zonas
        for x,z in pairs(BOOTYBAY.PremadesOld[k]) do -- x = zona, z = quantidade de players nessa zona
            if BOOTYBAY.Fn_ContemChave(BOOTYBAY.PremadesAtual,k) then -- se tem a guild na tab atual remova apenas as premades das zonas que não tem mais
                if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.PremadesAtual[k],x) or BOOTYBAY.PremadesAtual[k][x] <= 2 then
                    if BOOTYBAY.GuildFactionRadar[k] == 1 then
                        if not BOOTYBAY.dbConfig.RadarPremadeSoInimigo or (BOOTYBAY.dbConfig.RadarPremadeSoInimigo and BOOTYBAY.PLAYER_FACTION_ID ~= 1) then
                            print("|cffFFFF55Radar Bootybay: premade da|r |cff2369cc"..k.."|r |cffFFFF55saiu de "..x.."|r")
                        end
                    else
                        if not BOOTYBAY.dbConfig.RadarPremadeSoInimigo or (BOOTYBAY.dbConfig.RadarPremadeSoInimigo and BOOTYBAY.PLAYER_FACTION_ID ~= 0) then
                            print("|cffFFFF55Radar Bootybay: premade da|r |cFFFF0000"..k.."|r |cffFFFF55saiu de "..x.."|r")
                        end
                    end
                    v[x] = nil
                end
            else -- se não tem a guild, remova as premades de todas as zonas
                if BOOTYBAY.GuildFactionRadar[k] == 1 then
                    if not BOOTYBAY.dbConfig.RadarPremadeSoInimigo or (BOOTYBAY.dbConfig.RadarPremadeSoInimigo and BOOTYBAY.PLAYER_FACTION_ID ~= 1) then
                        print("|cffFFFF55Radar Bootybay: premade da|r |cff2369cc"..k.."|r |cffFFFF55saiu de "..x.."|r")
                    end
                else
                    if not BOOTYBAY.dbConfig.RadarPremadeSoInimigo or (BOOTYBAY.dbConfig.RadarPremadeSoInimigo and BOOTYBAY.PLAYER_FACTION_ID ~= 0) then
                        print("|cffFFFF55Radar Bootybay: premade da|r |cFFFF0000"..k.."|r |cffFFFF55saiu de "..x.."|r")
                    end
                end
                v[x] = nil
            end
        end
    end
            
    -- DESCARTE DE GUILDS SEM GRUPO MINIMO, ANUNCIO DE ENTRADA E MUDANÇA DE TAMANHO
    for k,v in pairs(BOOTYBAY.PremadesAtual) do -- k = guild, v = tabela com zonas
        for x,z in pairs (v) do -- x = zona, z = quantidade de players nessa zona
            if (BOOTYBAY.Fn_ContemChave(BOOTYBAY.PremadesOld,k) and BOOTYBAY.Fn_ContemChave(BOOTYBAY.PremadesOld[k],x)) and ((BOOTYBAY.PremadesOld[k][x] - z) >= BOOTYBAY.dbConfig.RadarPremadeMudanca) then
                if BOOTYBAY.GuildFactionRadar[k] == 1 then
                    if not BOOTYBAY.dbConfig.RadarPremadeSoInimigo or (BOOTYBAY.dbConfig.RadarPremadeSoInimigo and BOOTYBAY.PLAYER_FACTION_ID ~= 1) then
                        print("|cffFFFF55Radar Bootybay: grupo da|r |cff2369cc"..k.."|r |cffFFFF55em "..x.." diminuiu para "..z.."|r")
                    end
                else
                    if not BOOTYBAY.dbConfig.RadarPremadeSoInimigo or (BOOTYBAY.dbConfig.RadarPremadeSoInimigo and BOOTYBAY.PLAYER_FACTION_ID ~= 0) then
                        print("|cffFFFF55Radar Bootybay: grupo da|r |cFFFF0000"..k.."|r |cffFFFF55em "..x.." diminuiu para "..z.."|r")
                    end
                end
                BOOTYBAY.PremadesOld[k][x] = z
            end
            if z < BOOTYBAY.dbConfig.RadarPremadeTamanho then
                -- descarta as infos de guilds com grupos menores que o tamanho minimo e que nao tenham sido anunciados
                if (not BOOTYBAY.Fn_ContemChave(BOOTYBAY.PremadesOld, k) or not BOOTYBAY.Fn_ContemChave(BOOTYBAY.PremadesOld[k],x)) then
                    v[x] = nil
                end
            else
                if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.PremadesOld, k) then BOOTYBAY.PremadesOld[k] = {} end
                if BOOTYBAY.Fn_ContemChave(BOOTYBAY.PremadesOld[k],x) then
                    if (z - BOOTYBAY.PremadesOld[k][x]) >= BOOTYBAY.dbConfig.RadarPremadeMudanca then
                        if BOOTYBAY.GuildFactionRadar[k] == 1 then
                            if not BOOTYBAY.dbConfig.RadarPremadeSoInimigo or (BOOTYBAY.dbConfig.RadarPremadeSoInimigo and BOOTYBAY.PLAYER_FACTION_ID ~= 1) then
                                print("|cffFFFF55Radar Bootybay: grupo da|r |cff2369cc"..k.."|r |cffFFFF55subiu para "..z.." em "..x.."|r")
                            end
                        else
                            if not BOOTYBAY.dbConfig.RadarPremadeSoInimigo or (BOOTYBAY.dbConfig.RadarPremadeSoInimigo and BOOTYBAY.PLAYER_FACTION_ID ~= 0) then
                                print("|cffFFFF55Radar Bootybay: grupo da|r |cFFFF0000"..k.."|r |cffFFFF55subiu para "..z.." em "..x.."|r")
                            end
                        end
                        BOOTYBAY.PremadesOld[k][x] = z
                    end
                else
                    if BOOTYBAY.GuildFactionRadar[k] == 1 then
                        if not BOOTYBAY.dbConfig.RadarPremadeSoInimigo or (BOOTYBAY.dbConfig.RadarPremadeSoInimigo and BOOTYBAY.PLAYER_FACTION_ID ~= 1) then
                            print("|cffFFFF55Radar Bootybay:|r |cff2369cc"..k.."|r |cffFFFF55tem "..z.." players em "..x.."|r")
                        end
                    else
                        if not BOOTYBAY.dbConfig.RadarPremadeSoInimigo or (BOOTYBAY.dbConfig.RadarPremadeSoInimigo and BOOTYBAY.PLAYER_FACTION_ID ~= 0) then
                            print("|cffFFFF55Radar Bootybay:|r |cFFFF0000"..k.."|r |cffFFFF55tem "..z.." players em "..x.."|r")
                        end
                    end
                    BOOTYBAY.PremadesOld[k][x] = z
                end
            end
        end
    end
end

function BOOTYBAY:FinalizarRadarInvasao()
    if BOOTYBAY.PLAYER_FACTION == "Alliance" then
        for k,v in pairs(InvasaoCidadesAlly) do -- k: mapa, v: quantidade de player
            if CacheInvasaoCidadesAlly[k] ~= 0 then
                if v == 0 then
                    print("|cfff2aa18Radar Bootybay: todos os|r |cFFFF0000Hordas|r |cfff2aa18sairam de "..k.."|r")
                    CacheInvasaoCidadesAlly[k] = 0
                elseif (CacheInvasaoCidadesAlly[k] - v) >= 5 then
                    print("|cfff2aa18Radar Bootybay: o grupo da|r |cFFFF0000Horda|r |cfff2aa18em "..k.." diminuiu, agora são "..v.." players|r")
                    CacheInvasaoCidadesAlly[k] = v
                elseif (v - CacheInvasaoCidadesAlly[k]) >= 5 then
                    if v == 49 then
                        print("|cfff2aa18Radar Bootybay: o grupo da|r |cFFFF0000Horda|r |cfff2aa18em "..k.." cresceu, agora são mais do que 50 players|r")
                    else
                        print("|cfff2aa18Radar Bootybay: o grupo da|r |cFFFF0000Horda|r |cfff2aa18em "..k.." cresceu, agora são "..v.." players|r")
                    end
                    
                    CacheInvasaoCidadesAlly[k] = v
                end
            else
                if v >= BOOTYBAY.dbConfig.RadarInvasaoQuantidade then
                    if v == 49 then
                        print("|cfff2aa18Radar Bootybay: tem uma raid de mais de 50|r |cFFFF0000Hordas|r |cfff2aa18em "..k.."|r")
                    else
                        print("|cfff2aa18Radar Bootybay: tem um grupo de "..v.."|r |cFFFF0000Hordas|r |cfff2aa18em "..k.."|r")
                    end
                    
                CacheInvasaoCidadesAlly[k] = v
                end
            end
            
            InvasaoCidadesAlly[k] = 0
        end
    else
        for k,v in pairs(InvasaoCidadesHorda) do -- k: mapa, v: quantidade de player
            if CacheInvasaoCidadesHorda[k] ~= 0 then
                if v == 0 then
                    print("|cfff2aa18Radar Bootybay: todos os|r |cff2369ccAllys|r |cfff2aa18sairam de "..k.."|r")
                    CacheInvasaoCidadesHorda[k] = 0
                elseif (CacheInvasaoCidadesHorda[k] - v) >= 5 then
                    print("|cfff2aa18Radar Bootybay: o grupo da|r |cff2369ccAlly|r |cfff2aa18em "..k.." diminuiu, agora são "..v.." players|r")
                    CacheInvasaoCidadesHorda[k] = v
                elseif (v - CacheInvasaoCidadesHorda[k]) >= 5 then
                    if v == 49 then
                        print("|cfff2aa18Radar Bootybay: o grupo da|r |cff2369ccAlly|r |cfff2aa18em "..k.." cresceu, agora são mais do que 50 players|r")
                    else
                        print("|cfff2aa18Radar Bootybay: o grupo da |r |cff2369ccAlly|r |cfff2aa18em "..k.." cresceu, agora são "..v.." players|r")
                    end
                    
                    CacheInvasaoCidadesHorda[k] = v
                end
            else
                if v >= BOOTYBAY.dbConfig.RadarInvasaoQuantidade then
                    if v == 49 then
                        print("|cfff2aa18Radar Bootybay: tem uma raid de mais de 50|r |cff2369ccAllys|r |cfff2aa18em "..k.."|r")
                    else
                        print("|cfff2aa18Radar Bootybay: tem um grupo de "..v.."|r |cff2369ccAllys|r |cfff2aa18em "..k.."|r")
                    end
                    CacheInvasaoCidadesHorda[k] = v
                end
            end
            
            InvasaoCidadesHorda[k] = 0
        end
    end

    ExecutarRadarInvasao = false
    BOOTYBAY.MapaNoRadar = 0
end

function BOOTYBAY:EnviarQueryWhoInvasao(mapa)
    if BOOTYBAY.PLAYER_FACTION == "Alliance" then
        if CidadesAlly[mapa] ~= nil then
            BOOTYBAY.MapaNoRadar = mapa
            QueryText = "z-\""..CidadesAlly[mapa].."\" 80 r-\"orc\" r-\"undead\" r-\"tauren\" r-\"troll\" r-\"blood\""
            SendWho(QueryText)
            return
        end
    else
        if CidadesHorda[mapa] ~= nil then
            BOOTYBAY.MapaNoRadar = mapa
            QueryText = "z-\""..CidadesHorda[mapa].."\" 80 r-\"human\" r-\"draenei\" r-\"night\" r-\"gnome\" r-\"dwarf\""
            SendWho(QueryText)
            return
        end
    end

    FriendsFrame:RegisterEvent("WHO_LIST_UPDATE")
    SetWhoToUI(nil)
    BOOTYBAY:FinalizarRadarInvasao()
end

function BOOTYBAY:EnviarQueryWhoPremade(mapa)
    if Battlegrounds[mapa] ~= nil then
        BOOTYBAY.MapaNoRadar = mapa
        if FiltroRadarBG == 0 then
            QueryText = "z-\""..Battlegrounds[mapa].."\" 80"
            SendWho(QueryText)
        elseif FiltroRadarBG == 10 then
            QueryText = "z-\""..Battlegrounds[mapa].."\" 80 r-\"human\" r-\"draenei\" r-\"night\" r-\"gnome\" r-\"dwarf\""
            SendWho(QueryText)
        elseif FiltroRadarBG == 20 then
            QueryText = "z-\""..Battlegrounds[mapa].."\" 80 r-\"orc\" r-\"undead\" r-\"tauren\" r-\"troll\" r-\"blood\""
            SendWho(QueryText)
        elseif FiltroRadarBG == 11 then
            QueryText = "z-\""..Battlegrounds[mapa].."\" 80 r-\"human\" r-\"draenei\" r-\"night\" r-\"gnome\" r-\"dwarf\" c-\"pala\" c-\"mage\" c-\"druid\" c-\"hunter\" c-\"rogue\""
            SendWho(QueryText)
        elseif FiltroRadarBG == 12 then
            QueryText = "z-\""..Battlegrounds[mapa].."\" 80 r-\"human\" r-\"draenei\" r-\"night\" r-\"gnome\" r-\"dwarf\" c-\"warr\" c-\"death\" c-\"lock\" c-\"priest\" c-\"shaman\""
            SendWho(QueryText)
        elseif FiltroRadarBG == 21 then
            QueryText = "z-\""..Battlegrounds[mapa].."\" 80 r-\"orc\" r-\"undead\" r-\"tauren\" r-\"troll\" r-\"blood\" c-\"pala\" c-\"mage\" c-\"druid\" c-\"hunter\" c-\"rogue\""
            SendWho(QueryText)
        elseif FiltroRadarBG == 22 then
            QueryText = "z-\""..Battlegrounds[mapa].."\" 80 r-\"orc\" r-\"undead\" r-\"tauren\" r-\"troll\" r-\"blood\" c-\"warr\" c-\"death\" c-\"lock\" c-\"priest\" c-\"shaman\""
            SendWho(QueryText)
        end
    return
    end

    
    BOOTYBAY:FinalizarRadarPremades()
    BOOTYBAY.MapaNoRadar = 0
    if BOOTYBAY.dbConfig.RadarInvasao then
        ExecutarRadarInvasao = true
        SetWhoToUI(1)
        BOOTYBAY:EnviarQueryWhoInvasao(1)
    else
        FriendsFrame:RegisterEvent("WHO_LIST_UPDATE")
        SetWhoToUI(nil)
    end
end

function BOOTYBAY:ExtrairDadosWho()
    if ExecutarRadarInvasao then
        for i = 1, ResultadoWHO do
            local _,_,_,_,_,zone = GetWhoInfo(i)
            if BOOTYBAY.PLAYER_FACTION == "Alliance" then
                if tContains(CidadesAlly, zone) then
                    InvasaoCidadesAlly[zone] = InvasaoCidadesAlly[zone] + 1
                end
            else
                if tContains(CidadesHorda, zone) then
                    InvasaoCidadesHorda[zone] = InvasaoCidadesHorda[zone] + 1
                end
            end
        end
    else
        for i = 1, ResultadoWHO do
            local _,guild,_,r,_,zone = GetWhoInfo(i)
            if guild ~= "" then
                if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildFactionRadar, guild) then
                    if r == "Human" or r == "Night Elf" or r == "Draenei" or r == "Gnome" or r == "Dwarf" then
                        BOOTYBAY.GuildFactionRadar[guild] = 1
                    else
                        BOOTYBAY.GuildFactionRadar[guild] = 0
                    end
                end

                if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.PremadesAtual, guild) then
                    BOOTYBAY.PremadesAtual[guild] = {}
                end
                
                if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.PremadesAtual[guild], zone) then
                    BOOTYBAY.PremadesAtual[guild][zone] = 1
                else
                    BOOTYBAY.PremadesAtual[guild][zone] = BOOTYBAY.PremadesAtual[guild][zone] + 1
                end
            end
        end
    end
end

function Bootybay:WHO_LIST_UPDATE(...)
    if BOOTYBAY.MapaNoRadar == 0 then return end
    
    ResultadoWHO = GetNumWhoResults()
    
    if ExecutarRadarInvasao then
        BOOTYBAY:ExtrairDadosWho()
        BOOTYBAY:EnviarQueryWhoInvasao(BOOTYBAY.MapaNoRadar+1)
    else

        if ResultadoWHO < 49 and ResultadoWHO ~= 0 then
            BOOTYBAY:ExtrairDadosWho()

            if FiltroRadarBG == 0 then
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar+1)
                return
            elseif FiltroRadarBG == 10 then
                FiltroRadarBG = 20
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar)
                return
            elseif FiltroRadarBG == 11 then
                FiltroRadarBG = 12
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar)
                return
            elseif FiltroRadarBG == 12 then
                FiltroRadarBG = 21
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar)
                return
            elseif FiltroRadarBG == 20 then
                FiltroRadarBG = 0
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar+1)
                return
            elseif FiltroRadarBG == 21 then
                FiltroRadarBG = 22
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar)
                return
            elseif FiltroRadarBG == 22 then
                FiltroRadarBG = 0
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar+1)
                return
            end             
        elseif ResultadoWHO == 0 then
            BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar+1)
        else
            if FiltroRadarBG == 0 then
                FiltroRadarBG = 10
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar)
                return
            elseif FiltroRadarBG == 10 then
                FiltroRadarBG = 11
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar)
                return
            elseif FiltroRadarBG == 11 then
                BOOTYBAY:ExtrairDadosWho()
                FiltroRadarBG = 12
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar)
                return
            elseif FiltroRadarBG == 12 then
                BOOTYBAY:ExtrairDadosWho()
                FiltroRadarBG = 21
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar)
                return
            elseif FiltroRadarBG == 20 then
                FiltroRadarBG = 21
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar)
                return
            elseif FiltroRadarBG == 21 then
                BOOTYBAY:ExtrairDadosWho()
                FiltroRadarBG = 22
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar)
                return
            elseif FiltroRadarBG == 22 then
                BOOTYBAY:ExtrairDadosWho()
                FiltroRadarBG = 0
                BOOTYBAY:EnviarQueryWhoPremade(BOOTYBAY.MapaNoRadar+1)
                return
            end
        end
    end
end

BootybayTimer:SetScript("OnUpdate", function(self, elapsed)
    BootybayTimer.Intervalo = BootybayTimer.Intervalo + elapsed
    
    if BootybayTimer.Intervalo >= BOOTYBAY.dbConfig.RadarIntervalo then 
        if _G.WhoFrame:IsVisible() then -- Usuario está lendo a janela de /who, então vamos dar tempo a ele
            BootybayTimer.Intervalo = BootybayTimer.Intervalo - 5
            return
        end
        
        BootybayTimer.Intervalo = 0
        
        if WIM3_Data then return end -- WIM (WoW Instant Messenger)
        
        if BOOTYBAY.dbConfig.RadarPremade then
            SetWhoToUI(1)
            FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
            table.wipe(BOOTYBAY.PremadesAtual)
            BOOTYBAY:EnviarQueryWhoPremade(1)
            return
        else 
            if BOOTYBAY.dbConfig.RadarInvasao then
                ExecutarRadarInvasao = true
            end
        end
            
        if ExecutarRadarInvasao then
            SetWhoToUI(1)
            FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
            BOOTYBAY:EnviarQueryWhoInvasao(1)
        end
    end
end)