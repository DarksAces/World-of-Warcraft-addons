local addonName, addonTable = ...

-- --- Valores por defecto ---
local DEFAULTS = {
    HIDE_BUTTONS = true,
    MOUSE_SCROLL = true,
    TOP_EDITBOX = false,
    CLASS_COLORS = true,
    URL_COPY = true,
    TIMESTAMP = true,
    SHORT_CHANNELS = true,
    ARROW_KEYS = true,
    STICKY_CHANNELS = true,
    TABS_MOUSEOVER = true,
    CHAT_STYLE = true,
    FONT_NAME = "Arial",
    FONT_SIZE = 14,
    FONT_OUTLINE = "OUTLINE",
}

-- Referencia global a la configuración (se asignará en PLAYER_LOGIN)
local CONFIG = DEFAULTS

local FONTS = {
    ["Friz"] = "Fonts\\FRIZQT__.TTF",
    ["Arial"] = "Fonts\\ARIALN.TTF",
    ["Skurri"] = "Fonts\\skurri.TTF",
    ["Morpheus"] = "Fonts\\MORPHEUS.TTF",
}

-- Función para resolver la ruta de la fuente
local function GetFontPath(fontName)
    -- 1. Si está en la lista predefinida
    if FONTS[fontName] then return FONTS[fontName] end
    
    -- 2. Si es "Custom", buscamos Custom.ttf en la carpeta Fonts del addon
    if fontName == "Custom" then
        return "Interface\\AddOns\\CleanChat\\Fonts\\Custom.ttf"
    end

    -- 3. Fuentes Personalizadas: Prioridad carpeta "Fonts"
    -- Ej: /cc font Batman busca .../CleanChat/Fonts/Batman.ttf
    return "Interface\\AddOns\\CleanChat\\Fonts\\" .. fontName .. ".ttf"
end

local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")

-- --- Funciones Helper ---

-- Acortar nombres de canales (Estilo Prat)
local function ShortChannel(self, event, msg, sender, ...)
    if CONFIG.SHORT_CHANNELS then
        local args = { ... }
        local channelString = args[2] -- arg4 in standard payload
        local channelName = args[7]   -- arg9 in standard payload
        
        if channelName then
            local newName = channelName
            newName = string.gsub(newName, "General", "Gen")
            newName = string.gsub(newName, "Trade", "Trd")
            newName = string.gsub(newName, "LocalDefense", "LocDef")
            newName = string.gsub(newName, "LookingForGroup", "LFG")
            newName = string.gsub(newName, "WorldDefense", "WorldDef")
            newName = string.gsub(newName, "Services", "Svc")
            -- Eliminar nombre capitales si es muy largo (ej: Trade - City)
            newName = string.gsub(newName, " %- .*", "") 

            -- Reconstruir el channelString (ej: "1. General" -> "1. Gen")
            if args[6] and args[6] > 0 then -- args[6] is channelNumber (arg8)
                 -- A veces channelString es "1. General", a veces "General"
                 if channelString then
                    args[2] = string.gsub(channelString, channelName, newName)
                 end
            end
            args[7] = newName
            
            return false, msg, sender, unpack(args)
        end
    end
    return false, msg, sender, ...
end

