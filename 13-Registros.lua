local Recovery, BOOTYBAY = ...
local Bootybay           = BOOTYBAY.events

-- Registro dos eventos que possuem função para OnEvent
BOOTYBAY.frame:SetScript("OnEvent", function(self, event, ...)
    Bootybay[event](self, ...)
end)

for k, v in pairs(Bootybay) do
    BOOTYBAY.frame:RegisterEvent(k)
end