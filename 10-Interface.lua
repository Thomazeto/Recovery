local Recovery, BOOTYBAY    = ...
BOOTYBAY.Usuarios           = {}

local BootybayEditBoxParent = CreateFrame("Frame", "nItensBroadcast", UIParent)

do -- Paineis do Addon na Interface do jogo (Esc)

-- Painel Principal (/gra)
local BootybayPanel = CreateFrame("FRAME", "BootybayPanel");
    BootybayPanel.name = "Bootybay Surfclub"
    BootybayPanel:SetBackdrop(
    {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = 
        { 
            left = 4, 
            right = 4, 
            top = 4, 
            bottom = 4 
        }
    })
    BootybayPanel:SetBackdropColor(0,0,0,1)
    InterfaceOptions_AddCategory(BootybayPanel)

BootybayPanel.titulo = BootybayPanel:CreateFontString(nil, nil, "GameFontNormalLarge")
    BootybayPanel.titulo:SetPoint("TOP", 0, -15)
    BootybayPanel.titulo:SetFont('Fonts\\ARIALN.ttf', 20)
    BootybayPanel.titulo:SetText("Bootybay Surfclub")

BootybayPanel.estatisticas = BootybayPanel:CreateFontString(nil, nil, "GameFontNormal")
    BootybayPanel.estatisticas:SetFont('Fonts\\ARIALN.ttf', 13)
    BootybayPanel.estatisticas:SetPoint("TOP", -70, -120)
    BootybayPanel.estatisticas:SetWidth(220)
    BootybayPanel.estatisticas:SetJustifyH("LEFT")

BootybayPanel.recordes = BootybayPanel:CreateFontString(nil, nil, "GameFontNormal")
    BootybayPanel.recordes:SetFont('Fonts\\ARIALN.ttf', 13)
    BootybayPanel.recordes:SetPoint("TOP", 150, -120)
    BootybayPanel.recordes:SetWidth(220)
    BootybayPanel.recordes:SetJustifyH("LEFT")

BootybayPanel.infos = BootybayPanel:CreateFontString(nil, nil, "GameFontNormal")
    BootybayPanel.infos:SetFont('Fonts\\ARIALN.ttf', 13)
    BootybayPanel.infos:SetPoint("TOP", -85, -385)
    BootybayPanel.infos:SetWidth(220)
    BootybayPanel.infos:SetText("Addon das guilds |cFFFF0000<Bootybay Surfclub>|r e |cff307DD6<Recovery>|r by Killax (WoW-Brasil)")


BootybayPanel.vers = BootybayPanel:CreateFontString(nil, nil, "GameFontNormal")
    BootybayPanel.vers:SetFont('Fonts\\ARIALN.ttf', 13)
    --BootybayPanel.vers:SetPoint("TOP", 150, -390)
    BootybayPanel.vers:SetPoint("TOP", 150, -15)
    BootybayPanel.vers:SetWidth(220)

BootybayPanel.database = BootybayPanel:CreateFontString(nil, nil, "GameFontNormal")
    BootybayPanel.database:SetFont('Fonts\\ARIALN.ttf', 13)
    BootybayPanel.database:SetPoint("TOP", -70, -240) -- -210
    BootybayPanel.database:SetWidth(220)
    BootybayPanel.database:SetJustifyH("LEFT")

BootybayPanel.link = BootybayPanel:CreateFontString(nil, nil, "GameFontNormal")
    BootybayPanel.link:SetFont('Fonts\\ARIALN.ttf', 13)
    BootybayPanel.link:SetPoint("TOP", 120, -390)
    BootybayPanel.link:SetWidth(220)

BootybayPanel:SetScript("OnShow", function(self)
    BootybayPanel.estatisticas:SetFormattedText("Agora:\n\nKillstreak: %s\nWinstreak Solo/Duo: %s\nWinstreak Grupo: %s",BOOTYBAY.dbChar.KillStreak, BOOTYBAY.dbChar.WinStreakSolo, BOOTYBAY.dbChar.WinStreakGrupo)
    BootybayPanel.recordes:SetFormattedText("Recordes:\n\nKillstreak: %s\nKills no dia: %s\nWinstreak Solo/Duo: %s\nWinstreak Grupo: %s\n\nKills em uma BG: %s\nDano em uma BG: %s\nHeal em uma BG: %s\n\n\n\n\n\nKills da Blacklist: %s",BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["killstreak"], BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["killsdia"], BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["winstreakSolo"], BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["winstreakGrupo"], BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["killbg"], BOOTYBAY.Fn_AbreviarNumeros(BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["dmg"]), BOOTYBAY.Fn_AbreviarNumeros(BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["heal"]), BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["blacklistkills"])
    
    if BOOTYBAY.dbConfig.NovaVers > BOOTYBAY.VERSION then 
        BootybayPanel.vers:SetFormattedText("Versão: r%s\n|cFFFF0000DESATUALIZADO|r",BOOTYBAY.VERSION)
        BootybayPanel.link:SetText("atualize em:\n|cFFFF0000discord.gg/y53pXFKRkG|r")
    else
        BootybayPanel.vers:SetFormattedText("Versão: r%s",BOOTYBAY.VERSION)
    end
    
    local tamanhoScore  = 0
    local tamanhoGuid   = 0
    local tamanhoRename = 0 
    local tamanhoJunto  = 0
    local tamanhoContra = 0
    local tamanhoBL     = 0
    
    for k,v in pairs(BOOTYBAY.dbData.Score) do
        tamanhoScore = tamanhoScore + 1
    end
    
    for k,v in pairs(BOOTYBAY.dbData.Guid) do
        tamanhoGuid = tamanhoGuid + 1
        if #v > 1 then
            tamanhoRename = tamanhoRename +1
        end
    end
    
    for k,v in pairs(BOOTYBAY.dbData.BgJunto) do
        tamanhoJunto = tamanhoJunto + 1
    end
    
    for k,v in pairs(BOOTYBAY.dbData.BgContra) do
        tamanhoContra = tamanhoContra + 1
    end
    
    for k,v in pairs(BOOTYBAY.dbChar.Blacklist) do
        tamanhoBL = tamanhoBL + 1
    end
    
    BootybayPanel.database:SetFormattedText("DataBase (nº de players):\n~Score: %s\n~GUID: %s\n~Rename: %s\n~Bg Junto: %s\n~Bg Contra: %s\n\nGUILD\n~Blacklist: %s",tamanhoScore, tamanhoGuid, tamanhoRename, tamanhoJunto, tamanhoContra, tamanhoBL)
    
end)

-- Criação do botão dropdown de configuração
BootybayPanel.config = CreateFrame("FRAME", "BootybayPanel.config", BootybayPanel, "UIDropDownMenuTemplate")
    BootybayPanel.config:SetPoint("TOP", 0, -50)
    UIDropDownMenu_SetWidth(BootybayPanel.config, 110)
    UIDropDownMenu_SetText(BootybayPanel.config, "Configurações")
    UIDropDownMenu_JustifyText(BootybayPanel.config, "LEFT")
    BootybayPanel.config:SetBackdrop(
    {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { 
            left = 4,
            right = 4,
            top = 4,
            bottom = 4 
         }
    })
    BootybayPanel.config:SetBackdropColor(0,0,0,1)

local BotaoBlacklist = CreateFrame("Button", "BotaoBlacklist", BootybayPanel, "UIPanelButtonTemplate")
    BotaoBlacklist:SetPoint("TOP", 90, -330)
    BotaoBlacklist:SetWidth(200)
    BotaoBlacklist:SetHeight(30)
    BotaoBlacklist:SetText("Print Blacklist no Chat")
    BotaoBlacklist:SetScript("OnClick", function(self)
        local temp = {}
        for k, v in pairs(BOOTYBAY.dbChar.Blacklist) do
            table.insert(temp, k)
        end
    
        table.sort(temp)
        print("|cffFF6600Players na Blacklist da guild:")
        print("|cffFF6600"..table.concat(temp,", ").."")
    end)

