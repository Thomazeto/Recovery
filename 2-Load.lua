local Recovery, BOOTYBAY    = ...
BOOTYBAY.VERSION            = 16
BOOTYBAY.events             = {}
local Bootybay              = BOOTYBAY.events

BootybayConfig              = BootybayConfig or {}      -- Database das configurações
BootybayControle            = BootybayControle or {}    -- Database de controle das configurações impostas pelo guild master para saber se a informação recebida é atual ou já foi alterada
BootybayData                = BootybayData or {}        -- Database de informações salvas na pasta da acc (atualmente, scores e GUID)
BootybayCharInfo            = BootybayCharInfo or {}    -- Database de informações referente ao personagem ou a guild do personagem

-- Upvalue das tabelas do addon
BOOTYBAY.dbConfig           = nil
BOOTYBAY.dbControle         = nil
BOOTYBAY.dbData             = nil
BOOTYBAY.dbChar             = nil


BOOTYBAY.frame              = CreateFrame("Frame")
BOOTYBAY.NOME_PLAYER        = UnitName("player")
BOOTYBAY.HORA_DO_LOGIN      = time()
BOOTYBAY.PLAYER_RANK_GUILD  = 15
BOOTYBAY.PLAYER_GUID        = 0
BOOTYBAY.Bool_GuildLoaded   = false
BOOTYBAY.GuildMembers       = {}



