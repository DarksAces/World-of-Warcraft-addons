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
    UIDropDownMenu_SetText(dropdown, "Formato Completo")
    
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

        info.text = "Solo Horas"
        info.arg1 = "hours"
        info.arg2 = "Solo Horas"
        info.checked = (TimeTrackerDB.settings.timeFormat == "hours")
        UIDropDownMenu_AddButton(info)
        
        info.text = "Solo Minutos"
        info.arg1 = "minutes"
        info.arg2 = "Solo Minutos"
        info.checked = (TimeTrackerDB.settings.timeFormat == "minutes")
        UIDropDownMenu_AddButton(info)
        
        info.text = "Solo Segundos"
        info.arg1 = "seconds"
        info.arg2 = "Solo Segundos"
        info.checked = (TimeTrackerDB.settings.timeFormat == "seconds")
        UIDropDownMenu_AddButton(info)
        
        info.text = "Formato Completo"
        info.arg1 = "complete"
        info.arg2 = "Formato Completo"
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
    frame.title:SetText("Time Tracker")

    -- Tab相关 FontStrings reutilizables
    frame.accountFontStrings = {}
    frame.characterFontStrings = {}

    -- Pestañas
    frame.tabPersonal = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.tabPersonal:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -25)
    frame.tabPersonal:SetText("Personaje Actual")
    frame.tabPersonal:SetSize(120, 25)
    frame.tabPersonal.selected = true

    frame.tabCuenta = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.tabCuenta:SetPoint("LEFT", frame.tabPersonal, "RIGHT", 5, 0)
    frame.tabCuenta:SetText("Cuenta")
    frame.tabCuenta:SetSize(80, 25)
    frame.tabCuenta.selected = false

    -- Panel Personaje Actual
    frame.personalPanel = CreateFrame("Frame", nil, frame)
    frame.personalPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.personalPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.personalPanel:Show()

    frame.personalFormatLabel = frame.personalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.personalFormatLabel:SetPoint("TOPLEFT", frame.personalPanel, "TOPLEFT", 10, -10)
    frame.personalFormatLabel:SetText("Formato de tiempo:")
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
    frame.cuentaFormatLabel:SetText("Formato de tiempo:")
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
        frame.noDataText:SetText("No hay datos disponibles para el personaje actual.\nUsa /tt time para obtener información.")
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
    classText:SetText("Nivel " .. (char.level or "?") .. " " .. (char.class or ""))
    classText:SetTextColor(0.8, 0.8, 0.8)
    yOffset = yOffset - 40

    local mainStatsTitle = CreateOrReuse(3, "GameFontNormalLarge")
    mainStatsTitle:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 10, yOffset)
    mainStatsTitle:SetText("--- Estadisticas Principales ---")
    mainStatsTitle:SetTextColor(1, 0.8, 0)
    yOffset = yOffset - 25

    local totalText = CreateOrReuse(4, "GameFontHighlight")
    totalText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    totalText:SetText("Tiempo Total: " .. FormatTime(char.totalTime, format))
    totalText:SetTextColor(1, 1, 0)
    yOffset = yOffset - 20

    local levelText = CreateOrReuse(5, "GameFontHighlight")
    levelText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    levelText:SetText("Tiempo en Nivel " .. (char.level or "?") .. ": " .. FormatTime(char.levelTime or 0, format))
    levelText:SetTextColor(0.8, 0.8, 1)
    yOffset = yOffset - 35

    local timeStatsTitle = CreateOrReuse(6, "GameFontNormalLarge")
    timeStatsTitle:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 10, yOffset)
    timeStatsTitle:SetText("--- Tiempo de Juego ---")
    timeStatsTitle:SetTextColor(0, 1, 1)
    yOffset = yOffset - 25

    local todayTime = char.daily[GetCurrentDate()] or 0
    local todayText = CreateOrReuse(7, "GameFontHighlight")
    todayText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    todayText:SetText("Hoy: " .. FormatTime(todayTime, format))
    todayText:SetTextColor(0, 1, 0)
    yOffset = yOffset - 20

    local weekTime = char.weekly[GetCurrentWeek()] or 0
    local weekText = CreateOrReuse(8, "GameFontHighlight")
    weekText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    weekText:SetText("Esta Semana: " .. FormatTime(weekTime, format))
    weekText:SetTextColor(0, 0.8, 1)
    yOffset = yOffset - 20

    local monthTime = char.monthly[GetCurrentMonth()] or 0
    local monthText = CreateOrReuse(9, "GameFontHighlight")
    monthText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    monthText:SetText("Este Mes: " .. FormatTime(monthTime, format))
    monthText:SetTextColor(1, 0, 1)
    yOffset = yOffset - 35

    local historyTitle = CreateOrReuse(10, "GameFontNormalLarge")
    historyTitle:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 10, yOffset)
    historyTitle:SetText("--- Ultimos 7 Dias ---")
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
    sessionTitle:SetText("--- Sesion Actual ---")
    sessionTitle:SetTextColor(1, 0.5, 0)
    yOffset = yOffset - 25

    local loginTime = CreateOrReuse(12, "GameFontNormal")
    loginTime:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 20, yOffset)
    if char.lastLogin then
        loginTime:SetText("Último login: " .. date("%Y-%m-%d %H:%M:%S", char.lastLogin))
    else
        loginTime:SetText("Último login: Desconocido")
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
        frame.summaryTitle:SetText("--- Resumen General ---")
        frame.summaryTitle:SetTextColor(0,1,1)
    end
    frame.summaryTitle:Show()
    yOffset = yOffset - 25

    if not frame.summaryTotalTime then
        frame.summaryTotalTime = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.summaryTotalTime:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 20, yOffset)
    end
    frame.summaryTotalTime:SetText("Tiempo Total de Todos los Personajes: " .. FormatTime(totalAccountTime, format))
    frame.summaryTotalTime:SetTextColor(1, 1, 0)
    frame.summaryTotalTime:Show()
    yOffset = yOffset - 20

    if not frame.summaryCharCount then
        frame.summaryCharCount = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.summaryCharCount:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 20, yOffset)
    end
    frame.summaryCharCount:SetText("Número de Personajes: " .. characterCount)
    frame.summaryCharCount:SetTextColor(0.8, 0.8, 0.8)
    frame.summaryCharCount:Show()
    yOffset = yOffset - 20

    if not frame.summaryAvgTime then
        frame.summaryAvgTime = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.summaryAvgTime:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 20, yOffset)
    end
    local avgTime = characterCount > 0 and (totalAccountTime / characterCount) or 0
    frame.summaryAvgTime:SetText("Promedio por Personaje: " .. FormatTime(avgTime, format))
    frame.summaryAvgTime:SetTextColor(0.8, 0.8, 0.8)
    frame.summaryAvgTime:Show()
    yOffset = yOffset - 35

    if characterCount == 0 then
        if not frame.noDataText then
            frame.noDataText = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            frame.noDataText:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 10, yOffset)
            frame.noDataText:SetTextColor(1, 0.5, 0)
        end
        frame.noDataText:SetText("No hay personajes registrados en la base de datos")
        frame.noDataText:Show()
        return
    elseif frame.noDataText then
        frame.noDataText:Hide()
    end

    -- Mostrar totales diarios combinados cuenta (últimos 7 días)
    if not frame.accountDailyTitle then
        frame.accountDailyTitle = frame.cuentaContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.accountDailyTitle:SetPoint("TOPLEFT", frame.cuentaContent, "TOPLEFT", 10, yOffset)
        frame.accountDailyTitle:SetText("--- Tiempo Diario Total Cuenta (Últimos 7 Días) ---")
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
        frame.listTitle:SetText("--- Ranking de Personajes ---")
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

        fsGroup[1]:SetText(nameColor .. "#" .. i .. " " .. char.name .. " - " .. char.realm .. (isCurrentChar and " (ACTUAL)" or ""))
        fsGroup[2]:SetText("Nivel " .. (char.level or "?") .. " " .. (char.class or "Desconocido"))
        local percentage = totalAccountTime > 0 and (char.totalTime / totalAccountTime) * 100 or 0
        fsGroup[3]:SetText("Tiempo: " .. FormatTime(char.totalTime, format) .. string.format(" (%.1f%% del total)", percentage))

        local todayTime = char.daily and char.daily[GetCurrentDate()] or 0
        if todayTime > 0 then
            fsGroup[4]:SetText("Jugado hoy: " .. FormatTime(todayTime, format))
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