-- Segundo Painel (/gra rank)
local Bootybay2 = CreateFrame("FRAME", "Bootybay2")
    Bootybay2.name = "Ranking"
    Bootybay2.parent = BootybayPanel.name
    Bootybay2:SetBackdrop(
    {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
        tile = true, 
        tileSize = 16, 
        edgeSize = 16, 
        insets = 
        { 
            left = 4, 
            right = 4, 
            top = 4, 
            bottom = 4 
        }
    })
    Bootybay2:SetBackdropColor(0,0,0,1)
    InterfaceOptions_AddCategory(Bootybay2)

Bootybay2.titulo = Bootybay2:CreateFontString(nil, nil, "GameFontNormalLarge")
    Bootybay2.titulo:SetPoint("TOP", 0, -10)
    Bootybay2.titulo:SetFont('Fonts\\ARIALN.ttf', 20)
    Bootybay2.titulo:SetText("Ranking da Guild")

Bootybay2.desc = Bootybay2:CreateFontString(nil, nil, "GameFontNormal")
    Bootybay2.desc:SetFont('Fonts\\ARIALN.ttf', 13)
    Bootybay2.desc:SetPoint("TOP", 0, -40)
    Bootybay2.desc:SetWidth(400)
    Bootybay2.desc:SetText("Visualize vários tipos de ranking envolvendo os membros da guild.\nAs informações geradas pelo addon, como por exemplo, Killstreak e Winstreak, só estão disponiveis para os membros que utilizam o addon.")

Bootybay2.ranking = CreateFrame("FRAME", "Bootybay2.ranking", Bootybay2, "UIDropDownMenuTemplate")
    Bootybay2.ranking:SetPoint("TOP", 0, -110)
    UIDropDownMenu_SetText(Bootybay2.ranking, "Mostrar:")
    UIDropDownMenu_JustifyText(Bootybay2.ranking, "LEFT")
    UIDropDownMenu_SetWidth(Bootybay2.ranking, 110)

-- Terceiro Painel (/gra gm)
local Bootybay3 = CreateFrame("FRAME", "Bootybay3")
    Bootybay3.name = "Guild Master"
    Bootybay3.parent = BootybayPanel.name
    Bootybay3:SetBackdrop(
    {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
        tile = true, 
        tileSize = 16, 
        edgeSize = 16, 
        insets = 
        { 
            left = 4, 
            right = 4, 
            top = 4, 
            bottom = 4 
        }
    })
    Bootybay3:SetBackdropColor(0,0,0,1)
    InterfaceOptions_AddCategory(Bootybay3)

Bootybay3:SetScript("OnShow", function(self)
    if BOOTYBAY.PLAYER_RANK_GUILD > 0 then 
        Bootybay3.desc = Bootybay3:CreateFontString(nil, nil, "GameFontNormal")
        Bootybay3.desc:SetFont('Fonts\\ARIALN.ttf', 13)
        Bootybay3.desc:SetPoint("TOP", 0, -200)
        Bootybay3.desc:SetWidth(400)
        Bootybay3.desc:SetText("Opções acessíveis apenas pelo Guild Master.")
        return
    end

Bootybay3.titulo = Bootybay3:CreateFontString(nil, nil, "GameFontNormalLarge")
    Bootybay3.titulo:SetPoint("TOP", 0, -10)
    Bootybay3.titulo:SetFont('Fonts\\ARIALN.ttf', 20)
    Bootybay3.titulo:SetText("Opções do Guild Master")

Bootybay3.desc = Bootybay3:CreateFontString(nil, nil, "GameFontNormal")
    Bootybay3.desc:SetFont('Fonts\\ARIALN.ttf', 13)
    Bootybay3.desc:SetPoint("TOP", 0, -40)
    Bootybay3.desc:SetWidth(400)
    Bootybay3.desc:SetText("Cadastre aqui os itens de interesse da guild.")
    
local BotaoItensInteresse = CreateFrame("Button", "BotaoItensInteresse", Bootybay3, "UIPanelButtonTemplate")
    BotaoItensInteresse:SetPoint("TOP", 0, -100)
    BotaoItensInteresse:SetWidth(250)
    BotaoItensInteresse:SetHeight(25)
    BotaoItensInteresse:SetText("Cadastrar Itens de Interesse da Guild")
    BotaoItensInteresse:SetScript("OnClick", function(self)
        InterfaceOptionsFrame:Hide()
        BootybayEditBoxParent:Show()
    end)
end)

end

