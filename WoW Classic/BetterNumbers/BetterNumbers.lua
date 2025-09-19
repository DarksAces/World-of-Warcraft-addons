-- CompactNumbers: Muestra vida y manÃ¡/poder con nÃºmeros acortados (K/M/B)
-- Ahora con contorno negro y escalado automÃ¡tico para diferentes resoluciones

-- Variables de configuraciÃ³n
local decimalPlaces = 1
local showPercent = false
local baseFontSize = 12
local percentFontSize = 9

-- FunciÃ³n para obtener el factor de escala de la UI
local function GetUIScale()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    -- Escala base para 1920x1080
    local baseWidth = 1920
    local baseHeight = 1080
    
    -- Calcular factor de escala basado en resoluciÃ³n
    local scaleX = screenWidth / baseWidth
    local scaleY = screenHeight / baseHeight
    local scale = math.min(scaleX, scaleY)
    
    -- Limitar el escalado entre 0.5 y 2.0
    return math.max(0.5, math.min(2.0, scale))
end

-- FunciÃ³n para reducir nÃºmeros grandes con decimales configurables
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

-- FunciÃ³n que devuelve texto con o sin porcentaje
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

-- FunciÃ³n para actualizar tamaÃ±o de fuente con escala automÃ¡tica
local function UpdateFontSize(text)
    local uiScale = GetUIScale()
    local fontSize
    
    if showPercent then
        fontSize = math.floor(percentFontSize * uiScale)
    else
        fontSize = math.floor(baseFontSize * uiScale)
    end
    
    -- Asegurar que el tamaÃ±o no sea demasiado pequeÃ±o o grande
    fontSize = math.max(6, math.min(24, fontSize))
    
    -- Aplicar fuente con contorno negro
    text:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
    
    -- Color del texto (blanco por defecto)
    text:SetTextColor(1, 1, 1, 1)
    
    -- Sombra adicional para mejor visibilidad
    text:SetShadowColor(0, 0, 0, 1)
    text:SetShadowOffset(1, -1)
end

-- Crea texto overlay en el frame deseado con mejor posicionamiento
local function CreateOverlayText(parentFrame, offsetY)
    local text = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("CENTER", parentFrame, "CENTER", 0, offsetY or 0)
    text:SetText("")
    
    -- Configurar justificaciÃ³n del texto
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    
    return text
end

-- Crear textos para vida y manÃ¡ del jugador y objetivo
local playerHealthText = CreateOverlayText(PlayerFrame.healthbar, 0)
local playerPowerText  = CreateOverlayText(PlayerFrame.manabar, 0)

local targetHealthText = CreateOverlayText(TargetFrame.healthbar, 0)
local targetPowerText  = CreateOverlayText(TargetFrame.manabar, 0)

-- Actualiza todos los textos de vida y manÃ¡/poder
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
frame:RegisterEvent("UI_SCALE_CHANGED") -- Nuevo evento para cambios de escala

-- Solo actualizar en eventos clave
frame:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_ENTERING_WORLD" or 
       event == "PLAYER_TARGET_CHANGED" or 
       event == "UI_SCALE_CHANGED" or
       unit == "player" or 
       unit == "target" then
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

-- Comando para ajustar tamaÃ±o base de fuente
SLASH_FONTSIZE1 = "/fontsize"
SLASH_TAMANO1 = "/tamano"
SlashCmdList["FONTSIZE"] = function(msg)
    local n = tonumber(msg)
    if n and n >= 6 and n <= 24 then
        baseFontSize = n
        percentFontSize = math.max(6, n - 3)
        print("Base font size set to: " .. baseFontSize .. " (percent size: " .. percentFontSize .. ")")
        UpdateOverlayText()
    else
        print("Usage: /fontsize [6-24] or /tamano [6-24]. Example: /fontsize 14")
    end
end

-- Comando para mostrar informaciÃ³n de resoluciÃ³n
SLASH_RESOLUTION1 = "/resolution"
SLASH_RESOLUCION1 = "/resolucion"
SlashCmdList["RESOLUTION"] = function()
    local width = GetScreenWidth()
    local height = GetScreenHeight()
    local scale = GetUIScale()
    print(string.format("Resolution: %.0fx%.0f, UI Scale Factor: %.2f", width, height, scale))
end