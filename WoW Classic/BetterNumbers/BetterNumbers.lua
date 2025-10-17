-- CompactNumbers: Muestra vida y maná/poder con números acortados (K/M/B)
-- Ahora con contorno negro y escalado automático para diferentes resoluciones
-- + Ocultar overlay cuando el ratón está encima de la barra de vida

-- Variables de configuración
local decimalPlaces = 1
local showPercent = false
local baseFontSize = 12
local percentFontSize = 9

-- Función para obtener el factor de escala de la UI
local function GetUIScale()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    -- Escala base para 1920x1080
    local baseWidth = 1920
    local baseHeight = 1080

    -- Calcular factor de escala basado en resolución
    local scaleX = screenWidth / baseWidth
    local scaleY = screenHeight / baseHeight
    local scale = math.min(scaleX, scaleY)

    -- Limitar el escalado entre 0.5 y 2.0
    return math.max(0.5, math.min(2.0, scale))
end

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

-- Función para actualizar tamaño de fuente con escala automática
local function UpdateFontSize(text)
    local uiScale = GetUIScale()
    local fontSize

    if showPercent then
        fontSize = math.floor(percentFontSize * uiScale)
    else
        fontSize = math.floor(baseFontSize * uiScale)
    end

    -- Asegurar que el tamaño no sea demasiado pequeño o grande
    fontSize = math.max(6, math.min(24, fontSize))

    -- Aplicar fuente con contorno negro
    text:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")

    -- Color del texto (blanco por defecto)
    text:SetTextColor(1, 1, 1, 1)

    -- Sombra adicional para mejor visibilidad
    if text.SetShadowColor then
        text:SetShadowColor(0, 0, 0, 1)
        text:SetShadowOffset(1, -1)
    end
end

-- Crea texto overlay en el frame deseado con mejor posicionamiento
local function CreateOverlayText(parentFrame, offsetY)
    if not parentFrame then return nil end
    local text = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("CENTER", parentFrame, "CENTER", 0, offsetY or 0)
    text:SetText("")

    -- Configurar justificación del texto
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")

    return text
end

-- Crear textos para vida y maná del jugador y objetivo
local playerHealthText = CreateOverlayText(PlayerFrame and PlayerFrame.healthbar or nil, 0)
local playerPowerText  = CreateOverlayText(PlayerFrame and PlayerFrame.manabar or nil, 0)

local targetHealthText = CreateOverlayText(TargetFrame and TargetFrame.healthbar or nil, 0)
local targetPowerText  = CreateOverlayText(TargetFrame and TargetFrame.manabar or nil, 0)

-- Ocultar/Mostrar helper (acepta múltiples fontstrings)
-- Ocultar/Mostrar helper (acepta múltiples fontstrings)
-- Ocultar/Mostrar helper (acepta múltiples fontstrings)
-- Ocultar/Mostrar helper (acepta múltiples fontstrings)
-- Ocultar/Mostrar helper (acepta múltiples fontstrings)
local function HideTexts(...)
    local texts = {...}
    for i = 1, #texts do
        local t = texts[i]
        if t and t.Hide then t:Hide() end
    end
end

local function ShowTexts(...)
    local texts = {...}
    for i = 1, #texts do
        local t = texts[i]
        if t and t.Show then t:Show() end
    end
end

-- Oculta solo nuestros overlays al pasar el ratón, sin tocar los de Blizzard
local function SetMouseHide(bar, ...)
    if not bar then return end
    bar:EnableMouse(true)
    local texts = {...}

    -- HookScript no sobreescribe los OnEnter/OnLeave existentes de Blizzard
    bar:HookScript("OnEnter", function()
        HideTexts(unpack(texts))
    end)

    bar:HookScript("OnLeave", function()
        ShowTexts(unpack(texts))
    end)
end

-- Aplicar comportamiento mouseover en player/target
SetMouseHide(PlayerFrame and PlayerFrame.healthbar or nil, playerHealthText)
SetMouseHide(PlayerFrame and PlayerFrame.manabar or nil, playerPowerText)

SetMouseHide(TargetFrame and TargetFrame.healthbar or nil, targetHealthText)
SetMouseHide(TargetFrame and TargetFrame.manabar or nil, targetPowerText)


-- Actualiza todos los textos de vida y maná/poder
local function UpdateOverlayText()
    -- Jugador
    if playerHealthText then
        local pHP, pHPMax = UnitHealth("player"), UnitHealthMax("player")
        local pMP, pMPMax = UnitPower("player"), UnitPowerMax("player")

        playerHealthText:SetText(FormatWithOptionalPercent(pHP, pHPMax))
        playerPowerText:SetText(pMPMax > 0 and FormatWithOptionalPercent(pMP, pMPMax) or "")

        UpdateFontSize(playerHealthText)
        UpdateFontSize(playerPowerText)
    end

    -- Objetivo
    if UnitExists("target") and targetHealthText then
        local tHP, tHPMax = UnitHealth("target"), UnitHealthMax("target")
        local tMP, tMPMax = UnitPower("target"), UnitPowerMax("target")

        targetHealthText:SetText(FormatWithOptionalPercent(tHP, tHPMax))
        targetPowerText:SetText(tMPMax > 0 and FormatWithOptionalPercent(tMP, tMPMax) or "")

        UpdateFontSize(targetHealthText)
        UpdateFontSize(targetPowerText)
    else
        if targetHealthText then targetHealthText:SetText("") end
        if targetPowerText then targetPowerText:SetText("") end
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

-- Comando para ajustar tamaño base de fuente
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

-- Comando para mostrar información de resolución
SLASH_RESOLUTION1 = "/resolution"
SLASH_RESOLUCION1 = "/resolucion"
SlashCmdList["RESOLUTION"] = function()
    local width = GetScreenWidth()
    local height = GetScreenHeight()
    local scale = GetUIScale()
    print(string.format("Resolution: %.0fx%.0f, UI Scale Factor: %.2f", width, height, scale))
end

-- Inicializar primera actualización
UpdateOverlayText()
