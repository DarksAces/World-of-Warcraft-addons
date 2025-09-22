local TimeTracker = CreateFrame("Frame")
TimeTracker:RegisterEvent("ADDON_LOADED")
TimeTracker:RegisterEvent("PLAYER_LOGIN")
TimeTracker:RegisterEvent("PLAYER_LOGOUT")
TimeTracker:RegisterEvent("TIME_PLAYED_MSG")

-- Variables globales
local playerName = ""
local realmName = ""
local playerKey = ""
local sessionStartTime = 0
local lastUpdateTime = 0
local isRequestingTime = false

-- Localization system
local L = {}
local locale = GetLocale()

-- English (default)
L["en"] = {
    ADDON_NAME = "Time Tracker",
    SHOW_HIDE_WINDOW = "Show/hide main window",
    GET_TIME_PLAYED = "Get total time played",
    QUICK_STATS = "View quick stats in chat",
    FORMAT_INFO = "View time format information",
    COMMANDS_AVAILABLE = "Available commands:",
    ADDON_LOADED = "Time Tracker v2.0 loaded. Use /timetrack to open the window.",
    WELCOME = "Welcome %s! Use /timetrack to view your statistics.",
    GETTING_TIME = "Getting total time played...",
    QUICK_STATS_TITLE = "Quick Statistics:",
    TOTAL = "Total",
    TODAY = "Today",
    THIS_WEEK = "This Week",
    THIS_MONTH = "This Month",
    NO_DATA = "No data available. Use /timetrack time to get information.",
    FORMATS_AVAILABLE = "Available formats:",
    FORMAT_HOURS = "hours - Only shows total hours",
    FORMAT_MINUTES = "minutes - Only shows total minutes", 
    FORMAT_SECONDS = "seconds - Only shows total seconds",
    FORMAT_COMPLETE = "complete - Complete format (days, hours, minutes)",
    CURRENT_FORMAT = "Current format:",
    CHANGE_FORMAT = "Change format from the GUI (/timetrack show)",
    CURRENT_CHARACTER = "Current Character",
    ACCOUNT = "Account",
    TIME_FORMAT = "Time format:",
    ONLY_HOURS = "Hours Only",
    ONLY_MINUTES = "Minutes Only",
    ONLY_SECONDS = "Seconds Only",
    COMPLETE_FORMAT = "Complete Format",
    MAIN_STATS = "--- Main Statistics ---",
    TOTAL_TIME = "Total Time",
    LEVEL_TIME = "Time at Level %d",
    PLAY_TIME = "--- Play Time ---",
    TODAY_LABEL = "Today",
    THIS_WEEK_LABEL = "This Week",
    THIS_MONTH_LABEL = "This Month",
    LAST_7_DAYS = "--- Last 7 Days ---",
    CURRENT_SESSION = "--- Current Session ---",
    LAST_LOGIN = "Last login",
    UNKNOWN = "Unknown",
    GENERAL_SUMMARY = "--- General Summary ---",
    TOTAL_ALL_CHARS = "Total Time All Characters",
    NUMBER_OF_CHARS = "Number of Characters",
    AVERAGE_PER_CHAR = "Average per Character",
    NO_CHARS_REGISTERED = "No characters registered in database",
    DAILY_TOTAL_ACCOUNT = "--- Daily Total Account (Last 7 Days) ---",
    CHARACTER_RANKING = "--- Character Ranking ---",
    CURRENT = "CURRENT",
    PLAYED_TODAY = "Played today",
    LEVEL = "Level",
    TIME_COLON = "Time:",
    OF_TOTAL = "of total"
}