-- MENU DE CONFIGURAÇÃO DO PAINEL 1
UIDropDownMenu_Initialize(BootybayPanel.config, function(self, level, menuList)
    if (level or 1) == 1 then
        local info          = UIDropDownMenu_CreateInfo() -- OPÇÕES RADAR
            info.text       = "Radar"
            info.menuList   = 1
            info.hasArrow   = true
            UIDropDownMenu_AddButton(info)
        local info          = UIDropDownMenu_CreateInfo() -- OPÇÕES SCORE
            info.text       = "Score"
            info.menuList   = 8
            info.hasArrow   = true
            UIDropDownMenu_AddButton(info)
        local info          = UIDropDownMenu_CreateInfo() -- OPÇÕES TOOLTIP PLAYERS
            info.text       = "Tooltips"
            info.menuList   = 14
            info.hasArrow   = true
            UIDropDownMenu_AddButton(info)
        local info          = UIDropDownMenu_CreateInfo() -- OPÇÕES FILTRO
            info.text       = "Filtros"
            info.menuList   = 15
            info.hasArrow   = true
            UIDropDownMenu_AddButton(info)
        local info          = UIDropDownMenu_CreateInfo() -- OPÇÕES NAMEPLATE
            info.text       = "Nameplate"
            info.menuList   = 16
            info.hasArrow   = true
            UIDropDownMenu_AddButton(info)
        local info          = UIDropDownMenu_CreateInfo() -- OPÇÕES MSG DO ADDON
            info.text       = "Msg Chat"
            info.menuList   = 11
            info.hasArrow   = true
            UIDropDownMenu_AddButton(info)
        local info          = UIDropDownMenu_CreateInfo() -- OPÇÕES ITENS
            info.text       = "Itens"
            info.menuList   = 17
            info.hasArrow   = true
            UIDropDownMenu_AddButton(info)
        if BOOTYBAY.PLAYER_RANK_GUILD == 0 then
        local info          = UIDropDownMenu_CreateInfo() -- OPÇÕES GUILD MASTER
            info.text       = "Guild Master"
            info.menuList   = 12
            info.hasArrow   = true
            UIDropDownMenu_AddButton(info)
        end
    else
        if menuList == 1 then       -- MENULIST DAS OPÇÕES DO RADAR
            local info                  = UIDropDownMenu_CreateInfo() -- ATIVAR/DESATIVAR O RADAR DE PREMADES
                info.func               = self.funcBool
                info.checked            = BOOTYBAY.dbConfig.RadarPremade
                info.keepShownOnClick   = true
                info.text, info.arg1    = "Premades", "RadarPremade"
                info.tooltipTitle       = "Premades"
                info.tooltipText        = "Roda automaticamente uma série de querys de /who nos mapas de BGs, e então verifica se alguma guild possui uma premade ativa"
                info.menuList           = 2
                info.hasArrow           = true
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- ATIVAR/DESATIVAR O RADAR DE INVASÃO
                info.func               = self.funcBool
                info.checked            = BOOTYBAY.dbConfig.RadarInvasao
                info.keepShownOnClick   = true
                info.text               = "Invasões"
                info.arg1               = "RadarInvasao"
                info.tooltipTitle       = "Invasões"
                info.tooltipText        = "Roda automaticamente uma série de querys de /who nos mapas controlados pela sua facção, e avisa caso identifique uma raid inimiga"
                info.menuList           = 5
                info.hasArrow           = true
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- INTERVALO DE FREQUÊNCIA DO RADAR
                info.text               = "Intervalo"
                info.tooltipTitle       = "Intervalo"
                info.tooltipText        = "Define qual será o intervalo, em segundos, entre as execuções do sistema de radar.\nVale tanto para o de Premades como o de Invasão"
                info.menuList           = 7
                info.hasArrow           = true
                UIDropDownMenu_AddButton(info, level)
        elseif menuList == 2 then   -- MENULIST DAS OPÇÕES DO RADAR DE PREMADE
            local info                  = UIDropDownMenu_CreateInfo() -- TAMANHO MINIMO PRA PREMADES
                info.text               = "Tamanho mínimo"
                info.notCheckable       = true
                info.disabled           = not BOOTYBAY.dbConfig.RadarPremade
                info.tooltipTitle       = "Tamanho mínimo"
                info.tooltipText        = "Define qual é o tamanho mínimo para que um grupo seja considerado uma premade pelo radar"
                info.menuList           = 3
                info.hasArrow           = true
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- TOLERANCIA PARA MUDANÇAS
                info.text               = "Mudança mínima"
                info.notCheckable       = true
                info.disabled           = not BOOTYBAY.dbConfig.RadarPremade
                info.keepShownOnClick   = true
                info.tooltipTitle       = "Tolerância de Mudanças"
                info.tooltipText        = "Define qual é a tolerância que o addon deve ter ao anunciar alterações em alguma premade, vale tanto para aumento como diminuição dos grupos"
                info.menuList           = 4
                info.hasArrow           = true
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- MOSTRAR APENAS INIMIGOS
                info.func               = self.funcBool
                info.checked            = BOOTYBAY.dbConfig.RadarPremadeSoInimigo
                info.keepShownOnClick   = true
                info.text               = "Só guilds inimigas"
                info.arg1               = "RadarPremadeSoInimigo"
                info.tooltipTitle       = "Guilds Inimigas"
                info.tooltipText        = "Se marcar essa opção o addon só mostrará premades de guilds da facção oposta no radar, com a opção desmarcada, todas as guilds serão mostradas."
                UIDropDownMenu_AddButton(info, level)
        elseif menuList == 3 then   -- MENULIST COM TAMANHO MINIMO DE PREMADES
            for i = 3,10 do
                local info              = UIDropDownMenu_CreateInfo()
                    info.text           = i 
                    info.arg1           = "RadarPremadeTamanho"
                    info.arg2           = i
                    info.func           = self.funcNum
                    info.disabled       = not BOOTYBAY.dbConfig.RadarPremade
                    if i == BOOTYBAY.dbConfig.RadarPremadeTamanho then info.checked = true end
                    UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == 4 then   -- MENULIST COM TOLERANCIA PARA MUDANÇAS
            for i = 1,4 do
                local info              = UIDropDownMenu_CreateInfo()
                    info.text           = i 
                    info.arg1           = "RadarPremadeMudanca"
                    info.arg2           = i
                    info.func           = self.funcNum
                    info.disabled       = not BOOTYBAY.dbConfig.RadarPremade
                    if i == BOOTYBAY.dbConfig.RadarPremadeMudanca then info.checked = true end
                    UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == 5 then   -- MENULIST DAS OPÇÕES DO RADAR DE INVASÕES
            local info                  = UIDropDownMenu_CreateInfo() -- TAMANHO MINIMO PRA INVASÕES
                info.text               = "Tamanho mínimo"
                info.notCheckable       = true
                info.disabled           = not BOOTYBAY.dbConfig.RadarInvasao
                info.tooltipTitle       = "Tamanho mínimo"
                info.tooltipText        = "Definir qual é a quantidade minima de players da facção inimiga que devem estar reunidos no mapa para que seja considerada uma invasão pelo radar\nPara mudanças, o valor de tolerância é fixado em 5 players."
                info.menuList           = 6
                info.hasArrow           = true
                UIDropDownMenu_AddButton(info, level)
        elseif menuList == 6 then   -- MENULIST COM TAMANHO MINIMO PRA CONSIDERAR INVASÃO
            for i = 5,30,5 do
                local info              = UIDropDownMenu_CreateInfo()
                    info.text           = i 
                    info.arg1           = "RadarInvasaoQuantidade"
                    info.arg2           = i
                    info.func           = self.funcNum
                    info.disabled       = not BOOTYBAY.dbConfig.RadarInvasao
                    if i == BOOTYBAY.dbConfig.RadarInvasaoQuantidade then info.checked = true end
                    UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == 7 then   -- MENULIST COM INTERVALOS DO RADAR
            for i = 20,120,20 do
                local info              = UIDropDownMenu_CreateInfo()
                    info.text           = i
                    info.arg1           = "RadarIntervalo"
                    info.arg2           = i
                    info.func           = self.funcNum
                    info.disabled       = not BOOTYBAY.dbConfig.RadarIntervalo
                    if i == BOOTYBAY.dbConfig.RadarIntervalo then info.checked = true end
                    UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == 8 then   -- MENULIST COM OPÇÕES DO SCORE
            local info                  = UIDropDownMenu_CreateInfo() -- ATIVAR/DESATIVAR SCORE DE MOUSEOVER
                info.func               = self.funcBool
                info.checked            = BOOTYBAY.dbConfig.ScoreMouseover
                info.keepShownOnClick   = true
                info.text               = "Salvar Score do Mouseover"
                info.arg1               = "ScoreMouseover"
                info.tooltipTitle       = "Score Mouseover"
                info.tooltipText        = "Automaticamente salva o score de um player próximo quando você passar o mouse em cima do personagem dele.\nAtenção: NÃO COMPATÍVEL com o uso do addon GearScore."
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- TEMPO PRA ATUALIZAR SCORES
                info.text               = "Dias para atualizar o score"
                info.tooltipTitle       = "Atualizar"
                info.tooltipText        = "Define qual deve ser o tempo, em dias, para que uma informação de score seja atualizada.\nIsso é importante para evitar que o addon fique atualizando o score de todos os players o tempo todo"
                info.menuList           = 9
                info.hasArrow           = true
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- APAGAR SCORE ANTIGOS
                info.text               = "Descartar scores antigos"
                info.tooltipTitle       = "Apagar Scores"
                info.tooltipText        = "Definir se o addon deve apagar os scores antigos, e se positivo, definir o periodo, em dias, com que essa limpeza deva ocorrer"
                info.menuList           = 10
                info.hasArrow           = true
                UIDropDownMenu_AddButton(info, level)
        elseif menuList == 9 then   -- MENULIST COM DIAS PARA ATUALIZAR SCORES
            for i = 3,15,3 do
                local info              = UIDropDownMenu_CreateInfo()
                    info.text           = i 
                    info.arg1           = "ScoreValidade"
                    info.arg2           = i
                    info.func           = self.funcNum
                    if (i-1)*60*60*24 == BOOTYBAY.dbConfig.ScoreValidade then info.checked = true end
                    UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == 10 then  -- MENULIST COM DIAS PARA DESCARTAR O SCORE
            for i = 0,30,5 do
                local info              = UIDropDownMenu_CreateInfo()
                    if i == 0 then info.text = "Nunca" else info.text = i end
                    info.arg1           = "ScoreDescarte"
                    info.arg2           = i
                    info.func           = self.funcNum
                    if i == BOOTYBAY.dbConfig.ScoreDescarte then info.checked = true end
                    if (i-1)*60*60*24 == BOOTYBAY.dbConfig.ScoreDescarte then info.checked = true end
                    UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == 11 then  -- MENULIST COM OPÇÕES DO QUE MOSTRAR DAS MSG DO ADDON
            local info                  = UIDropDownMenu_CreateInfo() -- MOSTRAR KillStreak
                info.func               = self.funcBool
                info.text               = "Mostrar Killstreak (chat)"
                info.tooltipTitle       = "Killstreak"
                info.tooltipText        = "Desmarque essa opção para não receber mais as mensagens do tipo \"Fulano matou Ciclano e alcança a marca de 15 kills sem morrer\""
                info.checked            = BOOTYBAY.dbConfig.MostrarKill
                info.arg1               = "MostrarKill"
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- MOSTRAR MORTES
                info.func               = self.funcBool
                info.text               = "Mostrar Mortes (chat)"
                info.tooltipTitle       = "Mortes"
                info.tooltipText        = "Desmarque essa opção para não receber mais as mensagens do tipo \"[Fulano] matou [Ciclano] com [spell].\""
                info.checked            = BOOTYBAY.dbConfig.MostrarMortes
                info.arg1               = "MostrarMortes"
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- MOSTRAR RESULTADOS DE BG
                info.func               = self.funcBool
                info.text               = "Mostrar Resultado de BG (chat)"
                info.tooltipTitle       = "Resultado de BG"
                info.tooltipText        = "Desmarque essa opção para não receber mais as mensagens do tipo \"Fulano ganhou uma BG.\""
                info.checked            = BOOTYBAY.dbConfig.MostrarResultadoBGs
                info.arg1               = "MostrarResultadoBGs"
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- MOSTRAR KILL DA BLACKLIST
                info.func               = self.funcBool
                info.text               = "Mostrar Kills da Blacklist (chat)"
                info.tooltipTitle       = "Blacklist"
                info.tooltipText        = "Desmarque essa opção para não receber mais as mensagens do tipo \"Fulano matou um nome da blacklist: Ciclano.\""
                info.checked            = BOOTYBAY.dbConfig.MostrarKillBlacklist
                info.arg1               = "MostrarKillBlacklist"
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- MOSTRAR MSG AGUARDANDO RESS
                info.func               = self.funcBool
                info.text               = "Mostrar Aviso de Ress em BG (chat)"
                info.tooltipTitle       = "Ress"
                info.tooltipText        = "Desmarque essa opção para não receber mais as mensagens do tipo \"Fulano irá nascer em Cemiterio em 10seg.\""
                info.checked            = BOOTYBAY.dbConfig.MostrarAvisoRess
                info.arg1               = "MostrarAvisoRess"
                UIDropDownMenu_AddButton(info, level)
        elseif menuList == 12 then  -- MENULIST COM AS OPÇÕES DO GUILD MASTER
            local info                  = UIDropDownMenu_CreateInfo() -- RANK DE OFFICERS
                info.func               = self.funcGMNum
                info.text               = "Officers"
                info.menuList           = 13
                info.hasArrow           = true
                info.tooltipTitle       = "Officers"
                info.tooltipText        = "Marque o MENOR ranking da sua guild que o addon deve considerar como officers.\nOfficers podem adicionar e remover players na blacklist"
                UIDropDownMenu_AddButton(info, level)
        elseif menuList == 13 then  -- RANKING DE OFFICERS
            for i = 1,GuildControlGetNumRanks(),1 do
                local info              = UIDropDownMenu_CreateInfo()
                    info.text           = (i-1).." - "..GuildControlGetRankName(i)
                    info.arg1           = "Officer"
                    info.arg2           = i-1
                    info.func           = self.funcGMNum
                    if i-1 == BOOTYBAY.dbChar.Officer then info.checked = true end
                    UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList == 14 then  -- MENULIST COM OPÇÕES DE TOOLTIP
            local info                  = UIDropDownMenu_CreateInfo() -- TOOLTIP RENAMES
                info.text               = "Rename"
                info.tooltipTitle       = "Rename"
                info.tooltipText        = "Mostra os nicks antigos do player na sua tooltip."
                info.func               = self.funcBool
                info.arg1               = "RenameTooltip"
                info.checked            = BOOTYBAY.dbConfig.RenameTooltip
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- BG
                info.func               = self.funcBool
                info.text               = "Score de BG"
                info.tooltipTitle       = "Score BG"
                info.tooltipText        = "Mostra o score de BG do player na tooltip dele"
                info.checked            = BOOTYBAY.dbConfig.ScoreTooltipBG
                info.arg1               = "ScoreTooltipBG"
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- ALIADO
                info.func               = self.funcBool
                info.text               = "Score de BG com você"
                info.tooltipTitle       = "BG Junto"
                info.tooltipText        = "Mostra a quantia e o WR das suas bgs juntos com o player, na tooltip dele"
                info.checked            = BOOTYBAY.dbConfig.ScoreTooltipAliado
                info.arg1               = "ScoreTooltipAliado"
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- CONTRA
                info.func               = self.funcBool
                info.text               = "Score de BG contra"
                info.tooltipTitle       = "BG Contra"
                info.tooltipText        = "Mostra a quantia e o WR das suas bgs contra o player, na tooltip dele"
                info.checked            = BOOTYBAY.dbConfig.ScoreTooltipContra
                info.arg1               = "ScoreTooltipContra"
                UIDropDownMenu_AddButton(info, level)
        elseif menuList == 15 then  -- MENULIST COM AS OPÇÕES DOS FILTROS
            local info                  = UIDropDownMenu_CreateInfo() -- Filtro de Ninja Geral
                info.func               = self.funcBool
                info.checked            = BOOTYBAY.dbConfig.FiltroNinja
                info.keepShownOnClick   = true
                info.text               = "AntiNinja"
                info.arg1               = "FiltroNinja"
                info.tooltipTitle       = "AntiNinja"
                info.tooltipText        = "Essa opção irá filtrar aquelas mensagens de aviso que o sistema AntiNinja está ativado, desativado, etc."
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- Filtro de Ninja BG
                info.func               = self.funcBool
                info.disabled           = BOOTYBAY.dbConfig.FiltroNinja
                info.checked            = BOOTYBAY.dbConfig.FiltroNinjaBG or BOOTYBAY.dbConfig.FiltroNinja
                info.keepShownOnClick   = true
                info.text               = "AntiNinja em BGs"
                info.arg1               = "FiltroNinjaBG"
                info.tooltipTitle       = "AntiNinja em BG"
                info.tooltipText        = "Essa opção irá filtrar aquelas mensagens de aviso que o sistema AntiNinja está ativado, desativado, etc, que aparecerem enquanto você estiver dentro de uma BG."
                UIDropDownMenu_AddButton(info, level)   
            local info                  = UIDropDownMenu_CreateInfo() -- Filtro da LojaVip
                info.func               = self.funcBool
                info.checked            = BOOTYBAY.dbConfig.FiltroLojaUI
                info.keepShownOnClick   = true
                info.text               = "LojaVip"
                info.arg1               = "FiltroLojaUI"
                info.tooltipTitle       = "LojaVip"
                info.tooltipText        = "Essa opção irá filtrar aquela mensagem sobre a LojaVip que aparece no meio da tela ao logar o personagem"
                UIDropDownMenu_AddButton(info, level)
        elseif menuList == 16 then -- MENULIST COM OPÇÕES DE NAMEPLATE
            local info                  = UIDropDownMenu_CreateInfo() -- HEAL
                info.text               = "Healer"
                info.tooltipTitle       = "Healers"
                info.tooltipText        = "Coloca uma marcação no nameplate de qualquer healer."
                info.func               = self.funcBool
                info.arg1               = "NameplateHeal"
                info.checked            = BOOTYBAY.dbConfig.NameplateHeal
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- BLACKLIST
                info.text               = "Blacklist"
                info.tooltipTitle       = "Blacklist"
                info.tooltipText        = "Coloca uma marcação no nameplate de qualquer alvo da blacklist."
                info.func               = self.funcBool
                info.arg1               = "NameplateBL"
                info.checked            = BOOTYBAY.dbConfig.NameplateBL
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- EASTER EGG DHARKYN
                info.text               = "Easter egg (Dharkyn)"
                info.tooltipTitle       = "Dharkyn"
                info.tooltipText        = "Coloca uma marcação de healer no nameplate do nosso querido Dharkyn, o primeiro DK healer do WoW-Brasil."
                info.func               = self.funcBool
                info.arg1               = "NameplateDharkyn"
                info.checked            = BOOTYBAY.dbConfig.NameplateDharkyn
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- AJUSTES
                info.text               = "Ajustar Posição dos Icones"
                info.tooltipTitle       = "Ajuste de posição"
                info.tooltipText        = "Abre um controle para ajustar manualmente a posição dos icones na nameplate.\nUtilize essa opção caso você faça uso de algum addon que modifque o visual/tamanho das nameplates, como Tidyplates, e deseja que o icone fique alinhado corretamente."
                info.func = function() 
                    InterfaceOptionsFrame:Hide()
                    BOOTYBAY.FrameAjusteNameplate:Show()
                end
                UIDropDownMenu_AddButton(info, level)
        elseif menuList == 17 then  -- MENULIST COM OPÇÕES DE ITENS
            local info                  = UIDropDownMenu_CreateInfo() -- TOOLTIP GUILD BANK
                info.text               = "Estoque do GV na tooltip"
                info.tooltipTitle       = "Tooltip GV"
                info.tooltipText        = "Informa através da tooltip do item quantas unidades desse item existem no GV, essa informação é sincronizada com todos os usuarios."
                info.func               = self.funcBool
                info.arg1               = "GuildBankTooltip"
                info.checked            = BOOTYBAY.dbConfig.GuildBankTooltip
                UIDropDownMenu_AddButton(info, level)
            local info                  = UIDropDownMenu_CreateInfo() -- DATA E HORA NA TOOLTIP GUILD BANK
                info.disabled           = not BOOTYBAY.dbConfig.GuildBankTooltip
                info.text               = "Data e hora na tooltip"
                info.tooltipTitle       = "Data e Hora Tooltip"
                info.tooltipText        = "Informa através da tooltip do item o dia e o horario em que a informação da quantia foi extraida do GV, indicado para guilds com bastante movimentação no banco e com poucos membros usando o addon."
                info.func               = self.funcBool
                info.arg1               = "GuildBankTooltipData"
                info.checked            = BOOTYBAY.dbConfig.GuildBankTooltipData
                UIDropDownMenu_AddButton(info, level)
        end
    end
end, "MENU")