-- Copiar URL
local function ShowPopup(url)
    StaticPopupDialogs["CLEANCHAT_COPY_URL"] = {
        text = "Copia el enlace (Ctrl+C):",
        button1 = "OK",
        OnShow = function(self)
            local editBox = self.editBox
            editBox:SetText(url)
            editBox:SetFocus()
            editBox:HighlightText()
        end,
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("CLEANCHAT_COPY_URL")
end

local function URLFilter(self, event, msg, ...)
    if CONFIG.URL_COPY and msg then
        local newMsg, found = string.gsub(msg, "(https?://%S+)", "|cff00ffff|Hurl:%1|h[%1]|h|r")
        if found > 0 then
            return false, newMsg, ...
        end
        -- También para www.
        newMsg, found = string.gsub(msg, "(www%.%S+)", "|cff00ffff|Hurl:%1|h[%1]|h|r")
        if found > 0 then
            return false, newMsg, ...
        end
    end
    return false, msg, ...
end

hooksecurefunc("SetItemRef", function(link, text, button)
    if string.sub(link, 1, 3) == "url" then
        local url = string.sub(link, 5)
        ShowPopup(url)
    end
end)

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", URLFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", URLFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", URLFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", URLFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", URLFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", URLFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", URLFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", URLFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", URLFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", URLFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", URLFilter)

if CONFIG.SHORT_CHANNELS then
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", ShortChannel)
end

Frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Cargar Variables Guardadas
        if not CleanChatDB then CleanChatDB = {} end
        
        -- Mezclar con defaults por si faltan claves nuevas
        for k, v in pairs(DEFAULTS) do
            if CleanChatDB[k] == nil then
                CleanChatDB[k] = v
            end
        end
        CONFIG = CleanChatDB -- Ahora CONFIG apunta a la tabla guardada

        -- 1. Timestamps: Forzar CVar y formato global
        if CONFIG.TIMESTAMP then
            -- Aseguramos que la opción del juego esté activada con nuestro formato
            -- En WoW moderno, showTimestamps suele contener el formato o "none"
            local current = GetCVar("showTimestamps")
            if current == "none" then 
                SetCVar("showTimestamps", "[%H:%M] ")
            end
            CHAT_TIMESTAMP_FORMAT = "[%H:%M] "
        end

        -- 2. Colores de Clase
        if CONFIG.CLASS_COLORS then
            for k, v in pairs(ChatTypeInfo) do
                if v and type(v) == "table" then
                    v.colorNameByClass = true
                end
            end
        end

        -- 3. Configuración de ventanas de Chat
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame"..i]
            local editBox = _G["ChatFrame"..i.."EditBox"]
            local buttonFrame = _G["ChatFrame"..i.."ButtonFrame"]
            local scrollBar = _G["ChatFrame"..i.."ScrollBar"]

            -- Scroll con Ratón
            if CONFIG.MOUSE_SCROLL and chatFrame then
                chatFrame:EnableMouseWheel(true)
                chatFrame:SetScript("OnMouseWheel", function(self, delta)
                    if delta > 0 then
                        if IsShiftKeyDown() then self:ScrollToTop() else self:ScrollUp() end
                    else
                        if IsShiftKeyDown() then self:ScrollToBottom() else self:ScrollDown() end
                    end
                end)
            end

            -- Pestañas: Ocultar hasta pasar el ratón (Estilo Prat)
            if CONFIG.TABS_MOUSEOVER then
                local tab = _G["ChatFrame"..i.."Tab"]
                if tab then
                    tab:SetAlpha(0) -- Ocultar inicialmente
                    tab:SetScript("OnEnter", function(self)
                        UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
                    end)
                    tab:SetScript("OnLeave", function(self)
                        UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0)
                    end)
                end
            end

            -- Estilo Visual Minimalista (Fondo negro y borde fino)
            if CONFIG.CHAT_STYLE then
                -- Desactivar texturas background originales si molestan
                local bg = _G["ChatFrame"..i.."Background"]
                if bg then bg:Hide() end

                -- Crear nuestro propio marco de fondo limpio
                if not chatFrame.cleanBackdrop then
                    local backdrop = CreateFrame("Frame", nil, chatFrame, "BackdropTemplate")
                    backdrop:SetPoint("TOPLEFT", -2, 2)
                    backdrop:SetPoint("BOTTOMRIGHT", 2, -2)
                    backdrop:SetFrameLevel(chatFrame:GetFrameLevel() - 1)
                    
                    backdrop:SetBackdrop({
                        bgFile = "Interface\\Buttons\\WHITE8x8",
                        edgeFile = nil, 
                        tile = false, tileSize = 0, edgeSize = 0,
                        insets = { left = 5, right = 5, top = 5, bottom = 5 }
                    })
                    backdrop:SetBackdropColor(0, 0, 0, 0.3)      -- Fondo negro suave y sin borde
                    backdrop:SetBackdropBorderColor(0, 0, 0, 0)
                    
                    chatFrame.cleanBackdrop = backdrop
                end
            end
            
            -- Fuente Personalizada
            local fontFile = GetFontPath(CONFIG.FONT_NAME)
            -- Aseguramos que se aplique (Convertir NONE a "")
            local flags = CONFIG.FONT_OUTLINE
            if flags == "NONE" then flags = "" end
            
            chatFrame:SetFont(fontFile, CONFIG.FONT_SIZE, flags)
            
            -- Espaciado entre líneas para que respire
            chatFrame:SetSpacing(2)
            -- Forzamos actualización si es necesario
            chatFrame:SetShadowOffset(1, -1)
            chatFrame:SetShadowColor(0, 0, 0, 0.5)

            -- Ocultar Botones y Scrollbar
            if CONFIG.HIDE_BUTTONS then
                if buttonFrame then
                    buttonFrame:Hide()
                    buttonFrame:SetScript("OnShow", buttonFrame.Hide)
                end
                if scrollBar then
                    scrollBar:Hide()
                    scrollBar:SetScript("OnShow", scrollBar.Hide)
                end
            end
            
            -- Navegación con Flechas (Estilo clásico/Prat)
            if CONFIG.ARROW_KEYS and editBox then
                editBox:SetAltArrowKeyMode(false)
            end

            -- Caja de Texto: Estilo Limpio (Sin fondo)
            if editBox then
                -- Quitamos texturas de fondo de la caja para que sea más limpia
                local left = _G["ChatFrame"..i.."EditBoxLeft"]
                local mid = _G["ChatFrame"..i.."EditBoxMid"]
                local right = _G["ChatFrame"..i.."EditBoxRight"]
                if left then left:Hide() end
                if mid then mid:Hide() end
                if right then right:Hide() end
                
                -- Posición: Parte inferior (Estándar pero limpio)
                if CONFIG.TOP_EDITBOX then
                     editBox:ClearAllPoints()
                     editBox:SetPoint("BOTTOMLEFT", chatFrame, "TOPLEFT", -5, 30)
                     editBox:SetPoint("BOTTOMRIGHT", chatFrame, "TOPRIGHT", 5, 30)
                else
                    -- Si está abajo, aseguramos que respete el estilo
                    -- No cambiamos points si no es necesario para mantener compatibilidad
                    -- pero podemos ajustar si queda mal
                end
            end
        end

    -- Ocultar Botón de Menú y Canal
        if CONFIG.HIDE_BUTTONS then
            if ChatFrameMenuButton then
                ChatFrameMenuButton:Hide()
                ChatFrameMenuButton:SetScript("OnShow", ChatFrameMenuButton.Hide)
            end
            if ChatFrameChannelButton then
                ChatFrameChannelButton:Hide()
                ChatFrameChannelButton:SetScript("OnShow", ChatFrameChannelButton.Hide)
            end
            if QuickJoinToastButton then
                QuickJoinToastButton:Hide()
                QuickJoinToastButton:SetScript("OnShow", QuickJoinToastButton.Hide)
            end
        end

        -- 4. Modificaciones Estilo Prat
        if CONFIG.SHORT_CHANNELS then
            CHAT_GUILD_GET = "|Hchannel:GUILD|h[G]|h %s: "
            CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[O]|h %s: "
            CHAT_PARTY_GET = "|Hchannel:PARTY|h[P]|h %s: "
            CHAT_PARTY_LEADER_GET = "|Hchannel:PARTY|h[PL]|h %s: "
            CHAT_PARTY_GUIDE_GET = "|Hchannel:PARTY|h[PG]|h %s: "
            CHAT_RAID_GET = "|Hchannel:RAID|h[R]|h %s: "
            CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[RL]|h %s: "
            CHAT_RAID_WARNING_GET = "[RW] %s: "
            CHAT_BATTLEGROUND_GET = "|Hchannel:BATTLEGROUND|h[BG]|h %s: "
            CHAT_BATTLEGROUND_LEADER_GET = "|Hchannel:BATTLEGROUND|h[BGL]|h %s: "
        end
        
        if CONFIG.STICKY_CHANNELS then
            ChatTypeInfo["CHANNEL"].sticky = 1
            ChatTypeInfo["GUILD"].sticky = 1
            ChatTypeInfo["OFFICER"].sticky = 1
            ChatTypeInfo["PARTY"].sticky = 1
            ChatTypeInfo["RAID"].sticky = 1
            ChatTypeInfo["SAY"].sticky = 1
            ChatTypeInfo["YELL"].sticky = 0
            ChatTypeInfo["WHISPER"].sticky = 1
            ChatTypeInfo["BN_WHISPER"].sticky = 1
        end
        
        print("|cff00ff00CleanChat cargado. Usa /cc clear para limpiar.|r")
    end