-- Spanish
L["es"] = {
    ADDON_NAME = "Time Tracker",
    SHOW_HIDE_WINDOW = "Mostrar/ocultar ventana principal",
    GET_TIME_PLAYED = "Obtener tiempo total jugado",
    QUICK_STATS = "Ver estadísticas rápidas en chat",
    FORMAT_INFO = "Ver información sobre formatos de tiempo",
    COMMANDS_AVAILABLE = "Comandos disponibles:",
    ADDON_LOADED = "Time Tracker v2.0 cargado. Usa /timetrack para abrir la ventana.",
    WELCOME = "¡Bienvenido %s! Usa /timetrack para ver tus estadísticas.",
    GETTING_TIME = "Obteniendo tiempo total jugado...",
    QUICK_STATS_TITLE = "Estadísticas rápidas:",
    TOTAL = "Total",
    TODAY = "Hoy",
    THIS_WEEK = "Esta semana",
    THIS_MONTH = "Este mes",
    NO_DATA = "No hay datos disponibles. Usa /timetrack time para obtener información.",
    FORMATS_AVAILABLE = "Formatos disponibles:",
    FORMAT_HOURS = "hours - Solo muestra horas totales",
    FORMAT_MINUTES = "minutes - Solo muestra minutos totales",
    FORMAT_SECONDS = "seconds - Solo muestra segundos totales",
    FORMAT_COMPLETE = "complete - Formato completo (días, horas, minutos)",
    CURRENT_FORMAT = "Formato actual:",
    CHANGE_FORMAT = "Cambia el formato desde la interfaz gráfica (/timetrack show)",
    CURRENT_CHARACTER = "Personaje Actual",
    ACCOUNT = "Cuenta",
    TIME_FORMAT = "Formato de tiempo:",
    ONLY_HOURS = "Solo Horas",
    ONLY_MINUTES = "Solo Minutos",
    ONLY_SECONDS = "Solo Segundos",
    COMPLETE_FORMAT = "Formato Completo",
    MAIN_STATS = "--- Estadisticas Principales ---",
    TOTAL_TIME = "Tiempo Total",
    LEVEL_TIME = "Tiempo en Nivel %d",
    PLAY_TIME = "--- Tiempo de Juego ---",
    TODAY_LABEL = "Hoy",
    THIS_WEEK_LABEL = "Esta Semana",
    THIS_MONTH_LABEL = "Este Mes",
    LAST_7_DAYS = "--- Ultimos 7 Dias ---",
    CURRENT_SESSION = "--- Sesion Actual ---",
    LAST_LOGIN = "Último login",
    UNKNOWN = "Desconocido",
    GENERAL_SUMMARY = "--- Resumen General ---",
    TOTAL_ALL_CHARS = "Tiempo Total de Todos los Personajes",
    NUMBER_OF_CHARS = "Número de Personajes",
    AVERAGE_PER_CHAR = "Promedio por Personaje",
    NO_CHARS_REGISTERED = "No hay personajes registrados en la base de datos",
    DAILY_TOTAL_ACCOUNT = "--- Tiempo Diario Total Cuenta (Últimos 7 Días) ---",
    CHARACTER_RANKING = "--- Ranking de Personajes ---",
    CURRENT = "ACTUAL",
    PLAYED_TODAY = "Jugado hoy",
    LEVEL = "Nivel",
    TIME_COLON = "Tiempo:",
    OF_TOTAL = "del total"
}

-- Get localized string function
local function GetLocalizedText(key)
    local currentLocale = locale
    if locale == "esES" or locale == "esMX" then
        currentLocale = "es"
    elseif locale ~= "en" then
        currentLocale = "en" -- fallback to English
    end
    
    return L[currentLocale] and L[currentLocale][key] or L["en"][key] or key
end

-- Base de datos por defecto
local defaultDB = {
    characters = {},
    settings = {
        showOnLogin = true,
        updateInterval = 300, -- 5 minutos
        timeFormat = "complete" -- "hours", "minutes", "seconds", "complete"
    }
}

-- Funciones auxiliares
local function GetCurrentDate()
    return date("%Y-%m-%d")
end

local function GetCurrentWeek()
    local t = date("*t")
    local dayOfWeek = t.wday == 1 and 7 or t.wday - 1
    local startOfWeek = time(t) - (dayOfWeek - 1) * 24 * 60 * 60
    return date("%Y-W%U", startOfWeek)
end

local function GetCurrentMonth()
    return date("%Y-%m")
end

local function FormatTime(seconds, format)
    if not seconds or seconds <= 0 then
        if format == "hours" then return "0h"
        elseif format == "minutes" then return "0m"
        elseif format == "seconds" then return "0s"
        else return "0m" end
    end
    
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    
    if format == "hours" then
        return math.floor(seconds / 3600) .. "h"
    elseif format == "minutes" then
        return math.floor(seconds / 60) .. "m"
    elseif format == "seconds" then
        return seconds .. "s"
    else -- formato completo
        local result = ""
        if days > 0 then
            result = result .. days .. "d "
        end
        if hours > 0 then
            result = result .. hours .. "h "
        end
        if minutes > 0 or result == "" then
            result = result .. minutes .. "m"
        end
        return result:match("^%s*(.-)%s*$") -- trim spaces
    end
end

-- Inicializar personaje en la base de datos
local function InitializeCharacter()
    if not TimeTrackerDB.characters[playerKey] then
        TimeTrackerDB.characters[playerKey] = {
            name = playerName,
            realm = realmName,
            class = UnitClass("player"),
            level = UnitLevel("player"),
            totalTime = 0,
            levelTime = 0,
            daily = {},
            weekly = {},
            monthly = {},
            sessions = {},
            lastLogin = time(),
            firstLogin = time(),
            baseTime = nil,
            lastKnownTime = nil
        }
    else
        local char = TimeTrackerDB.characters[playerKey]
        char.level = UnitLevel("player")
        char.lastLogin = time()
        if not char.firstLogin then char.firstLogin = time() end
        if not char.lastKnownTime then char.lastKnownTime = char.totalTime or 0 end
    end