-- FUNÇÕES USADAS PELO MENU DE CONFIGURAÇÃO DO PAINEL 1
function BootybayPanel.config:funcBool(opt, db)
    if db == "char" then
        if BOOTYBAY.dbChar[opt] then
            BOOTYBAY.dbChar[opt] = false
        else
            BOOTYBAY.dbChar[opt] = true
        end
    else
        if BOOTYBAY.dbConfig[opt] then
            BOOTYBAY.dbConfig[opt] = false
        else
            BOOTYBAY.dbConfig[opt] = true
        end
    end
end
function BootybayPanel.config:funcNum(opt, valor)
    if (opt == "ScoreDescarte" or opt == "ScoreValidade") and valor ~= 0 then
        valor = 60*60*24*(valor-1)
    end
    BOOTYBAY.dbConfig[opt] = valor
end
function BootybayPanel.config:funcGMNum(opt, valor)
    BOOTYBAY.dbChar[opt]        = valor
    BOOTYBAY.dbControle[opt]    = time()
    local sendMessage           = strjoin(";",opt,tostring(valor),tostring(BOOTYBAY.dbControle[opt]))
    ChatThrottleLib:SendAddonMessage("ALERT", "BBSCCN", sendMessage, "GUILD")
end

-- MENU DE ESCOLHA DO RANKING DO PAINEL 2
UIDropDownMenu_Initialize(Bootybay2.ranking, function(self, level, menuList)
    local info      = UIDropDownMenu_CreateInfo()
        info.text   = "Total BG"
        info.arg1   = "score"
        info.arg2   = "totalBG"
        info.func   = self.Ranqueamento
        UIDropDownMenu_AddButton(info, level)
    local info      = UIDropDownMenu_CreateInfo()
        info.text   = "Winrate em BG"
        info.arg1   = "score"
        info.arg2   = "winrate"
        info.func   = self.Ranqueamento
        UIDropDownMenu_AddButton(info, level)
    local info      = UIDropDownMenu_CreateInfo()
        info.text   = "Total Kill"
        info.arg1   = "score"
        info.arg2   = "totalKill"
        info.func   = self.Ranqueamento
        UIDropDownMenu_AddButton(info, level)
    local info      = UIDropDownMenu_CreateInfo()
        info.text   = "Killstreak"
        info.arg1   = "rank"
        info.arg2   = "killstreak"
        info.func   = self.Ranqueamento
        UIDropDownMenu_AddButton(info, level)
    local info      = UIDropDownMenu_CreateInfo()
        info.text   = "Winstreak Solo/Duo"
        info.arg1   = "rank"
        info.arg2   = "winstreakSolo"
        info.func   = self.Ranqueamento
        UIDropDownMenu_AddButton(info, level)
    local info      = UIDropDownMenu_CreateInfo()
        info.text   = "Winstreak Grupo"
        info.arg1   = "rank"
        info.arg2   = "winstreakGrupo"
        info.func   = self.Ranqueamento
        UIDropDownMenu_AddButton(info, level)
    local info      = UIDropDownMenu_CreateInfo()
        info.text   = "Blacklist kills"
        info.arg1   = "rank"
        info.arg2   = "blacklistkills"
        info.func   = self.Ranqueamento
        UIDropDownMenu_AddButton(info, level)
    local info      = UIDropDownMenu_CreateInfo()
        info.text   = "Kills diarias"
        info.arg1   = "rank"
        info.arg2   = "killsdia"
        info.func   = self.Ranqueamento
        UIDropDownMenu_AddButton(info, level)
    local info      = UIDropDownMenu_CreateInfo()
        info.text   = "Max Kill em uma BG"
        info.arg1   = "rank"
        info.arg2   = "killbg"
        info.func   = self.Ranqueamento
        UIDropDownMenu_AddButton(info, level)
    local info      = UIDropDownMenu_CreateInfo()
        info.text   = "Maior dmg done em uma BG"
        info.arg1   = "rank"
        info.arg2   = "dmg"
        info.func   = self.Ranqueamento
        UIDropDownMenu_AddButton(info, level)
    local info      = UIDropDownMenu_CreateInfo()
        info.text   = "Maior heal done em uma BG"
        info.arg1   = "rank"
        info.arg2   = "heal"
        info.func   = self.Ranqueamento
        UIDropDownMenu_AddButton(info, level)
end)

