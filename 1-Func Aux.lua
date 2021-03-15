local Recovery, BOOTYBAY    = ...

-- FUNÇÕES AUXILIARES

function BOOTYBAY.Fn_RemoverChave(tab, key)
    local element = tab[key]
    tab[key] = nil
    return element
end

function BOOTYBAY.Fn_ContemChave(tab, key)
    for k, v in pairs(tab) do
        if k == key then
            return true
        end
    end

    return false
end

function BOOTYBAY.Fn_Arredondamento(num, c)
  local mult = 10^(c or 0)
  return math.floor(num * mult + 0.5) / mult
end

function BOOTYBAY.Fn_PadronizarNome(first, rest) -- Padronizar nicks capitalizando a primeira letra (killax/KILLAX/KILLax > Killax)
   return first:upper()..rest:lower()
end

function BOOTYBAY.Fn_CopiarTabela(src, dst)
if type(src) ~= "table" then return {} end
if type(dst) ~= "table" then dst = { } end
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = BOOTYBAY.Fn_CopiarTabela(v, dst[k])
        elseif type(v) ~= type(dst[k]) then
            dst[k] = v
        end
    end
return dst
end

function BOOTYBAY.Fn_ConverterTime(t)
local hours   = floor(mod(t, 86400)/3600)
local minutes = floor(mod(t,3600)/60)
local seconds = floor(mod(t,60))
    if hours == 0 then
        return format("%02dm:%02ds",minutes,seconds)
    else 
        return format("%dh:%02dm:%02ds",hours,minutes,seconds)
    end
end

function BOOTYBAY.Fn_AbreviarNumeros(n)
    if n >= 10^6 then
        return string.format("%.2fm", n / 10^6)
    elseif n >= 10^3 then
        return string.format("%.fk", n / 10^3)
    else
        return tostring(n)
    end
end
