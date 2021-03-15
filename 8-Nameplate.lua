local Recovery, BOOTYBAY    = ...
local Bootybay              = BOOTYBAY.events

local BootybayTimer         = CreateFrame("Frame")
BootybayTimer.Intervalo     = 0

local select                = _G.select


function BOOTYBAY:MarcarNameplate(frame)

-- NOTA PESSOAL: EU ODEIO O TIDY PLATES E SUAS 500 VERSÕES COM TODAS AS MINHAS FORÇAS!

    local _, _, _, _, _, _, oldname, level, _, _, _ = frame:GetRegions()
    local name 
    if oldname then 
        name = oldname:GetText()
    else 
        if  TidyPlates and frame.extended then  -- TidyPlates desaparece com as regions originais do nameplate da blizzard
            name = frame.extended.unit.name 
        end
    end

    if frame.gra then frame.gra:Hide() end

    if (tContains(BOOTYBAY.Healers, name) and BOOTYBAY.dbConfig.NameplateHeal) or (name == "Dharkyn" and BOOTYBAY.dbConfig.NameplateDharkyn) then -- HEALERS E DHARKYN
        if level then
            level:Hide()
        else 
            if TidyPlates and frame.extended.regions.levelText then -- tidy desaparece com o level original, e usa um outro, então temos que esconder esse também
                frame.extended.regions.levelText:Hide() 
            end
        end
        
        if not frame.gra then 
            frame.gra = frame:CreateTexture(nil, "OVERLAY")
            frame.gra.tipo = "heal"
            frame.gra:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-ROLES")
            frame.gra:SetTexCoord(0.26171875, 0.5234375, 0, 0.26171875)
            if TidyPlates and frame.extended then -- frame.extended é onde o tidyplates jogou as informações que ele usa pra substituir as originais que estão desaparecidas
                if frame.extended.visual then -- tidy versão "neon" usa uma tabela chamada "visual" para colocar a barra de hp
                    frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.visual.healthborder,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 15,BOOTYBAY.dbConfig.Icone_Y - 10)
                else -- tidy versão "clean" usa uma tabela chamada "bars" para colocar a barra de hp
                    frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.bars.health,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 24,BOOTYBAY.dbConfig.Icone_Y + 4)
                end
            else
                frame.gra:SetPoint("BOTTOMRIGHT",BOOTYBAY.dbConfig.Icone_X,BOOTYBAY.dbConfig.Icone_Y)
            end
            frame.gra:SetWidth(30)
            frame.gra:SetHeight(30)
            frame.gra:Show()
        else
            if frame.gra.tipo == "heal" then
                if TidyPlates and frame.extended then 
                    if frame.extended.visual then
                        frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.visual.healthborder,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 15,BOOTYBAY.dbConfig.Icone_Y - 10)
                    else
                        frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.bars.health,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 24,BOOTYBAY.dbConfig.Icone_Y + 4)
                    end
                else
                    frame.gra:SetPoint("BOTTOMRIGHT",BOOTYBAY.dbConfig.Icone_X,BOOTYBAY.dbConfig.Icone_Y)
                end
                frame.gra:Show()
            else
                frame.gra.tipo = "heal"
                frame.gra:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-ROLES")
                frame.gra:SetTexCoord(0.26171875, 0.5234375, 0, 0.26171875)
                if TidyPlates and frame.extended then 
                    if frame.extended.visual then
                        frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.visual.healthborder,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 15,BOOTYBAY.dbConfig.Icone_Y - 10)
                    else
                        frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.bars.health,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 24,BOOTYBAY.dbConfig.Icone_Y + 4)
                    end
                else
                    frame.gra:SetPoint("BOTTOMRIGHT",BOOTYBAY.dbConfig.Icone_X,BOOTYBAY.dbConfig.Icone_Y)
                end
                frame.gra:SetWidth(30)
                frame.gra:SetHeight(30)
                frame.gra:Show()
            end
        end
    elseif BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.Blacklist, name) and BOOTYBAY.dbConfig.NameplateBL then -- BLACKLIST
        if level then 
            level:Hide()
        else 
            if TidyPlates and frame.extended.regions.levelText then 
                frame.extended.regions.levelText:Hide() 
            end
        end
        if not frame.gra then
            frame.gra = frame:CreateTexture(nil, "OVERLAY")
            frame.gra.tipo = "bl"
            frame.gra:SetTexture("Interface\\ICONS\\Achievement_Dungeon_Naxxramas")
            frame.gra:SetTexCoord(0,1,0,1)
            if TidyPlates and frame.extended then 
                if frame.extended.visual then
                    frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.visual.healthborder,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 13,BOOTYBAY.dbConfig.Icone_Y - 8)
                else
                    frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.bars.health,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 22,BOOTYBAY.dbConfig.Icone_Y + 6)
                end
            else
                frame.gra:SetPoint("BOTTOMRIGHT",BOOTYBAY.dbConfig.Icone_X - 2,BOOTYBAY.dbConfig.Icone_Y + 2)
            end
            frame.gra:SetWidth(27)
            frame.gra:SetHeight(27)
            frame.gra:Show()
        else
            if frame.gra.tipo == "bl" then
                if TidyPlates and frame.extended then 
                    if frame.extended.visual then
                        frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.visual.healthborder,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 13,BOOTYBAY.dbConfig.Icone_Y - 8)
                    else
                        frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.bars.health,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 22,BOOTYBAY.dbConfig.Icone_Y + 6)
                    end
                else
                    frame.gra:SetPoint("BOTTOMRIGHT",BOOTYBAY.dbConfig.Icone_X - 2,BOOTYBAY.dbConfig.Icone_Y + 2)
                end
                frame.gra:Show()
            else
                frame.gra.tipo = "bl"
                frame.gra:SetTexture("Interface\\ICONS\\Achievement_Dungeon_Naxxramas")
                frame.gra:SetTexCoord(0,1,0,1)
                if TidyPlates and frame.extended then 
                    if frame.extended.visual then
                        frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.visual.healthborder,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 13,BOOTYBAY.dbConfig.Icone_Y - 8)
                    else
                        frame.gra:SetPoint("BOTTOMRIGHT",frame.extended.bars.health,"RIGHT",BOOTYBAY.dbConfig.Icone_X + 22,BOOTYBAY.dbConfig.Icone_Y + 6)
                    end
                else
                    frame.gra:SetPoint("BOTTOMRIGHT",BOOTYBAY.dbConfig.Icone_X - 2,BOOTYBAY.dbConfig.Icone_Y + 2)
                end
                frame.gra:SetWidth(27)
                frame.gra:SetHeight(27)
                frame.gra:Show()
            end
        end
    else 
        if oldname and oldname:IsVisible() then -- pra não conflitar com o addon TotemPlates
            level:Show()
        end
    end
end

function BOOTYBAY:EncontrarNameplates(...)
   for i = 1, select('#', ...) do
        local frame = select(i, ...)
        local region = frame:GetRegions()
        -- frame.extended é do TidyPlates
        if (not frame:GetName() and region and region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\TargetingFrame\\UI-TargetingFrame-Flash") or (frame.extended and frame.extended.unit) then
            BOOTYBAY:MarcarNameplate(frame)
        end
   end
end

BootybayTimer:SetScript("OnUpdate", function(self, elapsed)
    BootybayTimer.Intervalo = BootybayTimer.Intervalo + elapsed
    if BootybayTimer.Intervalo >= 0.6 then
        BOOTYBAY:EncontrarNameplates(WorldFrame:GetChildren())
    end
end)

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