-- RANKING
do
local ranking_nomes     = {}
local ranking_valores   = {}

local NumeroDeLinhas    = 9
local AlturaDasLinhas   = 20
local ComprimentoDasLinhas = 160
local Linha_Nomes       = {}
local Linha_Valores     = {}

for i=1, NumeroDeLinhas do
    ranking_nomes[i]    = ""
    ranking_valores[i]  = ""
end

local function ranking_Update(self)
    local numItems = #ranking_nomes
    FauxScrollFrame_Update(self, numItems, NumeroDeLinhas, AlturaDasLinhas)
    local offset = FauxScrollFrame_GetOffset(self)
    for linha = 1, NumeroDeLinhas do
        local linhaplusoffset = linha + offset
        local Linha_Nome = Linha_Nomes[linha]
        local Linha_Valor = Linha_Valores[linha]
        if linhaplusoffset <= numItems then
            Linha_Nome:SetText(ranking_nomes[linhaplusoffset])
            Linha_Nome:Show()
            Linha_Valor:SetText(ranking_valores[linhaplusoffset])
            Linha_Valor:Show()
        else
            Linha_Nome:Hide()
            Linha_Valor:Hide()
        end
    end
end

local ScrollFrame = CreateFrame("ScrollFrame", "RankingScrollFrame", Bootybay2, "FauxScrollFrameTemplate")
    RankingScrollFrameScrollBar:Hide()
    ScrollFrame:SetWidth(20)
    ScrollFrame:SetHeight(NumeroDeLinhas * AlturaDasLinhas)
    ScrollFrame:SetPoint("CENTER", -100, -100)
    ScrollFrame:EnableMouseWheel(1)
    ScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, AlturaDasLinhas, ranking_Update)
    end)


local ScrollFrame2 = CreateFrame("ScrollFrame", "RankingScrollFrame2", ScrollFrame, "FauxScrollFrameTemplate")
    ScrollFrame2:SetWidth(ComprimentoDasLinhas*1.5)
    ScrollFrame2:SetHeight(NumeroDeLinhas * AlturaDasLinhas)
    ScrollFrame2:SetPoint("LEFT", 0, 0)
    ScrollFrame2:EnableMouseWheel(1)
    ScrollFrame2:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, AlturaDasLinhas, ranking_Update)
    end)

