local Recovery, BOOTYBAY        = ...
local Bootybay                  = BOOTYBAY.events

local BootybayInspect           = CreateFrame("Frame")
local Bool_Inspectando          = false
local TempoUltimoInspect        = 0
local Nome                      = nil

local tonumber, tostring        = _G.tonumber, _G.tostring
local getStat, strjoin          = _G.GetComparisonStatistic, _G.strjoin


local function AddScoreTooltip(tooltip)
    local unitName, unit = tooltip:GetUnit()
    if not unitName or not unit then return end
    if not UnitIsPlayer(unit) then return end
    
    if unitName == "Unknown" then return end
    
    local guid = UnitGUID(unit)
    
    if guid then 
        BOOTYBAY:AtualizarGuid(unitName, guid, true)
    end
    
    if BOOTYBAY.dbConfig.ScoreTooltipBG then
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.Score, unitName) then
            local winrateBG
            local winrateBGRound
            
            if BOOTYBAY.dbData.Score[unitName]["vitoriasBG"] == 0 then 
                winrateBG, winrateBGRound = 0, 0
            else
                winrateBG = BOOTYBAY.dbData.Score[unitName]["vitoriasBG"] / BOOTYBAY.dbData.Score[unitName]["totalBG"]
                winrateBGRound = BOOTYBAY.Fn_Arredondamento(winrateBG, 2) * 100
            end
        
            if winrateBGRound > 100 then -- vi um score assim, mas não consegui identificar como ocorreu, então vamos remediar xD
                BOOTYBAY.dbData.Score[unitName] = nil
                return
            end
            
            tooltip:AddLine("Total Bg: "..BOOTYBAY.dbData.Score[unitName]["totalBG"].." Wr: "..winrateBGRound.."%",1,1,1,true)
        end
    end
    
    if not UnitIsEnemy("player", unit) and BOOTYBAY.dbConfig.ScoreTooltipAliado and unitName ~= BOOTYBAY.NOME_PLAYER then
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.BgJunto, unitName) then
            local wr = BOOTYBAY.dbData.BgJunto[unitName]["vitoria"] / BOOTYBAY.dbData.BgJunto[unitName]["total"]
            if BOOTYBAY.dbData.BgJunto[unitName]["vitoria"] == 0 then
                wr = 0
            end
            local wrRound = BOOTYBAY.Fn_Arredondamento(wr, 2) * 100
            tooltip:AddLine("Juntos: "..BOOTYBAY.dbData.BgJunto[unitName]["total"].." Wr: "..wrRound.."%",1,1,1,true)
        end
    end
    
    if UnitIsEnemy("player", unit) and BOOTYBAY.dbConfig.ScoreTooltipContra then
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.BgContra, unitName) then
            local wr = BOOTYBAY.dbData.BgContra[unitName]["vitoria"] / BOOTYBAY.dbData.BgContra[unitName]["total"]
            if BOOTYBAY.dbData.BgContra[unitName]["vitoria"] == 0 then
                wr = 0
            end
            local wrRound = BOOTYBAY.Fn_Arredondamento(wr, 2) * 100
            tooltip:AddLine("Contra: "..BOOTYBAY.dbData.BgContra[unitName]["total"].." Wr: "..wrRound.."%",1,1,1,true)
        end
    end
    
    if BOOTYBAY.dbConfig.RenameTooltip then
        if #BOOTYBAY.dbData.Guid[guid] > 1 then
            local tab = {}
            for k,v in pairs(BOOTYBAY.dbData.Guid[guid]) do
                if v ~= unitName then
                    tinsert(tab, v)
                end
            end
            tooltip:AddLine("Nomes antigos: "..table.concat(tab,", ").."",1,1,1,true)
        end
    end
    
    tooltip:Show() 
end

BootybayInspect:SetScript("OnEvent", function(self, event, ...)
    local Bool_TooltipPrecisaDeUpdate
    
    if not BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.Score, Nome) then
        BOOTYBAY.dbData.Score[Nome] = {}
        Bool_TooltipPrecisaDeUpdate = true
    end
    
    BOOTYBAY.dbData.Score[Nome] = {["totalBG"] = tonumber(getStat(839)) or 0, ["vitoriasBG"] = tonumber(getStat(840)) or 0, ["totalKill"] = tonumber(getStat(588)) or 0, ["data"] = BOOTYBAY.HORA_DO_LOGIN}
    
    if BOOTYBAY.Fn_ContemChave(BOOTYBAY.GuildMembers, Nome) then
        BOOTYBAY.dbData.Score[Nome]["guild"] = true
    end
    
    local sendMessage = strjoin(";", Nome, tostring(BOOTYBAY.dbData.Score[Nome]["totalKill"]), tostring(BOOTYBAY.dbData.Score[Nome]["totalBG"]), tostring(BOOTYBAY.dbData.Score[Nome]["vitoriasBG"]), tostring(BOOTYBAY.dbData.Score[Nome]["data"]))
    ChatThrottleLib:SendAddonMessage("BULK","GRASCORE", sendMessage, "GUILD")
    
    Bool_Inspectando = false
    
    if Bool_TooltipPrecisaDeUpdate then
        local tooltip = _G.GameTooltip
        if tooltip:GetUnit() == Nome then 
            AddScoreTooltip(tooltip)
        end
    end
    
    BootybayInspect:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")
    
    if (AchievementFrameComparison) then
        AchievementFrameComparison:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
    end
    
    TempoUltimoInspect = 0
end)

function Bootybay:UPDATE_MOUSEOVER_UNIT(...)
    if not BOOTYBAY.dbConfig.ScoreMouseover then return end
    if Bool_Inspectando == false then
        if not CanInspect("mouseover") or not CheckInteractDistance("mouseover", 1) then return end
        Nome = tostring(UnitName("mouseover"))
        if Nome == "Unknown" then return end
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.Score, Nome) then
            if (BOOTYBAY.HORA_DO_LOGIN - BOOTYBAY.dbData.Score[Nome]["data"]) <= BOOTYBAY.dbConfig.ScoreValidade then
                return 
            end
        end
    
        if (AchievementFrameComparison) then
            AchievementFrameComparison:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")
        end

        Bool_Inspectando = true
        TempoUltimoInspect = GetTime()
        
        BootybayInspect:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
        ClearAchievementComparisonUnit()
        SetAchievementComparisonUnit("mouseover")
    else
        if (GetTime() - TempoUltimoInspect) > 1 then
            TempoUltimoInspect = 0
            Nome = nil
            BootybayInspect:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")
            Bool_Inspectando = false
        end
    end
end


GameTooltip:HookScript("OnTooltipSetUnit", AddScoreTooltip)