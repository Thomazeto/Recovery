local Recovery, BOOTYBAY    = ...
local Bootybay              = BOOTYBAY.events

SLASH_GRA1                  = '/GRA'

local function ComandosBootybay(cmd,self)
    local _, _, msg, args = string.find(cmd, "%s?(%w+)%s?(.*)")
    
    if msg == "vers" then
        ChatThrottleLib:SendAddonMessage("ALERT","GRACHECK", "vers", "GUILD");
        if BOOTYBAY.Bool_PlayerEmBG then
            ChatThrottleLib:SendAddonMessage("ALERT","GRACHECK", "vers", "BATTLEGROUND")
        else
            if GetRealNumRaidMembers ~= 0 then
                ChatThrottleLib:SendAddonMessage("ALERT","GRACHECK", "vers", "RAID")
            elseif GetRealNumPartyMembers ~= 0 then
                ChatThrottleLib:SendAddonMessage("ALERT","GRACHECK", "vers", "PARTY")
            end
        end
    elseif cmd == "auc" then -- Reseta o historico de preços do Auctionator
        AUCTIONATOR_PRICE_DATABASE = {}
        AUCTIONATOR_PRICING_HISTORY = {}
        print("|cffff00ffBootybay: Database do Auctionator foi resetada!")
    elseif cmd == "bg" then
        BOOTYBAY:AcessarInfoQueue(BOOTYBAY.NOME_PLAYER)
    elseif (cmd == "premades" or cmd == "p") then
        if BOOTYBAY.MapaNoRadar == 0 then
            print("|cffFFFF55Premades ativas no Radar Bootybay:")
            for g, t in pairs(BOOTYBAY.PremadesOld) do
                for z, p in pairs(BOOTYBAY.PremadesOld[g]) do
                    if BOOTYBAY.GuildFactionRadar[g] == 1 then
                        print("|cff2369cc"..g.."|r |cffFFFF55em "..z.." com "..BOOTYBAY.PremadesAtual[g][z].." players|r")
                    else
                        print("|cFFFF0000"..g.."|r |cffFFFF55em "..z.." com "..BOOTYBAY.PremadesAtual[g][z].." players|r")
                    end
                end
            end
        else
            print("|cffFFFF55Radar sendo executado neste momento! aguarde a conclusão e solicite o comando novamente.")
        end
    elseif cmd == "blacklist add" then
        if BOOTYBAY.PLAYER_RANK_GUILD <= BOOTYBAY.dbChar.Officer then
            StaticPopup_Show ("GRA_ADD")
        end
    elseif cmd == "blacklist remove" then
        if BOOTYBAY.PLAYER_RANK_GUILD <= BOOTYBAY.dbChar.Officer then
            StaticPopup_Show ("GRA_REMOVE")
        end
    elseif cmd == "blacklist show" then
        local temp = {}
        for k, v in pairs(BOOTYBAY.dbChar.Blacklist) do
            table.insert(temp, k)
        end
        table.sort(temp)
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF6600Players na Blacklist da guild:");
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF6600"..table.concat(temp,", ").."");
    elseif cmd == "checkw" then
        for i = 1, GetNumWhoResults() do
            local n = GetWhoInfo(i)
            ChatThrottleLib:SendAddonMessage("ALERT","GRACHECK", "informe", "WHISPER", ""..n.."")
        end
    elseif msg == "score" then
        local nick
        if args ~= "" then
            nick = string.gsub(args, "(%a)([%w_']*)", BOOTYBAY.Fn_PadronizarNome)
        else
            nick = tostring(UnitName("target"))
        end
        print("|cffFF6600----")
        print("|cffFF6600Banco de dados da Bootybay Surfclub:")
        print("|cffFF6600Player: "..nick)
        local WinrateBGRound
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.Score, nick) then
            if BOOTYBAY.dbData.Score[nick]["vitoriasBG"] == 0 then 
                WinrateBGRound = 0
            else
                local WinrateBG = BOOTYBAY.dbData.Score[nick]["vitoriasBG"] / BOOTYBAY.dbData.Score[nick]["totalBG"]
                WinrateBGRound = (BOOTYBAY.Fn_Arredondamento(WinrateBG, 2) * 100)
            end
            print("|cffFF6600Honorable Kills: "..BOOTYBAY.dbData.Score[nick]["totalKill"].."")
            print("|cffFF6600Total BGs: "..BOOTYBAY.dbData.Score[nick]["totalBG"]..", WR: "..WinrateBGRound.."%")
        end
            
        if nick == BOOTYBAY.NOME_PLAYER then    return end
            
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.BgJunto, nick) then
            local wr = BOOTYBAY.dbData.BgJunto[nick]["vitoria"] / BOOTYBAY.dbData.BgJunto[nick]["total"]
            if BOOTYBAY.dbData.BgJunto[nick]["vitoria"] == 0 then
                wr = 0
            end
            local wrRound = BOOTYBAY.Fn_Arredondamento(wr, 2) * 100
            print("|cffFF6600Total juntos: "..BOOTYBAY.dbData.BgJunto[nick]["total"]..", WR: "..wrRound.."%")
        end
        
        if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbData.BgContra, nick) then
            local wr = BOOTYBAY.dbData.BgContra[nick]["vitoria"] / BOOTYBAY.dbData.BgContra[nick]["total"]
            if BOOTYBAY.dbData.BgContra[nick]["vitoria"] == 0 then
                wr = 0
            end
            local wrRound = BOOTYBAY.Fn_Arredondamento(wr, 2) * 100
            print("|cffFF6600Total contra: "..BOOTYBAY.dbData.BgContra[nick]["total"]..", WR: "..wrRound.."%")
        end
    elseif msg == "rank" then
        InterfaceOptionsFrame_OpenToCategory(Bootybay2)
    elseif msg == "gm" then
        InterfaceOptionsFrame_OpenToCategory(Bootybay3)
    else
        InterfaceOptionsFrame_OpenToCategory(BootybayPanel)
    end
end

-- Editbox para adicionar na Blacklist
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

-- Editbox para remover da Blacklist
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


SlashCmdList["GRA"] = ComandosBootybay