local Bordas = CreateFrame("Frame", nil, Bootybay2)
    Bordas:SetWidth(ScrollFrame2:GetWidth() + 15)
    Bordas:SetHeight(ScrollFrame2:GetHeight() + 25)
    Bordas:SetPoint("BOTTOM",10,12)
    Bordas:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile     = true,
        tileSize = 10,
        edgeSize = 30,
        insets   = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    Bordas:SetBackdropColor(0, 0, 0, 0)

local Linha_NomeText = ScrollFrame:CreateFontString(nil, nil, "GameFontNormal")
    Linha_NomeText:SetPoint("CENTER", 23, 115)
local Linha_NomeText2 = ScrollFrame:CreateFontString(nil, nil, "GameFontNormal")
    Linha_NomeText2:SetPoint("CENTER", 160, 115)


for i = 1, NumeroDeLinhas do
    local Linha_Nome = ScrollFrame:CreateFontString(nil, nil, "GameFontNormal")
    local Linha_Valor = ScrollFrame:CreateFontString(nil, nil, "GameFontNormal")
    if i == 1 then
        Linha_Nome:SetPoint("TOP", ScrollFrame)
        Linha_Valor:SetPoint("TOP", ScrollFrame2)
    else
        Linha_Nome:SetPoint("TOP", Linha_Nomes[i - 1], "BOTTOM")
        Linha_Valor:SetPoint("TOP", Linha_Valores[i - 1], "BOTTOM")
    end

    Linha_Nome:SetPoint("LEFT", 10, 0)
    Linha_Nome:SetSize(ComprimentoDasLinhas, AlturaDasLinhas)
    Linha_Nome:SetJustifyH("LEFT")
    Linha_Nome:SetText(ranking_nomes[i])
    Linha_Nomes[i] = Linha_Nome
    Linha_Valor:SetPoint("LEFT", 150, 0)
    Linha_Valor:SetSize(ComprimentoDasLinhas, AlturaDasLinhas)
    Linha_Valor:SetJustifyH("LEFT")
    Linha_Valor:SetText(ranking_valores[i])
    Linha_Valores[i] = Linha_Valor
end

function Bootybay2.ranking:Ranqueamento(tipo, valor)
    Linha_NomeText:SetText("Players:")
    ranking_nomes = table.wipe(ranking_nomes)
    ranking_valores = table.wipe(ranking_valores)
    local keys = {}
    local contagem = 0
    if tipo == "score" then 
        if valor == "totalBG" or valor == "totalKill" then
            if valor == "totalBG" then
                Linha_NomeText2:SetText("Total de BG")
            else
                Linha_NomeText2:SetText("Honorable Kill")
            end
            for k in pairs(BOOTYBAY.dbData.Score) do if BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, k) then table.insert(keys, k) end end
            table.sort(keys, function(a, b) return ((BOOTYBAY.dbData.Score[a][valor] or 0)  > (BOOTYBAY.dbData.Score[b][valor] or 0)) end)
            for _, k in ipairs(keys) do
                if contagem > 199 then break end
                contagem = contagem + 1
                ranking_nomes[#ranking_nomes+1] = string.format("%-3s %s", ""..(#ranking_nomes+1)..".",k)
                ranking_valores[#ranking_valores+1] = BOOTYBAY.dbData.Score[k][valor]
            end
        else
            Linha_NomeText2:SetText("Winrate em BG")
            for k in pairs(BOOTYBAY.dbData.Score) do if BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, k) and BOOTYBAY.dbData.Score[k]["totalBG"] >= 50 then table.insert(keys, k) end end
            table.sort(keys, function(a, b) return (((BOOTYBAY.dbData.Score[a]["vitoriasBG"] or 0) / (BOOTYBAY.dbData.Score[a]["totalBG"] or 0)) > (((BOOTYBAY.dbData.Score[b]["vitoriasBG"] or 0) / (BOOTYBAY.dbData.Score[b]["totalBG"] or 1)))) end)
            for _, k in ipairs(keys) do
                if contagem > 199 then break end
                contagem = contagem + 1
                ranking_nomes[#ranking_nomes+1] = string.format("%-3s %s", ""..(#ranking_nomes+1)..".",k)
                ranking_valores[#ranking_valores+1] = BOOTYBAY.Fn_Arredondamento((BOOTYBAY.dbData.Score[k]["vitoriasBG"] / BOOTYBAY.dbData.Score[k]["totalBG"])*100,2).."%"
            end
        end
    elseif tipo == "rank" then
        if valor == "killstreak" then
            Linha_NomeText2:SetText("Maior Killstreak")
        elseif valor == "winstreakSolo" then
            Linha_NomeText2:SetText("Winstreak Solo/Duo")
        elseif valor == "winstreakGrupo" then
            Linha_NomeText2:SetText("Winstreak Grupo")
        elseif valor == "blacklistkills" then
            Linha_NomeText2:SetText("Kills da Blacklist")
        elseif valor == "killsdia" then
            Linha_NomeText2:SetText("Kills Diárias")
        elseif valor == "killbg" then
            Linha_NomeText2:SetText("Max Kill BG")
        elseif valor == "dmg" then
            Linha_NomeText2:SetText("Max Dmg BG")
        elseif valor == "heal" then
            Linha_NomeText2:SetText("Max Heal BG")
        end
        
        for k in pairs(BOOTYBAY.dbChar.MembrosData) do table.insert(keys, k) end
        table.sort(keys, function(a, b) return (BOOTYBAY.dbChar.MembrosData[a][valor] > BOOTYBAY.dbChar.MembrosData[b][valor]) end)
        if valor == "dmg" or valor == "heal" then
            for _, k in ipairs(keys) do
                if contagem > 199 then break end
                contagem = contagem + 1
                ranking_nomes[#ranking_nomes+1] = string.format("%-3s %s", ""..(#ranking_nomes+1)..".",k)
                ranking_valores[#ranking_valores+1] = BOOTYBAY.Fn_AbreviarNumeros(BOOTYBAY.dbChar.MembrosData[k][valor])
            end
        else
            for _, k in ipairs(keys) do
                if contagem > 199 then break end
                contagem = contagem + 1
                ranking_nomes[#ranking_nomes+1] = string.format("%-3s %s", ""..(#ranking_nomes+1)..".",k)
                ranking_valores[#ranking_valores+1] = BOOTYBAY.dbChar.MembrosData[k][valor]
            end
        end
    end
    
    ranking_Update(ScrollFrame2)
end
end

-- FUNÇÕES USADAS NO MENU DE DROPDOWN EM PORTRAIT DE UNIT E NOME NO CHAT
local function AdicionarNaBlacklist(self)
    local name = self.value
    
    if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.Blacklist, name) then
        local id = time()
        BOOTYBAY.dbChar.Blacklist[name] = id
        ChatThrottleLib:SendAddonMessage("NORMAL","BBSCB", strjoin(";",name,tostring(id)), "GUILD")
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.BlacklistExcluidos, name) then
            BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbChar.BlacklistExcluidos, name)
        end
        print(name, "incluido na Blacklist com sucesso!")
    else 
        print(name, "já está na Blacklist, controle o seu ódio.")
    end
end
local function RemoverDaBlacklist(self)
    local name = self.value
    
    if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.Blacklist, name) then
        BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbChar.Blacklist, name)
        local id = time()
        BOOTYBAY.dbChar.BlacklistExcluidos[name] = id
        ChatThrottleLib:SendAddonMessage("NORMAL","BBSCE", strjoin(";",name,tostring(id)), "GUILD")
        print(name, "foi removido da Blacklist.")
    else 
        print(name, "não está na Blacklist")
    end
end
local function ConsultarScore(self)
    local WinrateBGRound
    
    if BOOTYBAY.dbData.Score[self.value]["vitoriasBG"] == 0 then 
        WinrateBGRound = 0
    else
        WinrateBGRound = (BOOTYBAY.Fn_Arredondamento(BOOTYBAY.dbData.Score[self.value]["vitoriasBG"] / BOOTYBAY.dbData.Score[self.value]["totalBG"], 2) * 100)
    end
    
    print("|cffFF6600Banco de dados da Bootybay Surfclub:")
    print("|cffFF6600Player: "..self.value)
    print("|cffFF6600Honorable Kills: "..BOOTYBAY.dbData.Score[self.value]["totalKill"].."")
    print("|cffFF6600Total BGs: "..BOOTYBAY.dbData.Score[self.value]["totalBG"]..", WR: "..WinrateBGRound.."%")
    
    if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.BgJunto, self.value) then
        local wr = BOOTYBAY.dbData.BgJunto[self.value]["vitoria"] / BOOTYBAY.dbData.BgJunto[self.value]["total"]
        if BOOTYBAY.dbData.BgJunto[self.value]["vitoria"] == 0 then
            wr = 0
        end
        local wrRound = BOOTYBAY.Fn_Arredondamento(wr, 2) * 100
        print("|cffFF6600Total juntos: "..BOOTYBAY.dbData.BgJunto[self.value]["total"].." WR: "..wrRound.."%")
    end
    
    if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.BgContra, self.value) then
        local wr = BOOTYBAY.dbData.BgContra[self.value]["vitoria"] / BOOTYBAY.dbData.BgContra[self.value]["total"]
        if BOOTYBAY.dbData.BgContra[self.value]["vitoria"] == 0 then
            wr = 0
        end
        local wrRound = BOOTYBAY.Fn_Arredondamento(wr, 2) * 100
        print("|cffFF6600Total contra: "..BOOTYBAY.dbData.BgContra[self.value]["total"].." WR: "..wrRound.."%")
    end