function BOOTYBAY:VariaveisPadrao()
    local defaultBootybayConfig     =   
    {
        NovaVers                = 0,
        RadarIntervalo          = 40,
        RadarPremade            = true,
        RadarPremadeTamanho     = 5,
        RadarPremadeMudanca     = 2,
        RadarPremadeSoInimigo   = false,
        RadarInvasao            = true,
        RadarInvasaoQuantidade  = 10,
        MostrarKill             = true,
        MostrarMortes           = true,
        MostrarResultadoBGs     = true,
        MostrarKillBlacklist    = true,
        MostrarAvisoRess        = true,
        ScoreMouseover          = true,
        ScoreValidade           = 172800, -- 3 dias // 60*60*24*2 = 
        ScoreDescarte           = 2505600, -- 30 dias
        ScoreTooltipBG          = true,
        ScoreTooltipAliado      = true,
        ScoreTooltipContra      = true,
        NameplateBL             = true,
        NameplateHeal           = true,
        NameplateDharkyn        = true,
        FiltroNinja             = false,
        FiltroNinjaBG           = true,
        FiltroLojaUI            = true,
        GuildBankTooltip        = true,
        GuildBankTooltipData    = false,
        Icone_Y                 = -6, 
        Icone_X                 = 0
    }

    local defaultBootybayControle   = 
    {
        Officer                 = 0,
        TempoUltimoSyncScore    = 0,
        Itens                   = 0,
        EntradaBG               = 0,
        GuildBank               = 0,
        GuildBankData           = 0
    }

    local defaultBootybayData       = 
    {
        Score                   = {},
        Guid                    = {},
        BgJunto                 = {},
        BgContra                = {},
    }

    local defaultBootybayCharInfo   = 
    {
        WinStreakSolo           = 0,
        WinStreakGrupo          = 0,
        KillStreak              = 0,
        KillsHoje               = 0,
        Aliados                 = {},
        Blacklist               = {},
        BlacklistExcluidos      = {},
        Officer                 = 0,
        MembrosData             = {}, 
        NomeGuild               = "guild",
        Itens                   = {},
        GuildBank               = {},
    }
    
    
    BootybayConfig              = BOOTYBAY.Fn_CopiarTabela(defaultBootybayConfig, BootybayConfig)
    BootybayControle            = BOOTYBAY.Fn_CopiarTabela(defaultBootybayControle, BootybayControle)
    BootybayData                = BOOTYBAY.Fn_CopiarTabela(defaultBootybayData, BootybayData)
    BootybayCharInfo            = BOOTYBAY.Fn_CopiarTabela(defaultBootybayCharInfo, BootybayCharInfo)
    
    BOOTYBAY.dbConfig           = BootybayConfig
    BOOTYBAY.dbControle         = BootybayControle
    BOOTYBAY.dbData             = BootybayData
    BOOTYBAY.dbChar             = BootybayCharInfo
    
    BOOTYBAY.PLAYER_GUID        = UnitGUID("player")
    
    -- Cria a tabela do proprio player no ranking da guild caso ele não esteja lá   
    if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.MembrosData, BOOTYBAY.NOME_PLAYER) then
        BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]   = 
        {
            ["killstreak"]      = 0,
            ["blacklistkills"]  = 0,
            ["winstreakSolo"]   = 0,
            ["killsdia"]        = 0,
            ["winstreakGrupo"]  = 0,
            ["killbg"]          = 0,
            ["dmg"]             = 0,
            ["heal"]            = 0,
            ["timeplayed"]      = 0
        }
    end
    
    -- Remove as entrys invalidas da tabela de score
    for k, v in pairs(BOOTYBAY.dbData.Score) do
        if v == nil or v["data"] == nil or v["vitoriasBG"] == nil or v["totalBG"] == nil or (v["vitoriasBG"] > v["totalBG"]) or v["totalBG"] == 0 then
            BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbData.Score, k)
        elseif v["totalBG"] < 15 and not v["guild"] then
            BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbData.Score, k)
        elseif BOOTYBAY.dbConfig.ScoreDescarte ~= 0 and (BOOTYBAY.HORA_DO_LOGIN - BOOTYBAY.dbData.Score[k]["data"]) >= BOOTYBAY.dbConfig.ScoreDescarte and not v["guild"]then
            BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbData.Score, k) 
        end
    end

    -- Transfere os dados da antiga tabela de aliados da guild para a nova, mais abrangente
    if BOOTYBAY.dbChar.Aliados["control"] ~= 1 then
        for k, v in pairs(BOOTYBAY.dbChar.Aliados) do
            if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.BgJunto, k) then
                BOOTYBAY.dbData.BgJunto[k]              = {}
                BOOTYBAY.dbData.BgJunto[k]["vitoria"]   = v.wincount
                BOOTYBAY.dbData.BgJunto[k]["total"]     = v.wincount + v.loseCount
            else
                BOOTYBAY.dbData.BgJunto[k]["vitoria"]   = BOOTYBAY.dbData.BgJunto[k]["vitoria"] + v.wincount
                BOOTYBAY.dbData.BgJunto[k]["total"]     = BOOTYBAY.dbData.BgJunto[k]["total"] + v.wincount + v.loseCount
            end     
        end
    BOOTYBAY.dbChar.Aliados             = {}
    BOOTYBAY.dbChar.Aliados["control"]  = 1
    end
    
    -- Deleta as entrys com 0 jogos da nova tabela de aliados (pra não dar erro em quem usou uma versão temporária de testes do addon)
    for k, v in pairs(BOOTYBAY.dbData.BgJunto) do
        if v.total == 0 then
            BOOTYBAY.dbData.BgJunto[k] = nil
        end
    end
    
    -- Limpa variaveis antigas que não são mais usadas nas tabelas do addon
    for k,v in pairs (BOOTYBAY.dbConfig) do
        if defaultBootybayConfig[k] == nil then
            BOOTYBAY.dbConfig[k] = nil
        end
    end
    
    for k,v in pairs (BOOTYBAY.dbChar) do
        if defaultBootybayCharInfo[k] == nil then
            BOOTYBAY.dbChar[k] = nil
        end
    end
    
    for k,v in pairs (BOOTYBAY.dbData) do
        if defaultBootybayData[k] == nil then
            BOOTYBAY.dbData[k] = nil
        end
    end
    
    for k,v in pairs (BOOTYBAY.dbControle) do
        if defaultBootybayControle[k] == nil then
            BOOTYBAY.dbControle[k] = nil
        end
    end
    
    -- Desativa a função de inspect score ao usar o GearScore
    if GS_Data then
        BOOTYBAY.frame:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
        print("|cff307DD6Bootybay Surfclub:|r a atualização dos scores pelo mouseover não é compativel com o uso do addon GearScore, você verá apenas scores que tenham sido enviados por membros da sua guild que utilizem o addon.")
        print("------")
    end