end

-- Actualizar tiempo jugado
local function UpdatePlayTime(totalTime, levelTime)
    if not totalTime or totalTime == 0 then return end
    
    local char = TimeTrackerDB.characters[playerKey]
    if not char then return end
    
    local currentDate = GetCurrentDate()
    local currentWeek = GetCurrentWeek()
    local currentMonth = GetCurrentMonth()
    local currentTime = time()
    
    char.totalTime = totalTime
    char.levelTime = levelTime or 0
    
    if not char.baseTime then
        char.baseTime = totalTime
        char.lastKnownTime = totalTime
    end
    
    local timePlayed = 0
    if char.lastKnownTime and totalTime > char.lastKnownTime then
        timePlayed = totalTime - char.lastKnownTime
    end
    
    char.daily[currentDate] = char.daily[currentDate] or 0
    char.weekly[currentWeek] = char.weekly[currentWeek] or 0
    char.monthly[currentMonth] = char.monthly[currentMonth] or 0
    
    if timePlayed > 0 and timePlayed < 7200 then
        char.daily[currentDate] = char.daily[currentDate] + timePlayed
        char.weekly[currentWeek] = char.weekly[currentWeek] + timePlayed
        char.monthly[currentMonth] = char.monthly[currentMonth] + timePlayed
        char.lastKnownTime = totalTime
    end
    
    lastUpdateTime = currentTime
end

-- Suma el tiempo jugado diario de todos los personajes y devuelve un diccionario {fecha => segundos}
local function GetAccountDailyTotals()
    local totals = {}
    for _, char in pairs(TimeTrackerDB.characters) do
        if char.daily then
            for dateStr, seconds in pairs(char.daily) do
                totals[dateStr] = (totals[dateStr] or 0) + seconds
            end
        end
    end
    return totals
end

