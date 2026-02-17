-- Bag Space Notifier - Configurable
local frame = CreateFrame("Frame", "BagSpaceNotifierFrame")
local addonName = "BagSpaceNotifier"

-- Configuración por defecto
local defaultConfig = {
    thresholds = {50, 75, 90, 95}, -- Porcentajes donde alertar
    chatAlerts = true,
    onScreenAlerts = true,
    debug = false -- ya no usaremos debug
}

local alertedThresholds = {} -- Para trackear qué alertas ya se mostraron
local configLoaded = false

local function InitializeConfig()
    if BagSpaceNotifierDB == nil then
        BagSpaceNotifierDB = {}
    end
    
    -- Solo aplicar valores por defecto para campos que no existen
    for key, value in pairs(defaultConfig) do
        if BagSpaceNotifierDB[key] == nil then
            if type(value) == "table" then
                BagSpaceNotifierDB[key] = {}
                for i, v in ipairs(value) do
                    BagSpaceNotifierDB[key][i] = v
                end
            else
                BagSpaceNotifierDB[key] = value
            end
        end
    end
    
    configLoaded = true
    alertedThresholds = {}
    print("|cffcccccc[BagSpaceNotifier] Config inicializada - Umbrales: " .. table.concat(BagSpaceNotifierDB.thresholds, "%, ") .. "%|r")
end

local function GetBagFillPercent()
    local totalSlots = 0
    local usedSlots = 0
    
    for bag = 0, 4 do
        local slots = C_Container.GetContainerNumSlots(bag)
        if slots then
            totalSlots = totalSlots + slots
            
            for slot = 1, slots do
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                if itemInfo and itemInfo.itemID then
                    usedSlots = usedSlots + 1
                end
            end
        end
    end
    
    if totalSlots == 0 then return 0 end
    return usedSlots / totalSlots
end

-- Frame para mostrar alerta grande arriba-centro
-- Frame para mostrar alerta grande arriba-centro
local alertFrame = CreateFrame("Frame", "BagSpaceAlertFrame", UIParent)
alertFrame:SetSize(500, 70)
alertFrame:SetPoint("TOP", UIParent, "TOP", 0, -120)

-- Fondo semitransparente negro
alertFrame.bg = alertFrame:CreateTexture(nil, "BACKGROUND")
alertFrame.bg:SetAllPoints()
alertFrame.bg:SetColorTexture(0, 0, 0, 0.7)

-- Texto grande con borde blanco
alertFrame.text = alertFrame:CreateFontString(nil, "OVERLAY")
alertFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
alertFrame.text:SetPoint("CENTER", alertFrame, "CENTER")
alertFrame.text:SetTextColor(1, 0.1, 0.1, 1) -- rojo brillante
alertFrame.text:SetJustifyH("CENTER")

alertFrame:Hide()

local alertTimer
local fadeIn = alertFrame:CreateAnimationGroup()
local alphaIn = fadeIn:CreateAnimation("Alpha")
alphaIn:SetDuration(4)
alphaIn:SetFromAlpha(0)
alphaIn:SetToAlpha(1)

local fadeOut = alertFrame:CreateAnimationGroup()
local alphaOut = fadeOut:CreateAnimation("Alpha")
alphaOut:SetDuration(4)
alphaOut:SetFromAlpha(1)
alphaOut:SetToAlpha(0)
fadeOut:SetScript("OnFinished", function()
    alertFrame:Hide()
end)

local function ShowBigAlert(message)
    if alertTimer then
        alertTimer:Cancel()
        alertTimer = nil
    end
    fadeIn:Stop()
    fadeOut:Stop()
    alertFrame.text:SetText(message)
    alertFrame:SetAlpha(0)
    alertFrame:Show()
    fadeIn:Play()
    
    alertTimer = C_Timer.NewTimer(3, function()
        fadeOut:Play()
        alertTimer = nil
    end)
end


local function ShowAlert(percentage, fillPercent)
    local actualPercent = math.floor(fillPercent * 100)
    
    -- Alerta en chat
    if BagSpaceNotifierDB.chatAlerts then
        local color = "|cffff0000" -- Rojo por defecto
        if percentage <= 50 then color = "|cffffff00" -- Amarillo
        elseif percentage <= 75 then color = "|cffff8000" -- Naranja
        end
        
        print(color .. "[BagSpaceNotifier] ¡Inventario al " .. actualPercent .. "%! (Alerta: " .. percentage .. "%)|r")
    end
    
    -- Alerta grande en pantalla, arriba-centro
    if BagSpaceNotifierDB.onScreenAlerts then
        ShowBigAlert("¡Inventario al " .. actualPercent .. "%!")
    end
