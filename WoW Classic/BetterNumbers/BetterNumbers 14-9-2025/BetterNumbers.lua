-- CompactNumbers: Muestra vida y maná/poder con números acortados (K/M/B)
-- Ahora con opción para mostrar u ocultar porcentaje (%) y tamaño dinámico de texto

-- Variables de configuración
local decimalPlaces = 1
local showPercent = false -- por defecto activado
local baseFontSize = 12
local percentFontSize = 9 -- tamaño más pequeño si se muestra el porcentaje

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

-- Función que devuelve texto con o sin porcentaje
local function FormatWithOptionalPercent(current, max)
    if max > 0 then
        if showPercent then
            local percent = (current / max) * 100
            return ShortenNumber(current) .. " / " .. ShortenNumber(max) .. string.format(" (%.0f%%)", percent)
        else
            return ShortenNumber(current) .. " / " .. ShortenNumber(max)
        end
    else
        return ShortenNumber(current) .. " / " .. ShortenNumber(max)
    end
end

-- Función para actualizar tamaño de fuente según showPercent
local function UpdateFontSize(text)
    if showPercent then
        text:SetFont("Fonts\\FRIZQT__.TTF", percentFontSize)
    else
        text:SetFont("Fonts\\FRIZQT__.TTF", baseFontSize)
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
    playerHealthText:SetText(FormatWithOptionalPercent(pHP, pHPMax))
    playerPowerText:SetText(pMPMax > 0 and FormatWithOptionalPercent(pMP, pMPMax) or "")
    UpdateFontSize(playerHealthText)
    UpdateFontSize(playerPowerText)

    -- Objetivo
    if UnitExists("target") then
        local tHP, tHPMax = UnitHealth("target"), UnitHealthMax("target")
        local tMP, tMPMax = UnitPower("target"), UnitPowerMax("target")
        targetHealthText:SetText(FormatWithOptionalPercent(tHP, tHPMax))
        targetPowerText:SetText(tMPMax > 0 and FormatWithOptionalPercent(tMP, tMPMax) or "")
        UpdateFontSize(targetHealthText)
        UpdateFontSize(targetPowerText)
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

-- Comandos para activar/desactivar porcentaje
SLASH_PERCENT1 = "/percent"
SLASH_PORCENTAJE1 = "/porcentaje"
SlashCmdList["PERCENT"] = function(msg)
    msg = msg:lower()
    if msg == "on" or msg == "1" then
        showPercent = true
        print("Percent display: ON")
    elseif msg == "off" or msg == "0" then
        showPercent = false
        print("Percent display: OFF")
    else
        print("Usage: /percent [on|off] or /porcentaje [on|off]")
    end
    UpdateOverlayText()
end