-- Crear dropdown para formato de tiempo
local function CreateTimeFormatDropdown(parent, xOffset, yOffset)
    local dropdown = CreateFrame("Button", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    UIDropDownMenu_SetWidth(dropdown, 150)
    UIDropDownMenu_SetText(dropdown, GetLocalizedText("COMPLETE_FORMAT"))
    
    local function OnClick(self, arg1, arg2)
        TimeTrackerDB.settings.timeFormat = arg1
        UIDropDownMenu_SetText(dropdown, arg2)
        if TimeTrackerFrame and TimeTrackerFrame:IsShown() then
            if TimeTrackerFrame.tabPersonal.selected then
                UpdateCurrentCharacterStats(TimeTrackerFrame)
            else
                UpdateAccountStats(TimeTrackerFrame)
            end
        end
    end
    
    local function Initialize()
        local info = UIDropDownMenu_CreateInfo()
        info.func = OnClick

        info.text = GetLocalizedText("ONLY_HOURS")
        info.arg1 = "hours"
        info.arg2 = GetLocalizedText("ONLY_HOURS")
        info.checked = (TimeTrackerDB.settings.timeFormat == "hours")
        UIDropDownMenu_AddButton(info)
        
        info.text = GetLocalizedText("ONLY_MINUTES")
        info.arg1 = "minutes"
        info.arg2 = GetLocalizedText("ONLY_MINUTES")
        info.checked = (TimeTrackerDB.settings.timeFormat == "minutes")
        UIDropDownMenu_AddButton(info)
        
        info.text = GetLocalizedText("ONLY_SECONDS")
        info.arg1 = "seconds"
        info.arg2 = GetLocalizedText("ONLY_SECONDS")
        info.checked = (TimeTrackerDB.settings.timeFormat == "seconds")
        UIDropDownMenu_AddButton(info)
        
        info.text = GetLocalizedText("COMPLETE_FORMAT")
        info.arg1 = "complete"
        info.arg2 = GetLocalizedText("COMPLETE_FORMAT")
        info.checked = (TimeTrackerDB.settings.timeFormat == "complete")
        UIDropDownMenu_AddButton(info)
    end
    
    UIDropDownMenu_Initialize(dropdown, Initialize)
    return dropdown
end

-- Crear ventana principal y frames
local function CreateMainFrame()
    local frame = CreateFrame("Frame", "TimeTrackerFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(500, 600)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlightLarge")
    frame.title:SetPoint("TOP", frame.TitleBg, "TOP", 0, -5)
    frame.title:SetText(GetLocalizedText("ADDON_NAME"))

    -- FontStrings reutilizables
    frame.accountFontStrings = {}
    frame.characterFontStrings = {}

    -- Pestañas
    frame.tabPersonal = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.tabPersonal:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -25)
    frame.tabPersonal:SetText(GetLocalizedText("CURRENT_CHARACTER"))
    frame.tabPersonal:SetSize(120, 25)
    frame.tabPersonal.selected = true

    frame.tabCuenta = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.tabCuenta:SetPoint("LEFT", frame.tabPersonal, "RIGHT", 5, 0)
    frame.tabCuenta:SetText(GetLocalizedText("ACCOUNT"))
    frame.tabCuenta:SetSize(80, 25)
    frame.tabCuenta.selected = false

    -- Panel Personaje Actual
    frame.personalPanel = CreateFrame("Frame", nil, frame)
    frame.personalPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.personalPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.personalPanel:Show()

    frame.personalFormatLabel = frame.personalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.personalFormatLabel:SetPoint("TOPLEFT", frame.personalPanel, "TOPLEFT", 10, -10)
    frame.personalFormatLabel:SetText(GetLocalizedText("TIME_FORMAT"))
    frame.personalFormatLabel:SetTextColor(1, 1, 1)

    frame.personalFormatDropdown = CreateTimeFormatDropdown(frame.personalPanel, 5, -30)

    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame.personalPanel, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", frame.personalFormatDropdown, "BOTTOMLEFT", 0, -20)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame.personalPanel, "BOTTOMRIGHT", -20, 5)

    frame.content = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.content:SetSize(430, 450)
    frame.scrollFrame:SetScrollChild(frame.content)

    -- Panel Cuenta
    frame.cuentaPanel = CreateFrame("Frame", nil, frame)
    frame.cuentaPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.cuentaPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.cuentaPanel:Hide()

    frame.cuentaFormatLabel = frame.cuentaPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.cuentaFormatLabel:SetPoint("TOPLEFT", frame.cuentaPanel, "TOPLEFT", 10, -10)
    frame.cuentaFormatLabel:SetText(GetLocalizedText("TIME_FORMAT"))
    frame.cuentaFormatLabel:SetTextColor(1, 1, 1)

    frame.cuentaFormatDropdown = CreateTimeFormatDropdown(frame.cuentaPanel, 5, -30)

    frame.cuentaScrollFrame = CreateFrame("ScrollFrame", nil, frame.cuentaPanel, "UIPanelScrollFrameTemplate")
    frame.cuentaScrollFrame:SetPoint("TOPLEFT", frame.cuentaFormatDropdown, "BOTTOMLEFT", 0, -20)
    frame.cuentaScrollFrame:SetPoint("BOTTOMRIGHT", frame.cuentaPanel, "BOTTOMRIGHT", -20, 5)

    frame.cuentaContent = CreateFrame("Frame", nil, frame.cuentaScrollFrame)
    frame.cuentaContent:SetSize(450, 500)
    frame.cuentaScrollFrame:SetScrollChild(frame.cuentaContent)

    -- Estilo pestañas
    local function UpdateTabAppearance()
        if frame.tabPersonal.selected then
            frame.tabPersonal:SetButtonState("PUSHED", true)
            frame.tabPersonal:SetAlpha(1)
            frame.tabCuenta:SetButtonState("NORMAL", false)
            frame.tabCuenta:SetAlpha(0.7)
        else
            frame.tabPersonal:SetButtonState("NORMAL", false)
            frame.tabPersonal:SetAlpha(0.7)
            frame.tabCuenta:SetButtonState("PUSHED", true)
            frame.tabCuenta:SetAlpha(1)
        end
    end

    -- Scripts pestañas
    frame.tabPersonal:SetScript("OnClick", function()
        frame.tabPersonal.selected = true
        frame.tabCuenta.selected = false
        UpdateTabAppearance()
        frame.personalPanel:Show()
        frame.cuentaPanel:Hide()
        UpdateCurrentCharacterStats(frame)
    end)

    frame.tabCuenta:SetScript("OnClick", function()
        frame.tabPersonal.selected = false
        frame.tabCuenta.selected = true
        UpdateTabAppearance()
        frame.personalPanel:Hide()
        frame.cuentaPanel:Show()
        UpdateAccountStats(frame)
    end)

    UpdateTabAppearance()

    return frame
end