end
local function ConsultarQueue(self)
    ChatThrottleLib:SendAddonMessage("ALERT","BBSCI", "Queue", "WHISPER", self.value)
end
local function ResetarScore(self)
    BOOTYBAY.dbData.Score[self.value] = nil
end

-- DROPDOWN MENU DE PORTRAIT E NOME NO CHAT
local function IncluirOpcoesExtrasDropdown(_, tipo, unit, name)
    if (unit and not UnitIsPlayer(unit)) or tipo == "SELF" or tipo == "TEAM" or UIDROPDOWNMENU_MENU_LEVEL > 1 then return end
    
    local nome
    if tipo ~= "FRIEND" and tipo ~= "FRIEND_OFFLINE" then
        nome = UnitName(unit)
    else 
        nome = name
    end
    
    local info = UIDropDownMenu_CreateInfo()
        info.isTitle, info.notCheckable = true, true
        info.text = "Bootybay"
        UIDropDownMenu_AddButton(info)

    if unit and BOOTYBAY.PLAYER_RANK_GUILD <= BOOTYBAY.dbChar.Officer then
        if UnitIsEnemy(unit,"player") and not BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.Blacklist, nome) then
            info = UIDropDownMenu_CreateInfo()
            info.text = "++ BLACKLIST ++"
            info.colorCode = "|cffff0000"
            info.func, info.value = AdicionarNaBlacklist, nome
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info)
        end
        
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.Blacklist, nome) then
            info = UIDropDownMenu_CreateInfo()
            info.text = "Remover da Blacklist"
            info.func, info.value = RemoverDaBlacklist, nome
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info)
        end
    end

    if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.Score, nome) then
        info = UIDropDownMenu_CreateInfo()
        info.text = "Score"
        info.func, info.value = ConsultarScore, nome
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info)
        info = UIDropDownMenu_CreateInfo()
        info.text = "Resetar Score"
        info.func, info.value = ResetarScore, nome
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info)
    end
    
    if unit and UnitGUID(unit) then 
        if #BOOTYBAY.dbData.Guid[UnitGUID(unit)] > 1 then
            info = UIDropDownMenu_CreateInfo()
            info.text = "*Outros Nicks*"
            info.func = function()
                print("|cffFF6600Todos os nicks de "..nome.." na database do addon da Bootybay:")
                for k, v in pairs(BOOTYBAY.dbData.Guid[UnitGUID(unit)]) do
                    print("|cffFF6600"..k..": "..v)
                end
            end
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info)
        end
    end
    
    if tContains(BOOTYBAY.Usuarios, nome) then
        info = UIDropDownMenu_CreateInfo()
        info.text = "|cff00ccffQueue/BG|r"
        info.func, info.value = ConsultarQueue, nome
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info)
    end
end

-- EditBox para cadastrar itens de interesse da guild
do
-- Parent criado no inicio do arquivo para poder chamar :Show() pelo painel
    BootybayEditBoxParent:SetWidth(400)
    BootybayEditBoxParent:SetHeight(100)
    BootybayEditBoxParent:SetPoint("CENTER", 1, 1)
    BootybayEditBoxParent:SetFrameStrata('DIALOG')
    BootybayEditBoxParent:SetBackdrop(  
        {
            bgFile = [[Interface\Buttons\WHITE8x8]],
            insets = {left = 3, right = 3, top = 4, bottom = 3}
        })
        
    BootybayEditBoxParent:SetBackdropColor(0, 0, 0, 0.7)
    BootybayEditBoxParent:SetMovable(true)
    BootybayEditBoxParent:EnableMouse(true)
    BootybayEditBoxParent:RegisterForDrag("LeftButton")
    BootybayEditBoxParent:SetScript("OnDragStart", BootybayEditBoxParent.StartMoving)
    BootybayEditBoxParent:SetScript("OnDragStop", BootybayEditBoxParent.StopMovingOrSizing)
    BootybayEditBoxParent:Hide()

local TituloEditBox = BootybayEditBoxParent:CreateFontString(nil, nil, "GameFontHighlight")
    TituloEditBox:SetPoint("TOPLEFT", BootybayEditBoxParent, 0, 32)
    TituloEditBox:SetWidth(BootybayEditBoxParent:GetWidth())
    TituloEditBox:SetJustifyH("LEFT")
    TituloEditBox:SetText("|cffFF6600Informe o nome dos itens que a sua guild tem interesse, separados por \";\" \nexemplo: Runic Mana Potion;Fish Feast;Free Action Potion")

local BootybayEditBox = CreateFrame('EditBox', 'nItensBroadcastBox', BootybayEditBoxParent)
    BootybayEditBox:SetMultiLine(true)
    BootybayEditBox:SetPoint("CENTER", 25)
    BootybayEditBox:EnableMouse(true)
    BootybayEditBox:SetMaxLetters(99999)    
    BootybayEditBox:SetFont('Fonts\\ARIALN.ttf', 13, 'THINOUTLINE')
    BootybayEditBox:SetWidth(360)
    BootybayEditBox:SetHeight(100)
    BootybayEditBox:SetScript('OnEscapePressed', function() BootybayEditBoxParent:Hide() end)
    BootybayEditBox:SetScript('OnShow', function() table.sort(BOOTYBAY.dbChar.Itens) BootybayEditBox:SetText(table.concat(BOOTYBAY.dbChar.Itens,";")) end)

local BotaoOkEditBox = CreateFrame("Button", "BotaoEditBox", BootybayEditBoxParent, "UIPanelButtonTemplate")
    BotaoOkEditBox:SetPoint("BOTTOM", 0, -23)
    BotaoOkEditBox:SetWidth(115)
    BotaoOkEditBox:SetHeight(25)
    BotaoOkEditBox:SetText("Salvar")
    BotaoOkEditBox:SetScript("OnClick", function(self)
        BOOTYBAY.dbChar.Itens = {
            strsplit(";",BootybayEditBox:GetText())
        }
        BootybayEditBoxParent:Hide()
        InterfaceOptionsFrame_OpenToCategory(Bootybay3)
        BOOTYBAY.dbControle.Itens = BOOTYBAY.dbControle.Itens + 1
        ChatThrottleLib:SendAddonMessage("ALERT", "BBSCIR", tostring(BOOTYBAY.dbControle.Itens), "GUILD")
end)

local BotaoFecharEditBox = CreateFrame("Button", "FecharEditBox", BootybayEditBoxParent, "UIPanelCloseButton")
    BotaoFecharEditBox:SetPoint("TOPRIGHT", 20, 30)
    BotaoFecharEditBox:SetWidth(40)
    BotaoFecharEditBox:SetHeight(40)
    BotaoFecharEditBox:SetScript("OnClick", function(self)
        BootybayEditBoxParent:Hide()
    end)