end

local function CheckAlerts()
    if not configLoaded or not BagSpaceNotifierDB or not BagSpaceNotifierDB.thresholds then
        return
    end
    
    local fill = GetBagFillPercent()
    local currentPercent = math.floor(fill * 100)
    
    -- Verificar cada umbral configurado (sin debug)
    for _, threshold in ipairs(BagSpaceNotifierDB.thresholds) do
        if currentPercent >= threshold and not alertedThresholds[threshold] then
            ShowAlert(threshold, fill)
            alertedThresholds[threshold] = true
        elseif currentPercent < threshold and alertedThresholds[threshold] then
            -- Reset la alerta cuando baja del umbral
            alertedThresholds[threshold] = false
        end
    end
end

-- Comandos slash para configurar (sin el comando set)
SLASH_BAGNOTIFIER1 = "/bagnotifier"
SLASH_BAGNOTIFIER2 = "/bn"

SlashCmdList["BAGNOTIFIER"] = function(msg)
    local command, arg = strsplit(" ", msg, 2)
    command = strlower(command or "")
    
    if command == "config" or command == "" then
        print("|cff00ff00[BagSpaceNotifier] Configuración actual:|r")
        print("Umbrales: " .. table.concat(BagSpaceNotifierDB.thresholds, "%, ") .. "%")
        print("Chat: " .. (BagSpaceNotifierDB.chatAlerts and "Activado" or "Desactivado"))
        print("Pantalla: " .. (BagSpaceNotifierDB.onScreenAlerts and "Activado" or "Desactivado"))
        print("Debug: desactivado")
        print("|cffccccccComandos disponibles:|r")
        print("/bn chat <on/off> - Activar/desactivar alertas en chat")
        print("/bn screen <on/off> - Activar/desactivar alertas en pantalla")
        print("/bn reset - Restaurar configuración por defecto")
        print("/bn status - Ver estado actual del inventario")
        print("/bn save - Mostrar configuración actual para verificar")
        
    elseif command == "chat" then
        if arg == "on" then
            BagSpaceNotifierDB.chatAlerts = true
            print("|cff00ff00[BagSpaceNotifier] Alertas en chat activadas|r")
        elseif arg == "off" then
            BagSpaceNotifierDB.chatAlerts = false
            print("|cff00ff00[BagSpaceNotifier] Alertas en chat desactivadas|r")
        else
            print("|cffff0000[BagSpaceNotifier] Usa: /bn chat on o /bn chat off|r")
        end
        
    elseif command == "screen" then
        if arg == "on" then
            BagSpaceNotifierDB.onScreenAlerts = true
            print("|cff00ff00[BagSpaceNotifier] Alertas en pantalla activadas|r")
        elseif arg == "off" then
            BagSpaceNotifierDB.onScreenAlerts = false
            print("|cff00ff00[BagSpaceNotifier] Alertas en pantalla desactivadas|r")
        else
            print("|cffff0000[BagSpaceNotifier] Usa: /bn screen on o /bn screen off|r")
        end
        
    elseif command == "reset" then
        BagSpaceNotifierDB = {}
        configLoaded = false
        InitializeConfig()
        alertedThresholds = {}
        print("|cff00ff00[BagSpaceNotifier] Configuración restaurada a valores por defecto|r")
        
    elseif command == "status" then
        local fill = GetBagFillPercent()
        local percent = math.floor(fill * 100)
        local color = "|cff00ff00"
        if percent >= 90 then color = "|cffff0000"
        elseif percent >= 75 then color = "|cffff8000"
        elseif percent >= 50 then color = "|cffffff00"
        end
        
        print(color .. "[BagSpaceNotifier] Inventario actual: " .. percent .. "%|r")
        
    elseif command == "save" then
        print("|cff00ff00[BagSpaceNotifier] Configuración actual:|r")
        print("Umbrales guardados: " .. table.concat(BagSpaceNotifierDB.thresholds, "%, ") .. "%")
        print("Esta configuración debería persistir después de /reload")
        
    else
        print("|cffff0000[BagSpaceNotifier] Comando desconocido. Usa /bn config para ver ayuda|r")
    end
end

-- Registrar eventos
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, loadedAddonName)
    if event == "ADDON_LOADED" then
        if not configLoaded then
            InitializeConfig()
            print("|cff00ff00[BagSpaceNotifier] Cargado. Usa /bn config para configurar|r")
        end
        return
    end
    
    if event == "PLAYER_LOGIN" then
        if not configLoaded then
            InitializeConfig()
        end
        return
    end
    
    if (event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED") and configLoaded then
        C_Timer.After(0.1, CheckAlerts)
    end
end)