-- Comandos slash
SLASH_TIMETRACKER1 = "/tt"
SLASH_TIMETRACKER2 = "/timetracker"
function SlashCmdList.TIMETRACKER(msg)
    local command = string.lower(msg or "")
    if command == "show" or command == "" then
        if TimeTrackerFrame then
            if TimeTrackerFrame:IsShown() then
                TimeTrackerFrame:Hide()
            else
                TimeTrackerFrame:Show()
                local fmt = TimeTrackerDB.settings.timeFormat or "complete"
                local textMap = {hours = "Solo Horas", minutes = "Solo Minutos", seconds = "Solo Segundos", complete = "Formato Completo"}
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
        print("Time Tracker: Obteniendo tiempo total jugado...")
    elseif command == "stats" then
        local char = TimeTrackerDB.characters[playerKey]
        if char then
            local fmt = TimeTrackerDB.settings.timeFormat
            print("Time Tracker - Estadísticas rápidas:")
            print("Total: " .. FormatTime(char.totalTime, fmt))
            print("Hoy: " .. FormatTime(char.daily[GetCurrentDate()] or 0, fmt))
            print("Esta semana: " .. FormatTime(char.weekly[GetCurrentWeek()] or 0, fmt))
            print("Este mes: " .. FormatTime(char.monthly[GetCurrentMonth()] or 0, fmt))
        else
            print("Time Tracker: No hay datos disponibles. Usa /tt time para obtener información.")
        end
    elseif command == "format" then
        print("Time Tracker - Formatos disponibles:")
        print("  hours - Solo muestra horas totales")
        print("  minutes - Solo muestra minutos totales")
        print("  seconds - Solo muestra segundos totales")
        print("  complete - Formato completo (días, horas, minutos)")
        print("Formato actual: " .. (TimeTrackerDB.settings.timeFormat or "complete"))
        print("Cambia el formato desde la interfaz gráfica (/tt show)")
    else
        print("Time Tracker - Comandos disponibles:")
        print("/tt show - Mostrar/ocultar ventana principal")
        print("/tt time - Obtener tiempo total jugado")
        print("/tt stats - Ver estadísticas rápidas en chat")
        print("/tt format - Ver información sobre formatos de tiempo")
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
        print("Time Tracker v2.0 cargado. Usa /tt para abrir la ventana.")
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
            print("Time Tracker: ¡Bienvenido " .. playerName .. "! Usa /tt para ver tus estadísticas.")
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
local updateTimer = C_Timer.NewTicker(TimeTrackerDB and TimeTrackerDB.settings.updateInterval or 300, function()
    if playerKey and TimeTrackerDB.characters[playerKey] then
        RequestTimePlayed()
        isRequestingTime = true
    end
end)
