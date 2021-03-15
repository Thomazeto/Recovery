local Recovery, BOOTYBAY                = ...
local Bootybay                          = BOOTYBAY.events

local tContains                         = tContains
local bit_band                          = bit.band
local bit_bor                           = bit.bor
local COMBATLOG_OBJECT_TYPE_PLAYER      = COMBATLOG_OBJECT_TYPE_PLAYER
local COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE
local HOSTILE_PLAYER                    = bit_bor(COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_CONTROL_PLAYER)

local Curas = 
{
    -- Pala Holy
    "Holy Shock", "Beacon of Light",
    -- Shaman Restor
    "Riptide", "Earth Shield",
    -- Priest Disc
    "Penance", "Borrowed Time",
    -- Priest Holy
    "Serendipity", "Body and Soul",
    -- Druida Restor
    "Tree of Life", "Wild Growth", "Swiftmend"
}

function Bootybay:COMBAT_LOG_EVENT_UNFILTERED(...)
    
    local _, subevent, _, sourceName, sourceFlags, destGUID, destName, destFlags, prefixParam1, prefixParam2, _, _, suffixParam2 = ...
    
    if tContains(Curas, prefixParam2) then
        if not tContains(BOOTYBAY.Healers, sourceName) then
            tinsert(BOOTYBAY.Healers, sourceName)
            BOOTYBAY:EncontrarNameplates(WorldFrame:GetChildren())
            ChatThrottleLib:SendAddonMessage("ALERT","BBSCI", "heal;"..sourceName.."", "BATTLEGROUND")
        end
    return
    end
    
    if subevent == "PARTY_KILL" then
        if sourceName == BOOTYBAY.NOME_PLAYER and (bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER) then
            if BOOTYBAY.Fn_ContemChave(BOOTYBAY.dbChar.Blacklist, destName) then
                BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["blacklistkills"] = BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["blacklistkills"] + 1
                local sendMessage = strjoin(";",BOOTYBAY.NOME_PLAYER, "0", tostring(BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["blacklistkills"]), "0", "0", "0", "0", "0", "0")
                ChatThrottleLib:SendAddonMessage("BULK","GRARANKING", sendMessage, "GUILD")
                BOOTYBAY.dbChar.KillStreak = BOOTYBAY.dbChar.KillStreak + 1
                ChatThrottleLib:SendAddonMessage("ALERT","BBSCBK", ""..sourceName.." matou um nome da blacklist: "..destName.."!", "GUILD");
            else
                BOOTYBAY.dbChar.KillStreak = BOOTYBAY.dbChar.KillStreak + 1
            end

            if BOOTYBAY.dbChar.KillStreak > BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["killstreak"] then
                BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["killstreak"] = BOOTYBAY.dbChar.KillStreak
                local sendMessage = strjoin(";",BOOTYBAY.NOME_PLAYER, tostring(BOOTYBAY.dbChar.MembrosData[BOOTYBAY.NOME_PLAYER]["killstreak"]), "0", "0", "0", "0", "0", "0", "0")
                ChatThrottleLib:SendAddonMessage("BULK","GRARANKING", sendMessage, "GUILD")
            end

            if BOOTYBAY.dbChar.KillStreak % 10 == 0 then
                ChatThrottleLib:SendAddonMessage("ALERT","BBSCKS", ""..sourceName.." matou "..destName..", já são "..BOOTYBAY.dbChar.KillStreak.." kills sem morrer", "GUILD");
            end
        end
    return
    end

    if destGUID == BOOTYBAY.PLAYER_GUID and bit_band(sourceFlags, HOSTILE_PLAYER) ~= 0 then
        if subevent == "SPELL_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE" or subevent == "RANGE_DAMAGE" then
            if suffixParam2 > 0 then
                ChatThrottleLib:SendAddonMessage("ALERT","BBSCM","["..sourceName.."] matou ["..destName.."] com "..GetSpellLink(prefixParam1).."", "GUILD")
                BOOTYBAY.dbChar.KillStreak = 0
                BOOTYBAY.dbChar.UltimoStreakAtingido = 0
            end
        elseif subevent == "SWING_DAMAGE" then
            if prefixParam2 > 0 then
                ChatThrottleLib:SendAddonMessage("ALERT","BBSCM","["..sourceName.."] matou ["..destName.."] com um melee swing","GUILD")
                BOOTYBAY.dbChar.KillStreak = 0
                BOOTYBAY.dbChar.UltimoStreakAtingido = 0
            end
        end
    end
end