end

function BOOTYBAY:LoadGuildInfo(inicial)
    BOOTYBAY.Bool_GuildLoaded = true
    
    if BOOTYBAY.dbChar.NomeGuild ~= GetGuildInfo("player") then -- Reset
        if BOOTYBAY.dbChar.NomeGuild ~= "guild" then
            print("|cff307DD6O addon da Bootybay Surfclub percebeu que houve uma mudança de guild neste personagem, portanto todas as configurações de sua antiga guild foram deletadas.")
            for _, v in pairs(BOOTYBAY.dbControle) do v = 0 end
            BOOTYBAY.dbChar.Officer             = 0
            BOOTYBAY.dbChar.Blacklist           = {}
            BOOTYBAY.dbChar.BlacklistExcluidos  = {}
            BOOTYBAY.dbChar.Itens               = {}
            BOOTYBAY.dbChar.MembrosData         = {}
            BOOTYBAY.dbChar.GuildBank           = {}
            BOOTYBAY.dbChar.Itens               = {}
        end
        BOOTYBAY.dbChar.NomeGuild               = GetGuildInfo("player")
    end


    BOOTYBAY.PLAYER_GUID = UnitGUID("player")
    BOOTYBAY.GuildMembers = table.wipe(BOOTYBAY.GuildMembers)
    SetGuildRosterShowOffline(true)
    local guildMember, rank
    for i = 1, GetNumGuildMembers(), 1 do
        local guildMember,_,rank = GetGuildRosterInfo(i)
        BOOTYBAY.GuildMembers[guildMember] = rank   
            if guildMember == BOOTYBAY.NOME_PLAYER then
                BOOTYBAY.PLAYER_RANK_GUILD = rank
            end
    end

    if GuildFrameLFGButton then
        if GuildFrameLFGButton:GetChecked() then
            SetGuildRosterShowOffline(true)
        else
            SetGuildRosterShowOffline(false)
        end
    else
        SetGuildRosterShowOffline(false)
    end
end

function Bootybay:GUILD_ROSTER_UPDATE(...)
    local arg1 = ...
    if BOOTYBAY.Bool_GuildLoaded == false then
        if GetGuildInfo("player") then
            BOOTYBAY:LoadGuildInfo()
            BOOTYBAY:Sincronizar("GUILD")
        end
    else
        if arg1 == 1 then -- Promote/Join/Kick
            if GetGuildInfo("player") then
                BOOTYBAY:LoadGuildInfo()
            end
        end
    end
end

function Bootybay:ADDON_LOADED(...)
    local arg1 = ...
    if arg1 == "Recovery" then
        print("------\nAddon da guild |cff307DD6Bootybay Surfclub (Recovery)|r versão r"..BOOTYBAY.VERSION.." - |cff307DD6Killax|r (WoW-BR). \nAcesse o painel digitando \"/gra\"")
        print("------")
        
        BOOTYBAY:VariaveisPadrao()
        
        local Honor = GetHonorCurrency()
        if Honor == 75000 then
            print("|cffff00ffBootybay Alerta: Você atingiu o CAP de honor!|r")
            PlaySound("3081", "Master")
        elseif Honor > 68500 and Honor < 75000 then
            print("|cffff00ffBootybay Alerta: Você está muito próximo do cap de honor|r")
            PlaySound("3081", "Master")
        end
    
        if BOOTYBAY.dbConfig.NovaVers ~= 0 and BOOTYBAY.dbConfig.NovaVers > BOOTYBAY.VERSION then
            print("|cffff00ffBootybay Surfclub alerta: seu addon está desatualizado!|r")
        end
        
    elseif arg1 == "WIM" then
        print("------\n|cff307DD6Bootybay Surfclub:|r O sistema de radar de premades e invasões não é compativel com o addon WIM - WoW Instant Messenger.\nPara fazer uso do radar será necessário desabilitar esse addon.")
        print("------")
    end
end