-- CompactNumbers: Muestra vida y maná/poder con números acortados (K/M/B)

-- Variable para número de decimales, valor por defecto 1
local decimalPlaces = 1

-- Función para reducir números grandes con decimales configurables
local function ShortenNumber(value)
    local formatString = "%." .. decimalPlaces .. "f"
    if value >= 1e18 then
        return string.format(formatString .. "Qi", value / 1e18)
    elseif value >= 1e15 then
        return string.format(formatString .. "Qa", value / 1e15)
    elseif value >= 1e12 then
        return string.format(formatString .. "T", value / 1e12)
    elseif value >= 1e9 then
        return string.format(formatString .. "B", value / 1e9)
    elseif value >= 1e6 then
        return string.format(formatString .. "M", value / 1e6)
    elseif value >= 1e3 then
        return string.format(formatString .. "K", value / 1e3)
    else
        return tostring(value)
    end
end

-- Crea texto overlay en el frame deseado
local function CreateOverlayText(parentFrame, offsetY)
    local text = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("CENTER", parentFrame, "CENTER", 0, offsetY or 0)
    text:SetText("")
    return text
end

-- Crear textos para vida y maná del jugador y objetivo
local playerHealthText = CreateOverlayText(PlayerFrame.healthbar, 0)
local playerPowerText  = CreateOverlayText(PlayerFrame.manabar, 0)

local targetHealthText = CreateOverlayText(TargetFrame.healthbar, 0)
local targetPowerText  = CreateOverlayText(TargetFrame.manabar, 0)

-- Actualiza todos los textos de vida y maná/poder
local function UpdateOverlayText()
    -- Jugador
    local pHP, pHPMax = UnitHealth("player"), UnitHealthMax("player")
    local pMP, pMPMax = UnitPower("player"), UnitPowerMax("player")
    playerHealthText:SetText(ShortenNumber(pHP) .. " / " .. ShortenNumber(pHPMax))
    if pMPMax > 0 then
        playerPowerText:SetText(ShortenNumber(pMP) .. " / " .. ShortenNumber(pMPMax))
    else
        playerPowerText:SetText("")
    end

    -- Objetivo
    if UnitExists("target") then
        local tHP, tHPMax = UnitHealth("target"), UnitHealthMax("target")
        local tMP, tMPMax = UnitPower("target"), UnitPowerMax("target")
        targetHealthText:SetText(ShortenNumber(tHP) .. " / " .. ShortenNumber(tHPMax))
        if tMPMax > 0 then
            targetPowerText:SetText(ShortenNumber(tMP) .. " / " .. ShortenNumber(tMPMax))
        else
            targetPowerText:SetText("")
        end
    else
        targetHealthText:SetText("")
        targetPowerText:SetText("")
    end
end

-- Crear frame de eventos
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")

-- Solo actualizar en eventos clave
frame:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TARGET_CHANGED" or unit == "player" or unit == "target" then
        UpdateOverlayText()
    end
end)

-- Comandos para cambiar decimales
SLASH_DECIMALES1 = "/decimales"
SLASH_DECIMALS1 = "/decimals"
SlashCmdList["DECIMALES"] = function(msg)
    local n = tonumber(msg)
    if n and n >= 0 and n <= 5 then
        decimalPlaces = n
        print("Decimal places set to: " .. decimalPlaces)
        UpdateOverlayText()
    else
        print("Usage: /decimales [0-5] or /decimals [0-5]. Example: /decimales 2")
    end
end