-- Actualizar estadísticas del personaje actual
function UpdateCurrentCharacterStats(frame)
    local char = TimeTrackerDB.characters[playerKey]
    local format = TimeTrackerDB.settings.timeFormat
    local yOffset = -10

    frame.characterFontStrings = frame.characterFontStrings or {}

    if not char then
        for _, fs in pairs(frame.characterFontStrings) do fs:Hide() end
        if not frame.noDataText then
            frame.noDataText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            frame.noDataText:SetPoint("CENTER", frame.content, "CENTER", 0, 0)
            frame.noDataText:SetTextColor(1, 0.5, 0)
        end
        frame.noDataText:SetText(GetLocalizedText("NO_DATA"))
        frame.noDataText:Show()
        return
    end
    if frame.noDataText then frame.noDataText:Hide() end

    for _, fs in pairs(frame.characterFontStrings) do fs:Hide() end

    local function CreateOrReuse(index, font)
        local fs = frame.characterFontStrings[index]
        if not fs then
            fs = frame.content:CreateFontString(nil, "OVERLAY", font)
            frame.characterFontStrings[index] = fs
        end
        fs:Show()
        return fs
    end

    local nameText = CreateOrReuse(1, "GameFontHighlightLarge")
    nameText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 10, yOffset)
    nameText:SetText(char.name .. " - " .. char.realm)
    nameText:SetTextColor(1, 1, 1)
    yOffset = yOffset - 25

    local classText = CreateOrReuse(2, "GameFontHighlight")
    classText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 10, yOffset)
    classText:SetText(GetLocalizedText("LEVEL") .. " " .. (char.level or "?") .. " " .. (char.class or ""))
    classText:SetTextColor(0.8, 0.8, 0.8)
    yOffset = yOffset - 40

    local mainStatsTitle = CreateOrReuse(3, "GameFontNormalLarge")
    mainStatsTitle:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 10, yOffset)
    mainStatsTitle:SetText(GetLocalizedText("MAIN_STATS"))
    mainStatsTitle:SetTextColor(1, 0.8, 0)
    yOffset = yOffset - 25

    local totalText = CreateOrReuse(4, "GameFontHighlight")
    totalText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    totalText:SetText(GetLocalizedText("TOTAL_TIME") .. ": " .. FormatTime(char.totalTime, format))
    totalText:SetTextColor(1, 1, 0)
    yOffset = yOffset - 20

    local levelText = CreateOrReuse(5, "GameFontHighlight")
    levelText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    levelText:SetText(string.format(GetLocalizedText("LEVEL_TIME"), char.level or 0) .. ": " .. FormatTime(char.levelTime or 0, format))
    levelText:SetTextColor(0.8, 0.8, 1)
    yOffset = yOffset - 35

    local timeStatsTitle = CreateOrReuse(6, "GameFontNormalLarge")
    timeStatsTitle:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 10, yOffset)
    timeStatsTitle:SetText(GetLocalizedText("PLAY_TIME"))
    timeStatsTitle:SetTextColor(0, 1, 1)
    yOffset = yOffset - 25

    local todayTime = char.daily[GetCurrentDate()] or 0
    local todayText = CreateOrReuse(7, "GameFontHighlight")
    todayText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    todayText:SetText(GetLocalizedText("TODAY_LABEL") .. ": " .. FormatTime(todayTime, format))
    todayText:SetTextColor(0, 1, 0)
    yOffset = yOffset - 20

    local weekTime = char.weekly[GetCurrentWeek()] or 0
    local weekText = CreateOrReuse(8, "GameFontHighlight")
    weekText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    weekText:SetText(GetLocalizedText("THIS_WEEK_LABEL") .. ": " .. FormatTime(weekTime, format))
    weekText:SetTextColor(0, 0.8, 1)
    yOffset = yOffset - 20

    local monthTime = char.monthly[GetCurrentMonth()] or 0
    local monthText = CreateOrReuse(9, "GameFontHighlight")
    monthText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    monthText:SetText(GetLocalizedText("THIS_MONTH_LABEL") .. ": " .. FormatTime(monthTime, format))
    monthText:SetTextColor(1, 0, 1)
    yOffset = yOffset - 35

    local historyTitle = CreateOrReuse(10, "GameFontNormalLarge")
    historyTitle:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 10, yOffset)
    historyTitle:SetText(GetLocalizedText("LAST_7_DAYS"))
    historyTitle:SetTextColor(1, 0.6, 1)
    yOffset = yOffset - 25

    local today = time()
    frame.dayFontStrings = frame.dayFontStrings or {}
    for i = 1, 7 do
        local fs = frame.dayFontStrings[i]
        if not fs then
            fs = frame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            frame.dayFontStrings[i] = fs
        end
        fs:Show()

        local dateStr = date("%Y-%m-%d", today - (7 - i) * 86400)
        local dayTime = char.daily[dateStr] or 0
        local dayName = date("%a", today - (7 - i) * 86400)
        local isToday = (i == 7)

        fs:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 25, yOffset)
        fs:SetText(dayName .. " (" .. dateStr .. "): " .. FormatTime(dayTime, format))
        if isToday then
            fs:SetTextColor(0, 1, 0)
        elseif dayTime > 0 then
            fs:SetTextColor(0.9, 0.9, 0.9)
        else
            fs:SetTextColor(0.5, 0.5, 0.5)
        end
        yOffset = yOffset - 18
    end
    -- Ocultar sobrantes de días si hay más
    for i = 8, #(frame.dayFontStrings or {}) do
        frame.dayFontStrings[i]:Hide()
    end

    yOffset = yOffset - 15

    local sessionTitle = CreateOrReuse(11, "GameFontNormalLarge")
    sessionTitle:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 10, yOffset)
    sessionTitle:SetText(GetLocalizedText("CURRENT_SESSION"))
    sessionTitle:SetTextColor(1, 0.5, 0)
    yOffset = yOffset - 25

    local loginTime = CreateOrReuse(12, "GameFontNormal")
    loginTime:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    if char.lastLogin then
        loginTime:SetText(GetLocalizedText("LAST_LOGIN") .. ": " .. date("%Y-%m-%d %H:%M:%S", char.lastLogin))
    else
        loginTime:SetText(GetLocalizedText("LAST_LOGIN") .. ": " .. GetLocalizedText("UNKNOWN"))
    end
    loginTime:SetTextColor(0.8, 0.8, 0.8)

    -- Ajustar contenido para scroll
    local minHeight = 450
    local neededHeight = math.abs(yOffset) + 50
    frame.content:SetHeight(math.max(minHeight, neededHeight))
