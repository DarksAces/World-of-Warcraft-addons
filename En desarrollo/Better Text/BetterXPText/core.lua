local addonName = "BetterXPText"
local f = CreateFrame("Frame")
local enabled = true
local debug = false

local function ShowXP(amount)
    local msg = "+"..amount.." XP"
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, 0.7, 0.4, 1, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, 0.7, 0.4, 1, 53, 3)
    end
end

f:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
f:SetScript("OnEvent", function(_, _, msg)
    if not enabled then return end
    
    -- Debug: mostrar el mensaje completo
    if debug then
        print("|cff00ff00[DEBUG]|r Mensaje recibido: " .. tostring(msg))
    end
    
    -- Intentar varios patrones (inglés y español, con/sin puntos)
    local xp = msg:match("(%d+) experience") 
            or msg:match("(%d+) experiencia")
            or msg:match("(%d[%d,%.]+) experience")
            or msg:match("(%d[%d,%.]+) experiencia")
    
    if xp then
        -- Limpiar puntos/comas y convertir a número
        xp = xp:gsub("[,%.]", "")
        ShowXP(xp)
    elseif debug then
        print("|cffff0000[DEBUG]|r No se encontró XP en el mensaje")
    end
end)

SLASH_XPTEXT1 = "/xptext"
SlashCmdList["XPTEXT"] = function(msg)
    msg = msg:lower()
    if msg == "off" then 
        enabled = false
        print("|cffff8800[BetterXPText]|r Desactivado") 
    elseif msg == "on" then 
        enabled = true
        print("|cff88ff00[BetterXPText]|r Activado") 
    elseif msg == "debug" then
        debug = not debug
        print("|cff00ffff[BetterXPText]|r Debug: " .. (debug and "ON" or "OFF"))
    else 
        print("|cffffff00Uso:|r /xptext on | off | debug") 
    end
end