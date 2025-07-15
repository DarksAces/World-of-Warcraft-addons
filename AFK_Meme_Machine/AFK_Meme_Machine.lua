local locale = GetLocale()
local messages = AFKFunSimple_Locales[locale] or AFKFunSimple_Locales["enUS"]

-- Variable para activar/desactivar el addon
local addonEnabled = true

-- Variables para el control de estado AFK
local wasAFK = false
local repeatTicker = nil  -- ticker para mensajes repetidos

local function GetRandomAFKMessage()
    local name = UnitName("player") or "Player"
    local message = messages[math.random(#messages)]
    return message:format(name)
end

-- Función para mostrar todos los mensajes disponibles
local function ShowAllMessages()
    print("|cff00ff00AFK Meme Machine - Mensajes disponibles:|r")
    for i, msg in ipairs(messages) do
        local displayMsg = msg:format(UnitName("player") or "TuNombre")
        print("|cffff8800" .. i .. ".|r " .. displayMsg)
    end
end

-- Función para enviar un mensaje específico
local function SendSpecificMessage(index)
    local msgIndex = tonumber(index)
    if msgIndex and msgIndex >= 1 and msgIndex <= #messages then
        local name = UnitName("player") or "Player"
        local message = messages[msgIndex]:format(name)
        SendChatMessage(message, "AFK")
        print("|cff00ff00Mensaje AFK enviado:|r " .. message)
    else
        print("|cffff0000Error:|r Número de mensaje inválido. Usa /afkmeme list para ver los mensajes disponibles.")
    end
end

-- Función para iniciar envío repetido de mensajes AFK
local function StartSendingMessages()
    if repeatTicker then return end -- ya activo, no hacer nada

    repeatTicker = C_Timer.NewTicker(60, function()
        if addonEnabled and UnitIsAFK("player") then
            local msg = GetRandomAFKMessage()
            SendChatMessage(msg, "AFK")
            print("|cff00ff00[AFK Meme] Mensaje repetido enviado:|r " .. msg)
        else
            -- Si ya no estás AFK, detener ticker
            if repeatTicker then
                repeatTicker:Cancel()
                repeatTicker = nil
                print("|cffff8800[AFK Meme] Dejo de enviar mensajes, ya no estás AFK.|r")
            end
        end
    end)
end

-- Función para detener envío repetido
local function StopSendingMessages()
    if repeatTicker then
        repeatTicker:Cancel()
        repeatTicker = nil
        print("|cffff8800[AFK Meme] Mensajes repetidos detenidos.|r")
    end
end

-- Registro de comandos slash
SLASH_AFKMEME1 = "/afkmeme"
SLASH_AFKMEME2 = "/meme"
function SlashCmdList.AFKMEME(msg, editbox)
    local command, arg = msg:match("^(%S*)%s*(.-)$")
    command = command:lower()

    if command == "" or command == "help" then
        print("|cff00ff00=== AFK Meme Machine ===|r")
        print("|cffff8800/afkmeme|r - Muestra esta ayuda")
        print("|cffff8800/afkmeme on|r - Activa el addon")
        print("|cffff8800/afkmeme off|r - Desactiva el addon")
        print("|cffff8800/afkmeme list|r - Muestra todos los mensajes disponibles")
        print("|cffff8800/afkmeme send [número]|r - Envía un mensaje específico")
        print("|cffff8800/afkmeme random|r - Envía un mensaje aleatorio")
        print("|cffff8800/afkmeme status|r - Muestra el estado del addon")
        print("|cffff8800/afkmeme test|r - Prueba la detección de AFK")

    elseif command == "on" then
        addonEnabled = true
        print("|cff00ff00AFK Meme Machine activado.|r")

    elseif command == "off" then
        addonEnabled = false
        print("|cffff8800AFK Meme Machine desactivado.|r")
        StopSendingMessages()

    elseif command == "list" then
        ShowAllMessages()

    elseif command == "send" then
        if arg == "" then
            print("|cffff0000Error:|r Especifica el número del mensaje. Ejemplo: /afkmeme send 3")
        else
            SendSpecificMessage(arg)
        end

    elseif command == "random" then
        local message = GetRandomAFKMessage()
        SendChatMessage(message, "AFK")
        print("|cff00ff00Mensaje AFK aleatorio enviado:|r " .. message)

    elseif command == "status" then
        local status = addonEnabled and "|cff00ff00Activado|r" or "|cffff0000Desactivado|r"
        print("|cff00ff00AFK Meme Machine:|r " .. status)
        print("|cff00ff00Idioma:|r " .. locale)
        print("|cff00ff00Mensajes disponibles:|r " .. #messages)

    elseif command == "test" then
        local isAFK = UnitIsAFK("player")
        print("|cff00ff00Estado AFK actual:|r " .. (isAFK and "SÍ" or "NO"))
        print("|cff00ff00wasAFK:|r " .. (wasAFK and "SÍ" or "NO"))
        if isAFK then
            print("|cff00ff00¡Estás AFK! El addon debería haber enviado un mensaje.|r")
        else
            print("|cff00ff00No estás AFK. Usa /afk para ponerte AFK y probar.|r")
        end

    else
        print("|cffff0000Comando desconocido.|r Usa |cffff8800/afkmeme help|r para ver la ayuda.")
    end
end

-- Timer para verificar el estado AFK (cada 0.5 segundos)
local checkTimer = C_Timer.NewTicker(0.5, function()
    if addonEnabled then
        local isAFK = UnitIsAFK("player")
        if isAFK and not wasAFK then
            -- Acabamos de ponernos AFK
            local message = GetRandomAFKMessage()
            SendChatMessage(message, "AFK")
            print("|cff00ff00[AFK Meme] Mensaje inicial enviado:|r " .. message)
            wasAFK = true

            -- Arrancamos envío repetido
            StartSendingMessages()

        elseif not isAFK and wasAFK then
            -- Ya no estamos AFK
            wasAFK = false

            -- Paramos envío repetido
            StopSendingMessages()
        end
    else
        -- addon desactivado: asegurar detener envío repetido
        StopSendingMessages()
    end
end)

-- Frame para eventos automáticos
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
frame:RegisterEvent("CHAT_MSG_SYSTEM")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "AFK_Meme_Machine" then
            print("|cff00ff00AFK Meme Machine cargado.|r Usa |cffff8800/afkmeme help|r para ver los comandos.")
            -- Inicializar el estado AFK al cargar SIN enviar mensaje
            wasAFK = UnitIsAFK("player")
            if wasAFK then
                print("|cffff8800[AFK Meme] Detectado que ya estás AFK. Próximo mensaje al cambiar de estado.|r")
                -- Aquí no enviamos mensaje inicial para evitar spam al login
                StartSendingMessages()
            end
        end
    elseif event == "PLAYER_FLAGS_CHANGED" then
        if addonEnabled then
            local isAFK = UnitIsAFK("player")
            if isAFK and not wasAFK then
                local message = GetRandomAFKMessage()
                SendChatMessage(message, "AFK")
                print("|cff00ff00[AFK Meme] Mensaje enviado (evento):|r " .. message)
                wasAFK = true
                StartSendingMessages()
            elseif not isAFK and wasAFK then
                wasAFK = false
                StopSendingMessages()
            end
        end
    elseif event == "CHAT_MSG_SYSTEM" then
        local message = ...
        if message and (message:find("You are now AFK") or message:find("Ahora estás AFK") or message:find("Estás AFK")) then
            if addonEnabled and not wasAFK then
                local afkMessage = GetRandomAFKMessage()
                SendChatMessage(afkMessage, "AFK")
                print("|cff00ff00[AFK Meme] Mensaje enviado (sistema):|r " .. afkMessage)
                wasAFK = true
                StartSendingMessages()
            end
        elseif message and (message:find("You are no longer AFK") or message:find("Ya no estás AFK") or message:find("No estás AFK")) then
            wasAFK = false
            StopSendingMessages()
        end
    end
end)