end

-- Actualizar estadísticas de cuenta
function UpdateAccountStats(frame)
    local format = TimeTrackerDB.settings.timeFormat
    local characters = {}
    local totalAccountTime, characterCount = 0, 0

    for key, char in pairs(TimeTrackerDB.characters) do
        totalAccountTime = totalAccountTime + (char.totalTime or 0)
        characterCount = characterCount + 1
        table.insert(characters, {key = key, char = char, totalTime = char.totalTime or 0})
    end
    table.sort(characters, function(a,b) return a.totalTime > b.totalTime end)

    frame.accountFontStrings = frame.accountFontStrings or {}
    frame.accountDailyFontStrings = frame.accountDailyFontStrings or {}

    -- Ocultar FontStrings existentes
    for _, fsGroup in ipairs(frame.accountFontStrings) do
        for _, fs in ipairs(fsGroup) do fs:Hide() end
    end
    for _, fs in ipairs(frame.accountDailyFontStrings) do
        fs:Hide()
    end

    local yOffset = -10

    -- Títulos y resumen
    if not frame.summaryTitle then
        frame.summaryTitle = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.summaryTitle:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 10, yOffset)
        frame.summaryTitle:SetText(GetLocalizedText("GENERAL_SUMMARY"))
        frame.summaryTitle:SetTextColor(0,1,1)
    end
    frame.summaryTitle:Show()
    yOffset = yOffset - 25

    if not frame.summaryTotalTime then
        frame.summaryTotalTime = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.summaryTotalTime:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 20, yOffset)
    end
    frame.summaryTotalTime:SetText(GetLocalizedText("TOTAL_ALL_CHARS") .. ": " .. FormatTime(totalAccountTime, format))
    frame.summaryTotalTime:SetTextColor(1, 1, 0)
    frame.summaryTotalTime:Show()
    yOffset = yOffset - 20

    if not frame.summaryCharCount then
        frame.summaryCharCount = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.summaryCharCount:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 20, yOffset)
    end
    frame.summaryCharCount:SetText(GetLocalizedText("NUMBER_OF_CHARS") .. ": " .. characterCount)
    frame.summaryCharCount:SetTextColor(0.8, 0.8, 0.8)
    frame.summaryCharCount:Show()
    yOffset = yOffset - 20

    if not frame.summaryAvgTime then
        frame.summaryAvgTime = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.summaryAvgTime:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 20, yOffset)
    end
    local avgTime = characterCount > 0 and (totalAccountTime / characterCount) or 0
    frame.summaryAvgTime:SetText(GetLocalizedText("AVERAGE_PER_CHAR") .. ": " .. FormatTime(avgTime, format))
    frame.summaryAvgTime:SetTextColor(0.8, 0.8, 0.8)
    frame.summaryAvgTime:Show()
    yOffset = yOffset - 35

    if characterCount == 0 then
        if not frame.noDataText then
            frame.noDataText = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            frame.noDataText:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 10, yOffset)
            frame.noDataText:SetTextColor(1, 0.5, 0)
        end
        frame.noDataText:SetText(GetLocalizedText("NO_CHARS_REGISTERED"))
        frame.noDataText:Show()
        return
    elseif frame.noDataText then
        frame.noDataText:Hide()
    end

    -- Mostrar totales diarios combinados cuenta (últimos 7 días)
    if not frame.accountDailyTitle then
        frame.accountDailyTitle = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.accountDailyTitle:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 10, yOffset)
        frame.accountDailyTitle:SetText(GetLocalizedText("DAILY_TOTAL_ACCOUNT"))
        frame.accountDailyTitle:SetTextColor(1, 0.6, 0.6)
    end
    frame.accountDailyTitle:Show()
    yOffset = yOffset - 25

    local accountDailyTotals = GetAccountDailyTotals()
    local today = time()

    for i = 6, 0, -1 do
        local dateStr = date("%Y-%m-%d", today - i * 86400)
        local seconds = accountDailyTotals[dateStr] or 0
        local dayName = date("%a", today - i * 86400)
        local isToday = (i == 0)

        local fs = frame.accountDailyFontStrings[i + 1]
        if not fs then
            fs = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            frame.accountDailyFontStrings[i + 1] = fs
        end
        fs:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 20, yOffset)
        fs:SetText(dayName .. " (" .. dateStr .. "): " .. FormatTime(seconds, format))

        if isToday then
            fs:SetTextColor(0, 1, 0)
        elseif seconds > 0 then
            fs:SetTextColor(1, 1, 1)
        else
            fs:SetTextColor(0.5, 0.5, 0.5)
        end
        fs:Show()
        yOffset = yOffset - 18
    end

    yOffset = yOffset - 15

    -- Ranking personajes
    if not frame.listTitle then
        frame.listTitle = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.listTitle:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 10, yOffset)
        frame.listTitle:SetText(GetLocalizedText("CHARACTER_RANKING"))
        frame.listTitle:SetTextColor(1, 0.6, 1)
    end
    frame.listTitle:Show()
    yOffset = yOffset - 25

    for i, charData in ipairs(characters) do
        local fsGroup = frame.accountFontStrings[i]

        if not fsGroup then
            local nameFS = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            local classFS = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            local timeFS = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            local activityFS = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.accountFontStrings[i] = {nameFS, classFS, timeFS, activityFS}
            fsGroup = frame.accountFontStrings[i]

            nameFS:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 15, yOffset)
            classFS:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 25, yOffset - 18)
            timeFS:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 25, yOffset - 35)
            activityFS:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 25, yOffset - 55)
        else
            fsGroup[1]:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 15, yOffset)
            fsGroup[2]:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 25, yOffset - 18)
            fsGroup[3]:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 25, yOffset - 35)
            fsGroup[4]:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 25, yOffset - 55)
            for _, fs in ipairs(fsGroup) do fs:Show() end
        end

        local char = charData.char
        local isCurrentChar = (charData.key == playerKey)
        local nameColor = isCurrentChar and "|cff00ff00" or "|cffffffff"

        fsGroup[1]:SetText(nameColor .. "#" .. i .. " " .. char.name .. " - " .. char.realm .. (isCurrentChar and " (" .. GetLocalizedText("CURRENT") .. ")" or ""))
        fsGroup[2]:SetText(GetLocalizedText("LEVEL") .. " " .. (char.level or "?") .. " " .. (char.class or GetLocalizedText("UNKNOWN")))
        local percentage = totalAccountTime > 0 and (char.totalTime / totalAccountTime) * 100 or 0
        fsGroup[3]:SetText(GetLocalizedText("TIME_COLON") .. " " .. FormatTime(char.totalTime, format) .. string.format(" (%.1f%% " .. GetLocalizedText("OF_TOTAL") .. ")", percentage))

        local todayTime = char.daily and char.daily[GetCurrentDate()] or 0
        if todayTime > 0 then
            fsGroup[4]:SetText(GetLocalizedText("PLAYED_TODAY") .. ": " .. FormatTime(todayTime, format))
            fsGroup[4]:SetTextColor(0, 1, 0)
        else
            fsGroup[4]:SetText("")
        end

        yOffset = yOffset - 80
    end

    for i = characterCount + 1, #frame.accountFontStrings do
        for _, fs in ipairs(frame.accountFontStrings[i]) do
            fs:Hide()
        end
    end

    local minHeight = 450
    local neededHeight = math.abs(yOffset) + 50
    frame.cuentaContent:SetHeight(math.max(minHeight, neededHeight))
