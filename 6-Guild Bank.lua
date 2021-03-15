local Recovery, BOOTYBAY    = ...
local Bootybay              = BOOTYBAY.events

local BootybayTimer         = CreateFrame("Frame")
BootybayTimer.TempoDaQuery  = 0

local Bool_AnalisarGV       = false

local select = _G.select

function Bootybay:GUILDBANKBAGSLOTS_CHANGED(...)
    if Bool_AnalisarGV == true then return end
        BOOTYBAY.dbChar.GuildBank = {}
        BOOTYBAY.dbChar.GuildBank["Gold"] = GetGuildBankMoney() / 100 / 100
    for tab = 1, 6 do
        for slot = 1, 98 do
            local link = GetGuildBankItemLink(tab,slot)
            if link then
                local name, count = GetItemInfo(link), select(2,GetGuildBankItemInfo(tab,slot))
                if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.GuildBank, name) then
                    BOOTYBAY.dbChar.GuildBank[name] = BOOTYBAY.dbChar.GuildBank[name] + count
                else
                    BOOTYBAY.dbChar.GuildBank[name] = count
                end
            end
        end
    end
    BOOTYBAY.dbControle.GuildBank = time()
    BOOTYBAY.dbControle.GuildBankData = date("%d/%m/%y as %H:%M")
    ChatThrottleLib:SendAddonMessage("ALERT", "BBSCGB", ""..tostring(BOOTYBAY.dbControle.GuildBank)..";"..BOOTYBAY.dbControle.GuildBankData.."", "GUILD")
end

function Bootybay:GUILDBANKFRAME_OPENED(...)
        for tab = 1, 6 do
            QueryGuildBankTab(tab)
        end
        Bool_AnalisarGV = true
end

BootybayTimer:SetScript("OnUpdate", function(self, elapsed)
    if Bool_AnalisarGV then
        BootybayTimer.TempoDaQuery = BootybayTimer.TempoDaQuery + elapsed
        if BootybayTimer.TempoDaQuery > 1.5 then
            Bool_AnalisarGV = false
            BootybayTimer.TempoDaQuery = 0
            Bootybay:GUILDBANKBAGSLOTS_CHANGED()
        end
    end
end)

local function AddItemTooltip(tooltip) 
    local itemName, itemLink = tooltip:GetItem()
    if not itemName or not itemLink then return end
        
    if tContains(BOOTYBAY.dbChar.Itens, itemName) then
        tooltip:AddLine("A "..BOOTYBAY.dbChar.NomeGuild.." tem interesse em ter esse item no nosso GV.",0,1,1,true)
    end 
    
    if BOOTYBAY.dbConfig.GuildBankTooltip then
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.GuildBank, itemName) then
            if BOOTYBAY.dbConfig.GuildBankTooltipData then
                tooltip:AddDoubleLine ("Guild Bank em "..BOOTYBAY.dbControle.GuildBankData..":", BOOTYBAY.dbChar.GuildBank[itemName].."  ")
            else
                tooltip:AddDoubleLine ("Guild Bank:", BOOTYBAY.dbChar.GuildBank[itemName].."  ")
            end
        end
    end
end

GameTooltip:HookScript("OnTooltipSetItem", AddItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", AddItemTooltip) -- Hyperlink