local ScrollEditBox = CreateFrame('ScrollFrame', 'nItensBroadcastScroll', BootybayEditBoxParent, 'UIPanelScrollFrameTemplate')
    ScrollEditBox:SetPoint('TOPLEFT', BootybayEditBoxParent, 'TOPLEFT', 0, -5) -- 8, 30
    ScrollEditBox:SetPoint('BOTTOMRIGHT', BootybayEditBoxParent, 'BOTTOMRIGHT', -10, 0) -- -30, 8
    ScrollEditBox:SetScrollChild(BootybayEditBox)
end

-- Popup Editbox para adicionar na Blacklist
StaticPopupDialogs["GRA_ADD"] = {
    text = "Adicionar nome na Blacklist da guild:",
    button1 = "Adicionar",
    button2 = "Cancelar",
    
    OnAccept = function (self, data, data2)
        local name = string.gsub(self.editBox:GetText(), "(%a)([%w_']*)", BOOTYBAY.Fn_PadronizarNome)
        
        if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.Blacklist, name) then
            local id = time()
            BOOTYBAY.dbChar.Blacklist[name] = id
            ChatThrottleLib:SendAddonMessage("NORMAL","BBSCB", strjoin(";",name,tostring(id)), "GUILD")
            if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.BlacklistExcluidos, name) then
                BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbChar.BlacklistExcluidos, name)
            end
            print("|cffff00ff"..name..", incluido na Blacklist com sucesso!")
        else 
            print("|cffff00ff"..name..", já está na Blacklist, controle o seu ódio.")
        end
    end,
      
    OnShow = function (self, data, data2)
        local name = UnitName("target")
        if name then self.editBox:SetText(name) end
        if name ~= "" then
            self.button1:Enable()
        else
            self.button1:Disable()
        end
    end,
    
    OnHide = function (self) end,
    
    EditBoxOnTextChanged = function (self)
        local parent = self:GetParent()
        local name = parent.editBox:GetText()
        if name ~= "" then
            parent.button1:Enable()
        else
            parent.button1:Disable()
        end
    end,
    
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}

-- Popup Editbox para remover da Blacklist
StaticPopupDialogs["GRA_REMOVE"] = {
    text = "Remover nome da Blacklist:",
    button1 = "Remover",
    button2 = "Cancelar",
    OnAccept = function (self, data, data2)
        local name = string.gsub(self.editBox:GetText(), "(%a)([%w_']*)", BOOTYBAY.Fn_PadronizarNome)
    
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.Blacklist, name) then
            BOOTYBAY.Fn_RemoverChave(BOOTYBAY.dbChar.Blacklist, name)
            local id = time()
            BOOTYBAY.dbChar.BlacklistExcluidos[name] = id
            ChatThrottleLib:SendAddonMessage("NORMAL","BBSCE", strjoin(";",name,tostring(id)), "GUILD")
            print("|cffff00ff"..name..", foi removido da Blacklist.")
        else 
            print("|cffff00ff"..name..", não está na Blacklist")
        end
    end,
      
    OnShow = function (self, data, data2)
        local name = UnitName("target")
        if name then self.editBox:SetText(name) end
        if name ~= "" then
           self.button1:Enable()
        else
           self.button1:Disable()
        end
    end,
    
    OnHide = function (self) end,
    
    EditBoxOnTextChanged = function (self)
        local parent = self:GetParent()
        local name = parent.editBox:GetText()
        if name ~= "" then
           parent.button1:Enable()
        else
           parent.button1:Disable()
        end
    end,
      
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}

-- Frame de ajuste dos nameplates
BOOTYBAY.FrameAjusteNameplate = CreateFrame("Button", nil, UIParent, "UIPanelCloseButton")
do
BOOTYBAY.FrameAjusteNameplate.Text = BOOTYBAY.FrameAjusteNameplate:CreateFontString(nil, nil, "GameFontNormalLarge")
    BOOTYBAY.FrameAjusteNameplate.Text:SetPoint("CENTER", 0, 55)
    BOOTYBAY.FrameAjusteNameplate.Text:SetText("Ajuste a posição no nameplate")
    BOOTYBAY.FrameAjusteNameplate:SetPoint("CENTER",0,1)
    BOOTYBAY.FrameAjusteNameplate:SetMovable(true)
    BOOTYBAY.FrameAjusteNameplate:RegisterForDrag("LeftButton")
    BOOTYBAY.FrameAjusteNameplate:SetScript("OnDragStart", BOOTYBAY.FrameAjusteNameplate.StartMoving)
    BOOTYBAY.FrameAjusteNameplate:SetScript("OnDragStop", BOOTYBAY.FrameAjusteNameplate.StopMovingOrSizing)
    BOOTYBAY.FrameAjusteNameplate:SetScript("OnClick", function(self)
        self:Hide()
    end)

BOOTYBAY.FrameAjusteNameplate.Cima = CreateFrame("Button", nil, BOOTYBAY.FrameAjusteNameplate, "UIPanelButtonTemplate")
    BOOTYBAY.FrameAjusteNameplate.Cima:SetPoint("CENTER", 0, 30)
    BOOTYBAY.FrameAjusteNameplate.Cima:SetHeight(25)
    BOOTYBAY.FrameAjusteNameplate.Cima:SetWidth(35)
    BOOTYBAY.FrameAjusteNameplate.Cima:SetText("Subir")
    BOOTYBAY.FrameAjusteNameplate.Cima:SetScript("OnClick", function(self)
        BOOTYBAY.dbConfig.Icone_Y = BOOTYBAY.dbConfig.Icone_Y + 1
    end)
BOOTYBAY.FrameAjusteNameplate.Baixo = CreateFrame("Button", nil, BOOTYBAY.FrameAjusteNameplate, "UIPanelButtonTemplate")
    BOOTYBAY.FrameAjusteNameplate.Baixo:SetPoint("CENTER", 0, -30)
    BOOTYBAY.FrameAjusteNameplate.Baixo:SetHeight(25)
    BOOTYBAY.FrameAjusteNameplate.Baixo:SetWidth(35)
    BOOTYBAY.FrameAjusteNameplate.Baixo:SetText("Descer")
    BOOTYBAY.FrameAjusteNameplate.Baixo:SetScript("OnClick", function(self)
        BOOTYBAY.dbConfig.Icone_Y = BOOTYBAY.dbConfig.Icone_Y - 1
    end)
BOOTYBAY.FrameAjusteNameplate.Esquerda = CreateFrame("Button", nil, BOOTYBAY.FrameAjusteNameplate, "UIPanelButtonTemplate")
    BOOTYBAY.FrameAjusteNameplate.Esquerda:SetPoint("CENTER", -30, 0)
    BOOTYBAY.FrameAjusteNameplate.Esquerda:SetHeight(25)
    BOOTYBAY.FrameAjusteNameplate.Esquerda:SetWidth(25)
    BOOTYBAY.FrameAjusteNameplate.Esquerda:SetText("<<")
    BOOTYBAY.FrameAjusteNameplate.Esquerda:SetScript("OnClick", function(self)
        BOOTYBAY.dbConfig.Icone_X = BOOTYBAY.dbConfig.Icone_X - 1
    end)
BOOTYBAY.FrameAjusteNameplate.Direita = CreateFrame("Button", nil, BOOTYBAY.FrameAjusteNameplate, "UIPanelButtonTemplate")
    BOOTYBAY.FrameAjusteNameplate.Direita:SetPoint("CENTER", 30, 0)
    BOOTYBAY.FrameAjusteNameplate.Direita:SetHeight(25)
    BOOTYBAY.FrameAjusteNameplate.Direita:SetWidth(25)
    BOOTYBAY.FrameAjusteNameplate.Direita:SetText(">>")
    BOOTYBAY.FrameAjusteNameplate.Direita:SetScript("OnClick", function(self)
        BOOTYBAY.dbConfig.Icone_X = BOOTYBAY.dbConfig.Icone_X + 1
    end)

BOOTYBAY.FrameAjusteNameplate:Hide()
end

hooksecurefunc("UnitPopup_ShowMenu", IncluirOpcoesExtrasDropdown)