end

-- Comandos slash - CHANGED TO AVOID CONFLICT WITH BLIZZARD /tt
SLASH_TIMETRACKER1 = "/timetrack"
SLASH_TIMETRACKER2 = "/timetracker"
SLASH_TIMETRACKER3 = "/ttracker"
function SlashCmdList.TIMETRACKER(msg)
    local command = string.lower(msg or "")
    if command == "show" or command == "" then
        if TimeTrackerFrame then
            if TimeTrackerFrame:IsShown() then
                TimeTrackerFrame:Hide()
            else
                TimeTrackerFrame:Show()
                local fmt = TimeTrackerDB.settings.timeFormat or "complete"
                local textMap = {
                    hours = GetLocalizedText("ONLY_HOURS"), 
                    minutes = GetLocalizedText("ONLY_MINUTES"), 
                    seconds = GetLocalizedText("ONLY_SECONDS"), 
                    complete = GetLocalizedText("COMPLETE_FORMAT")
                }
                UIDropDownMenu_SetText(TimeTrackerFrame.personalFormatDropdown, textMap[fmt])
                UIDropDownMenu_SetText(TimeTrackerFrame.cuentaFormatDropdown, textMap[fmt])
                if TimeTrackerFrame.tabPersonal.selected then
                    UpdateCurrentCharacterStats(TimeTrackerFrame)
                else
                    UpdateAccountStats(TimeTrackerFrame)
                end
            end
        end
    elseif command == "time" then
        RequestTimePlayed()
        print("Time Tracker: " .. GetLocalizedText("GETTING_TIME"))
    elseif command == "stats" then
        local char = TimeTrackerDB.characters[playerKey]
        if char then
            local fmt = TimeTrackerDB.settings.timeFormat
            print("Time Tracker - " .. GetLocalizedText("QUICK_STATS_TITLE"))
            print(GetLocalizedText("TOTAL") .. ": " .. FormatTime(char.totalTime, fmt))
            print(GetLocalizedText("TODAY") .. ": " .. FormatTime(char.daily[GetCurrentDate()] or 0, fmt))
            print(GetLocalizedText("THIS_WEEK") .. ": " .. FormatTime(char.weekly[GetCurrentWeek()] or 0, fmt))
            print(GetLocalizedText("THIS_MONTH") .. ": " .. FormatTime(char.monthly[GetCurrentMonth()] or 0, fmt))
        else
            print("Time Tracker: " .. GetLocalizedText("NO_DATA"))
        end
    elseif command == "format" then
        print("Time Tracker - " .. GetLocalizedText("FORMATS_AVAILABLE"))
        print("  " .. GetLocalizedText("FORMAT_HOURS"))
        print("  " .. GetLocalizedText("FORMAT_MINUTES"))
        print("  " .. GetLocalizedText("FORMAT_SECONDS"))
        print("  " .. GetLocalizedText("FORMAT_COMPLETE"))
        print(GetLocalizedText("CURRENT_FORMAT") .. " " .. (TimeTrackerDB.settings.timeFormat or "complete"))
        print(GetLocalizedText("CHANGE_FORMAT"))
    else
        print("Time Tracker - " .. GetLocalizedText("COMMANDS_AVAILABLE"))
        print("/timetrack show - " .. GetLocalizedText("SHOW_HIDE_WINDOW"))
        print("/timetrack time - " .. GetLocalizedText("GET_TIME_PLAYED"))
        print("/timetrack stats - " .. GetLocalizedText("QUICK_STATS"))
        print("/timetrack format - " .. GetLocalizedText("FORMAT_INFO"))
    end
