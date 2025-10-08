local addonName = "BetterRepText"
local f = CreateFrame("Frame")

-- Control para activar/desactivar el addon
local repEnabled = true

-- Función para mostrar el texto flotante
local function ShowRepText(amount, factionName)
    local msg = "+" .. amount .. " " .. factionName

    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        -- Usar animación de BCT si está presente
        CombatText_AddMessage(msg, CombatText_StandardScroll, 0.2, 0.8, 0.2, "sticky")
    else
        -- Fallback básico
        UIErrorsFrame:AddMessage(msg, 0.2, 0.8, 0.2, 53, 3)
    end
end

-- Escuchar cambios de reputación
f:RegisterEvent("COMBAT_TEXT_UPDATE")
f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if not repEnabled then return end

    if arg1 == "FACTION" and arg2 then
        local factionName, standingID, barMin, barMax, barValue = GetWatchedFactionInfo()
        if factionName and barValue then
            ShowRepText(barValue, factionName)
        end
    end
end)

-- Comando de usuario para activar/desactivar
SLASH_REPTEXT1 = "/reptext"
SlashCmdList["REPTEXT"] = function(msg)
    msg = msg:lower()
    if msg == "off" then
        repEnabled = false
        print("|cffff8800[BetterRepText]|r Addon desactivado.")
    elseif msg == "on" then
        repEnabled = true
        print("|cff88ff00[BetterRepText]|r Addon activado.")
    else
        print("|cffffff00Uso:|r /reptext on | off")
    end
end