end)



-- --- GUI de Configuración ---
local ConfigPanel = CreateFrame("Frame", "CleanChatConfigPanel", UIParent)
ConfigPanel.name = "CleanChat"
local category = Settings.RegisterCanvasLayoutCategory(ConfigPanel, "CleanChat")
Settings.RegisterAddOnCategory(category)

local function CreateTitle(text, relativeTo)
    local fs = ConfigPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    fs:SetPoint("TOPLEFT", relativeTo or ConfigPanel, "TOPLEFT", 16, -16)
    fs:SetText(text)
    return fs
end

local title = CreateTitle("CleanChat Configuración")

-- Limitación de WoW: No podemos leer archivos de la carpeta Fonts automáticamente.
-- Ponemos una lista manual de las fuentes populares que recomendaste.
local PRESET_FONTS = {
    "Arial", "Friz", "Skurri", "Morpheus", 
    "Roboto", "Expressway", "Montserrat", "OpenSans",
    "Caveat", "Ewert", "Jersey", "Sixtyfour"
}

-- Dropdown simple (implementación básica sin librerías)
local function CreateFontDropdown()
    local drop = CreateFrame("Frame", "CleanChatFontDrop", ConfigPanel, "UIDropDownMenuTemplate")
    drop:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -15, -30)
    
    UIDropDownMenu_SetWidth(drop, 150)
    UIDropDownMenu_SetText(drop, CONFIG.FONT_NAME)
    
    UIDropDownMenu_Initialize(drop, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(self)
            CONFIG.FONT_NAME = self.value
            UIDropDownMenu_SetText(drop, self.value)
            -- Aplicar cambios (requiere reload para fuentes custom, pero podemos intentar setear si es standard)
            print("|cff00ffffCleanChat|r: Fuente seleccionada: "..self.value..". Haz /reload.")
        end
        
        for _, f in ipairs(PRESET_FONTS) do
            info.text = f
            info.value = f
            info.checked = (CONFIG.FONT_NAME == f)
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    local label = drop:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", drop, "TOPLEFT", 16, 3)
    label:SetText("Fuente (Requiere /reload)")
end

-- EditBox para fuente custom
local function CreateCustomFontBox()
    local eb = CreateFrame("EditBox", "CleanChatCustomFont", ConfigPanel, "InputBoxTemplate")
    eb:SetSize(150, 30)
    eb:SetPoint("TOPLEFT", "CleanChatFontDrop", "BOTTOMLEFT", 20, -30)
    eb:SetAutoFocus(false)
    eb:SetScript("OnEnterPressed", function(self)
        CONFIG.FONT_NAME = self:GetText()
        self:ClearFocus()
        print("|cff00ffffCleanChat|r: Fuente custom establecida: "..CONFIG.FONT_NAME..". Haz /reload.")
    end)
    eb:SetScript("OnShow", function(self) self:SetText(CONFIG.FONT_NAME) end)
    
    local label = eb:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", eb, "TOPLEFT", 0, 3)
    label:SetText("O escribe nombre de archivo (.ttf):")
end

-- Botón Reload
local function CreateReloadBtn()
    local btn = CreateFrame("Button", nil, ConfigPanel, "GameMenuButtonTemplate")
    btn:SetPoint("TOPLEFT", "CleanChatCustomFont", "BOTTOMLEFT", -20, -40)
    btn:SetSize(120, 30)
    btn:SetText("Aplicar (/reload)")
    btn:SetScript("OnClick", ReloadUI)
end

ConfigPanel:SetScript("OnShow", function()
    CreateFontDropdown()
    CreateCustomFontBox()
    CreateReloadBtn()
    ConfigPanel:SetScript("OnShow", nil) -- Solo crear una vez
end)

-- Slash Command abre panel
SLASH_CLEANCHATCONFIG1 = "/cc config"
SLASH_CLEANCHATCONFIG2 = "/cleanopt"
SlashCmdList["CLEANCHATCONFIG"] = function()
    Settings.OpenToCategory(category:GetID())
end

-- Slash Command para limpiar el chat
SLASH_CLEANCHAT1 = "/cleanchat"
SLASH_CLEANCHAT2 = "/cc"
SlashCmdList["CLEANCHAT"] = function(msg)
    local cmd, arg = strsplit(" ", msg, 2)
    cmd = string.lower(cmd or "")

    if cmd == "clear" then
        for i = 1, NUM_CHAT_WINDOWS do
            local f = _G["ChatFrame"..i]
            if f then f:Clear() end
        end
    elseif cmd == "size" and tonumber(arg) then
        CONFIG.FONT_SIZE = tonumber(arg)
        print("|cff00ffffCleanChat|r: Tamaño de fuente cambiado a "..arg..". Haz /reload.")
    elseif cmd == "outline" then
        if CONFIG.FONT_OUTLINE == "NONE" then CONFIG.FONT_OUTLINE = "OUTLINE"
        elseif CONFIG.FONT_OUTLINE == "OUTLINE" then CONFIG.FONT_OUTLINE = "THICKOUTLINE"
        else CONFIG.FONT_OUTLINE = "NONE" end
        print("|cff00ffffCleanChat|r: Contorno cambiado a "..CONFIG.FONT_OUTLINE..". Haz /reload.")
    elseif cmd == "font" then
        if arg then
            CONFIG.FONT_NAME = arg
            print("|cff00ffffCleanChat|r: Fuente cambiada a '"..arg.."'.")
            print("Asegúrate de que el archivo '"..arg..".ttf' esté en la carpeta CleanChat/Fonts.")
            print("Haz /reload para aplicar.")
        else
            print("|cff00ffffCleanChat|r Fuentes:")
            print("- Integradas: Friz, Arial, Skurri, Morpheus")
            print("- Propias: Pon el archivo .ttf en la carpeta CleanChat/Fonts y escribe su nombre.")
            print("  Ej: Si tienes 'Batman.ttf', escribe: /cc font Batman")
        end
    elseif cmd == "config" or cmd == "options" then
        Settings.OpenToCategory(category:GetID())
    else
        print("|cff00ffffCleanChat|r Comandos:")
        print("  /cc config  - Abrir MENÚ DE OPCIONES")
        print("  /cc clear   - Limpiar chat")
        print("  /cc size N  - Cambiar tamaño")
        print("  /cc font X  - Cambiar fuente")
        print("  /cc outline - Alternar contorno")
    end
end