end

-- Manejador de eventos
TimeTracker:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...
    if event == "ADDON_LOADED" and arg1 == "TimeTracker" then
        if not TimeTrackerDB then
            TimeTrackerDB = CopyTable(defaultDB)
        end
        if not TimeTrackerDB.settings.timeFormat then
            TimeTrackerDB.settings.timeFormat = "complete"
        end
        TimeTrackerFrame = CreateMainFrame()
        print(GetLocalizedText("ADDON_LOADED"))
    elseif event == "PLAYER_LOGIN" then
        playerName = UnitName("player")
        realmName = GetRealmName()
        playerKey = playerName .. "-" .. realmName
        sessionStartTime = time()
        lastUpdateTime = time()
        InitializeCharacter()
        C_Timer.After(2, function()
            RequestTimePlayed()
            isRequestingTime = true
        end)
        if TimeTrackerDB.settings.showOnLogin then
            print("Time Tracker: " .. string.format(GetLocalizedText("WELCOME"), playerName))
        end
    elseif event == "PLAYER_LOGOUT" then
        local sessionEnd = time()
        if sessionStartTime > 0 then
            local sessionTime = sessionEnd - sessionStartTime
            UpdatePlayTime(nil, nil)
        end
    elseif event == "TIME_PLAYED_MSG" then
        local totalTime, levelTime = ...
        if isRequestingTime then
            UpdatePlayTime(totalTime, levelTime)
            isRequestingTime = false
            if TimeTrackerFrame and TimeTrackerFrame:IsShown() then
                if TimeTrackerFrame.tabPersonal.selected then
                    UpdateCurrentCharacterStats(TimeTrackerFrame)
                else
                    UpdateAccountStats(TimeTrackerFrame)
                end
            end
        end
    end
end)

-- Timer para actualización automática
local updateTimer = nil

local function StartUpdateTimer()
    if updateTimer then
        updateTimer:Cancel()
    end
    local interval = TimeTrackerDB and TimeTrackerDB.settings.updateInterval or 300
    updateTimer = C_Timer.NewTicker(interval, function()
        if playerKey and TimeTrackerDB and TimeTrackerDB.characters[playerKey] then
            RequestTimePlayed()
            isRequestingTime = true
        end
    end)
end

-- Initialize timer after login
C_Timer.After(5, function()
    if TimeTrackerDB then
        StartUpdateTimer()
    end
end)