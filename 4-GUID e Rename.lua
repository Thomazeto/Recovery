local Recovery, BOOTYBAY    = ...

function BOOTYBAY:AtualizarGuidScoreBG(tab, nome, guid)
    if tab[nome] then
        -- Não tem o GUID na tabela
        if not tab[nome]["guid"] then
            tab[nome]["guid"] = guid
            return
        else
            -- É o mesmo GUID, encerra
            if tab[nome]["guid"] == guid then
            return
            end
        end
    end

    for k, v in pairs(tab) do
        -- Tem o GUID mas para outro nome
        if v.guid == guid and k ~= nome then
            if tab[nome] then
                tab[k]["total"] = tab[k]["total"] + tab[nome]["total"]
                tab[k]["vitoria"] = tab[k]["vitoria"] + tab[nome]["vitoria"]
                tab[nome] = nil
            end
            
            tab[nome] = tab[k]
            tab[k] = nil
            return
        end
    end
end
    
function BOOTYBAY:AtualizarGuid(nome, guid, score)
    if BOOTYBAY.dbData.Guid[guid] then 
        if not tContains(BOOTYBAY.dbData.Guid[guid], nome) then
            tinsert(BOOTYBAY.dbData.Guid[guid], nome)
            ChatThrottleLib:SendAddonMessage("BULK","GRAGUID", ""..guid..";"..nome.."", "GUILD")
        end
    else
        BOOTYBAY.dbData.Guid[guid] = {}
        tinsert(BOOTYBAY.dbData.Guid[guid], nome)
        ChatThrottleLib:SendAddonMessage("BULK","GRAGUID", ""..guid..";"..nome.."", "GUILD")
    end
    
    if score then
        BOOTYBAY:AtualizarGuidScoreBG(BOOTYBAY.dbData.BgContra, nome, guid)
        BOOTYBAY:AtualizarGuidScoreBG(BOOTYBAY.dbData.BgJunto, nome, guid)
    end
end