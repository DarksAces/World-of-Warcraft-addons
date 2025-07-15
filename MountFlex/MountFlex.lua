-- Configuración por defecto
MountFlexConfig = MountFlexConfig or {
    usePublicMessage = false,  -- No usado, puedes eliminar si quieres
    messageType = "screen"     -- Opciones: "screen", "chat", "say"
}

local locale = GetLocale()
local localeData = MountFlex_Locales_Config.messages[locale] or MountFlex_Locales_Config.messages["enUS"]

-- Variables para controlar estado
local wasMounted = false
local lastMsgTime = 0

local playerName = UnitName("player") or "Rider"

local function GetRandomMountMessage(messagesTable)
    -- Prioriza categoría "generic", si no, toma la primera disponible
    local category, msgs = next(messagesTable)
    if messagesTable["generic"] then
        category = "generic"
        msgs = messagesTable["generic"]
    end

    if not msgs or #msgs == 0 then
        return "Ready to ride!" -- fallback simple
    end

    local index = math.random(#msgs)
    local rawMsg = msgs[index]

    -- Si la frase tiene %s, la formateamos con el nombre del jugador
    if string.find(rawMsg, "%%s") then
        return string.format(rawMsg, playerName)
    else
        return rawMsg
    end
end


-- Frame para mostrar mensaje en pantalla
local msgFrame = CreateFrame("Frame", "MountFlexMessageFrame", UIParent)
msgFrame:SetSize(400, 50)
msgFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
msgFrame.text = msgFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
msgFrame.text:SetAllPoints()
msgFrame.text:SetTextColor(1, 1, 0) -- Amarillo
msgFrame:Hide()

local function ShowMountMessage(msg)
    if MountFlexConfig.messageType == "screen" then
        msgFrame.text:SetText(msg)
        msgFrame:Show()
        C_Timer.After(3, function()
            msgFrame:Hide()
        end)
    elseif MountFlexConfig.messageType == "chat" then
        print(msg)
    elseif MountFlexConfig.messageType == "say" then
        SendChatMessage(msg, "SAY")
    end
end

-- Frame para chequear estado de montura
local checkFrame = CreateFrame("Frame")
checkFrame:SetScript("OnUpdate", function(self, elapsed)
    local nowMounted = IsMounted()
    local currentTime = GetTime()

    if nowMounted and not wasMounted and (currentTime - lastMsgTime) > 3 then
        local msg = GetRandomMountMessage(localeData)
        ShowMountMessage(msg)
        lastMsgTime = currentTime
    end

    wasMounted = nowMounted
end)

-- Comandos slash para configuración rápida
SLASH_MOUNTFLEX1 = "/mountflex"
SLASH_MOUNTFLEX2 = "/mf"
SlashCmdList["MOUNTFLEX"] = function(msg)
    local cmd = string.lower(msg or "")
    if cmd == "screen" then
        MountFlexConfig.messageType = "screen"
        print("MountFlex: Mensajes ahora se muestran en pantalla")
    elseif cmd == "chat" then
        MountFlexConfig.messageType = "chat"
        print("MountFlex: Mensajes ahora se muestran en chat personal")
    elseif cmd == "say" then
        MountFlexConfig.messageType = "say"
        print("MountFlex: Mensajes ahora se muestran en /say")
    else
        print("MountFlex comandos:")
        print("/mountflex screen - Mostrar en pantalla (por defecto)")
        print("/mountflex chat - Mostrar en chat personal")
        print("/mountflex say - Mostrar en /say")
        print("Modo actual: " .. MountFlexConfig.messageType)
    end
end
