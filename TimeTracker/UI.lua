local addonName, private = ...

-- Global Frame Reference
local TimeTrackerFrame = nil

-- UI Helper: Create Dropdown
-- UI Helper: Create Dropdown (Modernized)
local dropdownIndex = 0
local function CreateTimeFormatDropdown(parent, xOffset, yOffset)
    dropdownIndex = dropdownIndex + 1
    local name = addonName .. "Dropdown" .. dropdownIndex
    local dropdown = CreateFrame("Button", name, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    UIDropDownMenu_SetWidth(dropdown, 150)
    
    -- Text styling
    local text = _G[name.."Text"]
    if text then text:SetFontObject("GameFontNormal") end


    
    UIDropDownMenu_SetText(dropdown, private.GetLocalizedText("COMPLETE_FORMAT"))
    
    local function OnClick(self, arg1, arg2)
        TimeTrackerDB.settings.timeFormat = arg1
        UIDropDownMenu_SetText(dropdown, arg2)
        if TimeTrackerFrame and TimeTrackerFrame:IsShown() then
            if TimeTrackerFrame.tabPersonal.selected then
                private.UpdateCurrentCharacterStats(TimeTrackerFrame)
            elseif TimeTrackerFrame.tabCharacters.selected then
                private.UpdateCharactersStats(TimeTrackerFrame)
            elseif TimeTrackerFrame.tabClasses.selected then
                private.UpdateClassesStats(TimeTrackerFrame)
            elseif TimeTrackerFrame.tabRaces.selected then
                private.UpdateRacesStats(TimeTrackerFrame)
            elseif TimeTrackerFrame.tabHistory and TimeTrackerFrame.tabHistory.selected then
                private.UpdateHistoryStats(TimeTrackerFrame)
            end
        end
    end
    
    local function Initialize()
        local info = UIDropDownMenu_CreateInfo()
        info.func = OnClick
        info.padding = 10

        info.text = "|cffffffff" .. private.GetLocalizedText("ONLY_HOURS") .. "|r"
        info.arg1 = "hours"
        info.arg2 = private.GetLocalizedText("ONLY_HOURS")
        info.checked = (TimeTrackerDB.settings.timeFormat == "hours")
        UIDropDownMenu_AddButton(info)
        
        info.text = "|cffffffff" .. private.GetLocalizedText("ONLY_MINUTES") .. "|r"
        info.arg1 = "minutes"
        info.arg2 = private.GetLocalizedText("ONLY_MINUTES")
        info.checked = (TimeTrackerDB.settings.timeFormat == "minutes")
        UIDropDownMenu_AddButton(info)
        
        info.text = "|cffffffff" .. private.GetLocalizedText("ONLY_SECONDS") .. "|r"
        info.arg1 = "seconds"
        info.arg2 = private.GetLocalizedText("ONLY_SECONDS")
        info.checked = (TimeTrackerDB.settings.timeFormat == "seconds")
        UIDropDownMenu_AddButton(info)
        
        info.text = "|cffffffff" .. private.GetLocalizedText("COMPLETE_FORMAT") .. "|r"
        info.arg1 = "complete"
        info.arg2 = private.GetLocalizedText("COMPLETE_FORMAT")
        info.checked = (TimeTrackerDB.settings.timeFormat == "complete")
        UIDropDownMenu_AddButton(info)
    end
    
    UIDropDownMenu_Initialize(dropdown, Initialize)
    return dropdown
end



-- UI Helper: Create Standard List Entry
local function CreateEntryFrame(parent)
    local frame = CreateFrame("Button", nil, parent, "BackdropTemplate")
    frame:SetSize(430, 52)
    
    -- Background with rounded edges effect
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.5)
    frame:SetBackdropBorderColor(1, 1, 1, 0.1)
    
    frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    frame:GetHighlightTexture():SetAlpha(0.15)
    
    -- Icon (optional) with border
    frame.iconContainer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.iconContainer:SetSize(38, 38)
    frame.iconContainer:SetPoint("LEFT", 6, 0)
    frame.iconContainer:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame.iconContainer:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.5)

    frame.icon = frame.iconContainer:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Name
    frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

    frame.name:SetPoint("TOPLEFT", 50, -8)
    frame.name:SetJustifyH("LEFT")
    
    -- Right Text (Total Time)
    frame.rightText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.rightText:SetPoint("TOPRIGHT", -12, -8)
    
    -- Status Bar (Modern style)
    frame.bar = CreateFrame("StatusBar", nil, frame)
    frame.bar:SetSize(370, 10)
    frame.bar:SetPoint("TOPLEFT", frame.name, "BOTTOMLEFT", 0, -4)
    frame.bar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    frame.bar:GetStatusBarTexture():SetHorizTile(false)
    
    local barBg = frame.bar:CreateTexture(nil, "BACKGROUND")
    barBg:SetAllPoints()
    barBg:SetColorTexture(0, 0, 0, 0.6)
    
    -- Bar Glow/Gloss
    local barGloss = frame.bar:CreateTexture(nil, "OVERLAY")
    barGloss:SetAllPoints()
    barGloss:SetTexture("Interface\\Buttons\\WHITE8X8")
    barGloss:SetGradient("VERTICAL", CreateColor(1,1,1,0.1), CreateColor(1,1,1,0))

    -- Bar Text (Overlay on bar)
    frame.barText = frame.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.barText:SetPoint("CENTER", 0, 1)
    frame.barText:SetScale(0.9)
    
    -- Subtext (Details below bar)
    frame.subText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.subText:SetPoint("TOPLEFT", frame.bar, "BOTTOMLEFT", 0, -3)
    frame.subText:SetTextColor(0.5, 0.5, 0.5)

    -- Helper to toggle icon
    frame.ToggleIcon = function(self, show)
        if show then
            self.iconContainer:Show()
            self.name:SetPoint("TOPLEFT", 50, -8)
            self.bar:SetPoint("TOPLEFT", self.name, "BOTTOMLEFT", 0, -4)
            self.bar:SetWidth(370)
        else
            self.iconContainer:Hide()
            self.name:SetPoint("TOPLEFT", 10, -8)
            self.bar:SetPoint("TOPLEFT", self.name, "BOTTOMLEFT", 0, -4)
            self.bar:SetWidth(410)
        end
    end
    
    return frame
end



-- Helper: Create/Reuse FontString
local function CreateOrReuseFontString(framePool, parent, index, fontTemplate)
    local fs = framePool[index]
    if not fs then
        fs = parent:CreateFontString(nil, "OVERLAY", fontTemplate or "GameFontNormal")
        framePool[index] = fs
    end
    fs:Show()
    return fs
end

-- Update Personal Stats
function private.UpdateCurrentCharacterStats(frame)
    local char = TimeTrackerDB.characters[private.playerKey]
    local format = TimeTrackerDB.settings.timeFormat
    local yOffset = -10

    frame.characterFontStrings = frame.characterFontStrings or {}
    for _, fs in pairs(frame.characterFontStrings) do fs:Hide() end
    frame.content:SetHeight(450) -- Reset

    if not char then
        if not frame.noDataText then
            frame.noDataText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            frame.noDataText:SetPoint("CENTER", frame.content, "CENTER", 0, 0)
            frame.noDataText:SetTextColor(1, 0.5, 0)
        end
        frame.noDataText:SetText(private.GetLocalizedText("NO_DATA"))
        frame.noDataText:Show()
        return
    end
    if frame.noDataText then frame.noDataText:Hide() end

    -- Helper
    local function AddLine(text, font, r, g, b, extraY)
        local index = #frame.characterFontStrings + 1
        local fs = CreateOrReuseFontString(frame.characterFontStrings, frame.content, index, font)
        fs:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 10, yOffset)
        fs:SetText(text)
        if r then fs:SetTextColor(r, g, b) end
        yOffset = yOffset - (extraY or 20)
        return fs
    end

    local nameText = AddLine(char.name .. " - " .. char.realm, "GameFontHighlightLarge", 1, 1, 1, 25)
    
    local classText = AddLine(private.GetLocalizedText("LEVEL") .. " " .. (char.level or "?") .. " " .. (char.class or "") .. " " .. (char.race or ""), "GameFontHighlight", 0.8, 0.8, 0.8, 40)
    
    AddLine(private.GetLocalizedText("MAIN_STATS"), "GameFontNormalLarge", 1, 0.8, 0, 25)
    AddLine(private.GetLocalizedText("TOTAL_TIME") .. ": " .. private.FormatTime(char.totalTime, format), "GameFontHighlight", 1, 1, 0)
    AddLine(string.format(private.GetLocalizedText("LEVEL_TIME"), char.level or 0) .. ": " .. private.FormatTime(char.levelTime or 0, format), "GameFontHighlight", 0.8, 0.8, 1, 35)

    AddLine(private.GetLocalizedText("PLAY_TIME"), "GameFontNormalLarge", 0, 1, 1, 25)
    AddLine(private.GetLocalizedText("TODAY_LABEL") .. ": " .. private.FormatTime(char.daily[private.GetCurrentDate()] or 0, format), "GameFontHighlight", 0, 1, 0)
    AddLine(private.GetLocalizedText("THIS_WEEK_LABEL") .. ": " .. private.FormatTime(char.weekly[private.GetCurrentWeek()] or 0, format), "GameFontHighlight", 0, 0.8, 1)
    AddLine(private.GetLocalizedText("THIS_MONTH_LABEL") .. ": " .. private.FormatTime(char.monthly[private.GetCurrentMonth()] or 0, format), "GameFontHighlight", 1, 0, 1)
    
    local currentYear = private.GetCurrentYear and private.GetCurrentYear() or date("%Y")
    local yearTime = (char.yearly and char.yearly[currentYear]) or 0
    AddLine(private.GetLocalizedText("THIS_YEAR_LABEL") .. ": " .. private.FormatTime(yearTime, format), "GameFontHighlight", 1, 0.5, 0, 35)

    AddLine(private.GetLocalizedText("LAST_7_DAYS"), "GameFontNormalLarge", 1, 0.6, 1, 25)
    
    local today = time()
    local weekDays = {CALENDAR_SUNDAY, CALENDAR_MONDAY, CALENDAR_TUESDAY, CALENDAR_WEDNESDAY, CALENDAR_THURSDAY, CALENDAR_FRIDAY, CALENDAR_SATURDAY}
    -- Fallback/Override for Spanish if globals fail or to bold them, but globals usually work.
    -- Ideally, we want short names like "Lun", "Mar". 
    -- CALENDAR_WEEKDAY_NAMES is a global table in WoW? No, typically CALENDAR_SUNDAY is full name.
    -- Let's try to substring or use a manual short list for UI compactness.
    
    local shortDays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
    if GetLocale() == "esES" or GetLocale() == "esMX" then
       shortDays = {"Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"}
    elseif CALENDAR_SUNDAY then
       -- Try to make short versions from globals if needed, or just use full names? 
       -- Full names might be too long for this list depending on width.
       -- Let's stick to the manual short list for now to ensure it fits.
    end

    for i = 1, 7 do
        local tDate = today - (7 - i) * 86400
        local dateStr = date("%Y-%m-%d", tDate)
        local dayTime = char.daily[dateStr] or 0
        local wDay = tonumber(date("%w", tDate)) + 1 -- 1=Sun, 7=Sat
        local dayName = shortDays[wDay] or date("%a", tDate)
        
        local isToday = (i == 7)
        local r, g, b = 0.9, 0.9, 0.9
        if isToday then r,g,b = 0,1,0 elseif dayTime == 0 then r,g,b = 0.5,0.5,0.5 end
        
        AddLine(dayName .. " (" .. dateStr .. "): " .. private.FormatTime(dayTime, format), "GameFontNormal", r, g, b, 18)
    end
    yOffset = yOffset - 10

    AddLine(private.GetLocalizedText("CURRENT_SESSION"), "GameFontNormalLarge", 1, 0.5, 0, 25)
    local loginStr = private.GetLocalizedText("UNKNOWN")
    if char.lastLogin then loginStr = date("%Y-%m-%d %H:%M:%S", char.lastLogin) end
    AddLine(private.GetLocalizedText("LAST_LOGIN") .. ": " .. loginStr, "GameFontNormal", 0.8, 0.8, 0.8)

    local neededHeight = math.abs(yOffset) + 50
    frame.content:SetHeight(math.max(450, neededHeight))
end

-- Update Classes Stats
function private.UpdateClassesStats(frame)
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    local totalAccountTime = 0
    local classTotals = {}
    local classYearly = {}
    local classToEnglish = {}
    local currentYear = private.GetCurrentYear and private.GetCurrentYear() or date("%Y")
    
    local currentPlayerClass, currentClassFile = UnitClass("player")
    local currentPlayerRace, currentRaceFile = UnitRace("player")
    
    local currentClassStats = {
        total = 0,
        year = 0,
        month = 0,
        week = 0,
        today = 0
    }
    
    local currentMonth = private.GetCurrentMonth and private.GetCurrentMonth() or date("%Y-%m")
    local currentWeek = private.GetCurrentWeek and private.GetCurrentWeek() or date("%Y-%W")
    local currentToday = private.GetCurrentDate and private.GetCurrentDate() or date("%Y-%m-%d")

    for key, char in pairs(TimeTrackerDB.characters) do
        local t = char.totalTime or 0
        totalAccountTime = totalAccountTime + t
        local className = char.class or private.GetLocalizedText("UNKNOWN")
        classTotals[className] = (classTotals[className] or 0) + t
        local yTime = (char.yearly and char.yearly[currentYear]) or 0
        classYearly[className] = (classYearly[className] or 0) + yTime
        
        if char.classFile then
            classToEnglish[className] = char.classFile
        end
        
        -- Current Class Aggregation
        if char.classFile == currentClassFile then
            currentClassStats.total = currentClassStats.total + t
            currentClassStats.year = currentClassStats.year + (char.yearly and char.yearly[currentYear] or 0)
            currentClassStats.month = currentClassStats.month + (char.monthly and char.monthly[currentMonth] or 0)
            currentClassStats.week = currentClassStats.week + (char.weekly and char.weekly[currentWeek] or 0)
            currentClassStats.today = currentClassStats.today + (char.daily and char.daily[currentToday] or 0)
        end
    end

    local classList = {}
    for className, time in pairs(classTotals) do
        table.insert(classList, {
            name = className,
            time = time,
            yearly = classYearly[className] or 0,
            english = classToEnglish[className]
        })
    end
    table.sort(classList, function(a,b) return a.time > b.time end)
    
    if frame.classFrames then for _, f in pairs(frame.classFrames) do f:Hide() end end
    frame.classFrames = frame.classFrames or {}
    
    frame.classMiscFS = frame.classMiscFS or {}
    for _, fs in ipairs(frame.classMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscClassFS()
        miscFSIndex = miscFSIndex + 1
        return CreateOrReuseFontString(frame.classMiscFS, frame.classesContent, miscFSIndex, "GameFontHighlight")
    end

    local yOffset = -10
    
    -- Current Class Header
    local h = GetMiscClassFS(); h:SetFontObject("GameFontNormalLarge"); h:SetPoint("TOPLEFT", 10, yOffset); h:SetText(string.format(private.GetLocalizedText("CURRENT_CLASS"), currentPlayerClass)); h:SetTextColor(1, 0.8, 0); yOffset = yOffset - 30
    
    local hex = private.GetClassHexColor and private.GetClassHexColor(currentClassFile) or "ffffffff"
    
    local t = GetMiscClassFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("TOTAL") .. ": |c" .. hex .. private.FormatTime(currentClassStats.total, format) .. "|r"); t:SetTextColor(1,1,1); yOffset = yOffset - 20
    t = GetMiscClassFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("THIS_YEAR_LABEL") .. ": " .. private.FormatTime(currentClassStats.year, format)); t:SetTextColor(0,1,0); yOffset = yOffset - 20
    t = GetMiscClassFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("THIS_MONTH_LABEL") .. ": " .. private.FormatTime(currentClassStats.month, format)); t:SetTextColor(0.4, 0.6, 1); yOffset = yOffset - 20
    t = GetMiscClassFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("THIS_WEEK_LABEL") .. ": " .. private.FormatTime(currentClassStats.week, format)); t:SetTextColor(1, 0.6, 1); yOffset = yOffset - 20
    t = GetMiscClassFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("TODAY") .. ": " .. private.FormatTime(currentClassStats.today, format)); t:SetTextColor(1, 1, 0.6); yOffset = yOffset - 35

    h = GetMiscClassFS(); h:SetFontObject("GameFontNormalLarge"); h:SetPoint("TOPLEFT", 10, yOffset); h:SetText(private.GetLocalizedText("CLASS_DISTRIBUTION")); h:SetTextColor(1,0.8,0.4); yOffset = yOffset - 30

    for i, classData in ipairs(classList) do
        local entry = frame.classFrames[i]
        if not entry then
            entry = CreateEntryFrame(frame.classesContent)
            frame.classFrames[i] = entry
        end
        entry:SetPoint("TOPLEFT", 10, yOffset)
        entry:Show()
        
        if i % 2 == 1 then 
            entry:SetBackdropColor(0.08, 0.08, 0.08, 0.8) 
        else 
            entry:SetBackdropColor(0.03, 0.03, 0.03, 0.4) 
        end

        
        local hex = private.GetClassHexColor and private.GetClassHexColor(classData.english) or "ffffffff"
        local r,g,b = 1,1,1
        if private.GetClassRGB then
             r,g,b = private.GetClassRGB(classData.english)
        end
        if type(r) ~= "number" then r,g,b = 1,1,1 end
        
        -- Icon
        entry:ToggleIcon(true)
        entry.icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        local coords = CLASS_ICON_TCOORDS[classData.english]
        if coords then
            entry.icon:SetTexCoord(unpack(coords))
        else
            entry.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        
        entry.name:SetText("|c" .. hex .. classData.name .. "|r")
        entry.rightText:SetText(private.FormatTime(classData.time, format))
        
        local pct = totalAccountTime > 0 and (classData.time / totalAccountTime) or 0
        entry.bar:SetMinMaxValues(0, totalAccountTime > 0 and totalAccountTime or 1)
        entry.bar:SetValue(classData.time)
        entry.bar:SetStatusBarColor(r,g,b)
        entry.barText:SetText(string.format("%.1f%%", pct * 100))

        
        entry.subText:SetText(private.GetLocalizedText("THIS_YEAR_LABEL") .. ": " .. private.FormatTime(classData.yearly, format))
        
        yOffset = yOffset - 55
    end
    local neededHeight = math.abs(yOffset) + 50
    frame.classesContent:SetHeight(math.max(450, neededHeight))
end

-- NEW: Update Races Stats
function private.UpdateRacesStats(frame)
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    local totalAccountTime = 0
    local raceTotals = {}
    local raceYearly = {}
    local currentYear = private.GetCurrentYear and private.GetCurrentYear() or date("%Y")
    
    local currentPlayerRace, currentRaceFile = UnitRace("player") -- Race name, Race ID/File
    -- UnitRace("player") returns: Name, File, ID
    -- TimeTracker stores char.race as Name. char.raceFile as File.
    -- We'll use localized name for matching since char.race is localized.
    
    local currentRaceStats = {
        total = 0,
        year = 0,
        month = 0,
        week = 0,
        today = 0
    }
    
    local currentMonth = private.GetCurrentMonth and private.GetCurrentMonth() or date("%Y-%m")
    local currentWeek = private.GetCurrentWeek and private.GetCurrentWeek() or date("%Y-%W")
    local currentToday = private.GetCurrentDate and private.GetCurrentDate() or date("%Y-%m-%d")

    for key, char in pairs(TimeTrackerDB.characters) do
        local t = char.totalTime or 0
        totalAccountTime = totalAccountTime + t
        local raceName = char.race or private.GetLocalizedText("UNKNOWN")
        raceTotals[raceName] = (raceTotals[raceName] or 0) + t
        
        local yTime = (char.yearly and char.yearly[currentYear]) or 0
        raceYearly[raceName] = (raceYearly[raceName] or 0) + yTime
        
        -- Current Race Aggregation
        if raceName == currentPlayerRace then
            currentRaceStats.total = currentRaceStats.total + t
            currentRaceStats.year = currentRaceStats.year + (char.yearly and char.yearly[currentYear] or 0)
            currentRaceStats.month = currentRaceStats.month + (char.monthly and char.monthly[currentMonth] or 0)
            currentRaceStats.week = currentRaceStats.week + (char.weekly and char.weekly[currentWeek] or 0)
            currentRaceStats.today = currentRaceStats.today + (char.daily and char.daily[currentToday] or 0)
        end
    end

    local raceList = {}
    for raceName, time in pairs(raceTotals) do
        table.insert(raceList, {
            name = raceName,
            time = time,
            yearly = raceYearly[raceName] or 0
        })
    end
    table.sort(raceList, function(a,b) return a.time > b.time end)
    
    if frame.raceFrames then for _, f in pairs(frame.raceFrames) do f:Hide() end end
    frame.raceFrames = frame.raceFrames or {}
    
    frame.raceMiscFS = frame.raceMiscFS or {}
    for _, fs in ipairs(frame.raceMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscRaceFS()
        miscFSIndex = miscFSIndex + 1
        return CreateOrReuseFontString(frame.raceMiscFS, frame.racesContent, miscFSIndex, "GameFontHighlight")
    end

    local yOffset = -10
    
    -- Current Race Header
    local h = GetMiscRaceFS(); h:SetFontObject("GameFontNormalLarge"); h:SetPoint("TOPLEFT", 10, yOffset); h:SetText(string.format(private.GetLocalizedText("CURRENT_RACE"), currentPlayerRace)); h:SetTextColor(0, 1, 0); yOffset = yOffset - 30
    
    local t = GetMiscRaceFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("TOTAL") .. ": " .. private.FormatTime(currentRaceStats.total, format)); t:SetTextColor(1,1,1); yOffset = yOffset - 20
    t = GetMiscRaceFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("THIS_YEAR_LABEL") .. ": " .. private.FormatTime(currentRaceStats.year, format)); t:SetTextColor(0,1,0); yOffset = yOffset - 20
    t = GetMiscRaceFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("THIS_MONTH_LABEL") .. ": " .. private.FormatTime(currentRaceStats.month, format)); t:SetTextColor(0.4, 0.6, 1); yOffset = yOffset - 20
    t = GetMiscRaceFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("THIS_WEEK_LABEL") .. ": " .. private.FormatTime(currentRaceStats.week, format)); t:SetTextColor(1, 0.6, 1); yOffset = yOffset - 20
    t = GetMiscRaceFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("TODAY") .. ": " .. private.FormatTime(currentRaceStats.today, format)); t:SetTextColor(1, 1, 0.6); yOffset = yOffset - 35

    h = GetMiscRaceFS(); h:SetFontObject("GameFontNormalLarge"); h:SetPoint("TOPLEFT", 10, yOffset); h:SetText(private.GetLocalizedText("RACE_DISTRIBUTION")); h:SetTextColor(0.5, 1, 0.5); yOffset = yOffset - 30

    for i, raceData in ipairs(raceList) do
        local entry = frame.raceFrames[i]
        if not entry then
            entry = CreateEntryFrame(frame.racesContent)
            frame.raceFrames[i] = entry
        end
        entry:SetPoint("TOPLEFT", 10, yOffset)
        entry:Show()
        
        if i % 2 == 1 then 
            entry:SetBackdropColor(0.08, 0.08, 0.08, 0.8) 
        else 
            entry:SetBackdropColor(0.03, 0.03, 0.03, 0.4) 
        end

        
        -- Icon
        entry:ToggleIcon(false)
        
        entry.name:SetText(raceData.name)
        entry.rightText:SetText(private.FormatTime(raceData.time, format))

        
        local pct = totalAccountTime > 0 and (raceData.time / totalAccountTime) or 0
        entry.bar:SetMinMaxValues(0, totalAccountTime > 0 and totalAccountTime or 1)
        entry.bar:SetValue(raceData.time)
        entry.bar:SetStatusBarColor(0, 1, 0)
        entry.barText:SetText(string.format("%.1f%%", pct * 100))
        
        entry.subText:SetText(private.GetLocalizedText("THIS_YEAR_LABEL") .. ": " .. private.FormatTime(raceData.yearly, format))
        
        yOffset = yOffset - 55
    end
    
    local neededHeight = math.abs(yOffset) + 50
    frame.racesContent:SetHeight(math.max(450, neededHeight))
end


-- Update Characters Stats
function private.UpdateCharactersStats(frame)
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    local characters = {}
    local totalAccountTime = 0
    
    -- Data Gathering (Keep logic same)
    local totalToday, totalWeek, totalMonth, totalYear = 0, 0, 0, 0
    local currentDate = private.GetCurrentDate()
    local currentWeek = private.GetCurrentWeek()
    local currentMonth = private.GetCurrentMonth()
    local currentYear = private.GetCurrentYear and private.GetCurrentYear() or date("%Y")

    for key, char in pairs(TimeTrackerDB.characters) do
        local t = char.totalTime or 0
        totalAccountTime = totalAccountTime + t
        table.insert(characters, {key = key, char = char, totalTime = t})
        
        totalToday = totalToday + (char.daily and char.daily[currentDate] or 0)
        totalWeek = totalWeek + (char.weekly and char.weekly[currentWeek] or 0)
        totalMonth = totalMonth + (char.monthly and char.monthly[currentMonth] or 0)
        totalYear = totalYear + (char.yearly and char.yearly[currentYear] or 0)
    end
    table.sort(characters, function(a,b) return a.totalTime > b.totalTime end)

    if frame.accountFrames then for _, f in pairs(frame.accountFrames) do f:Hide() end end
    frame.accountFrames = frame.accountFrames or {}
    
    -- Header Stats (reusing logic but cleaning up)
    frame.charMiscFS = frame.charMiscFS or {}
    for _, fs in ipairs(frame.charMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscCharFS()
        miscFSIndex = miscFSIndex + 1
        return CreateOrReuseFontString(frame.charMiscFS, frame.charactersContent, miscFSIndex, "GameFontHighlight")
    end

    local yOffset = -10
    
    -- Summary Section
    local h = GetMiscCharFS(); h:SetFontObject("GameFontNormalLarge"); h:SetPoint("TOPLEFT", 10, yOffset); h:SetText(private.GetLocalizedText("GENERAL_SUMMARY")); h:SetTextColor(0.4, 0.8, 1); yOffset = yOffset - 30
    
    -- Stats Grid effect
    local function AddStat(label, val, r, g, b)
        local t = GetMiscCharFS()
        t:SetPoint("TOPLEFT", 20, yOffset)
        t:SetText(label .. ": |cffffffff" .. val .. "|r")
        t:SetTextColor(r,g,b)
        yOffset = yOffset - 18
    end
    
    AddStat(private.GetLocalizedText("TOTAL_ALL_CHARS"), private.FormatTime(totalAccountTime, format), 1, 0.8, 0)
    AddStat(private.GetLocalizedText("THIS_YEAR_LABEL"), private.FormatTime(totalYear, format), 0, 1, 0)
    AddStat(private.GetLocalizedText("THIS_MONTH_LABEL"), private.FormatTime(totalMonth, format), 0.4, 0.6, 1)
    AddStat(private.GetLocalizedText("THIS_WEEK_LABEL"), private.FormatTime(totalWeek, format), 1, 0.6, 1)
    AddStat(private.GetLocalizedText("TODAY_LABEL"), private.FormatTime(totalToday, format), 1, 1, 0.6)
    
    yOffset = yOffset - 20
    h = GetMiscCharFS(); h:SetFontObject("GameFontNormalLarge"); h:SetPoint("TOPLEFT", 10, yOffset); h:SetText(private.GetLocalizedText("CHARACTER_RANKING")); h:SetTextColor(1, 0.8, 0); yOffset = yOffset - 30

    for i, charData in ipairs(characters) do
        local entry = frame.accountFrames[i]
        if not entry then
            entry = CreateEntryFrame(frame.charactersContent)
            frame.accountFrames[i] = entry
        end
        entry:SetPoint("TOPLEFT", 10, yOffset)
        entry:Show()
        
        -- Striping
        if i % 2 == 1 then 
            entry:SetBackdropColor(0.08, 0.08, 0.08, 0.8) 
        else 
            entry:SetBackdropColor(0.03, 0.03, 0.03, 0.4) 
        end

        
        local char = charData.char
        local hex = private.GetClassHexColor and private.GetClassHexColor(char.classFile) or "ffffffff"
        local classColorR, classColorG, classColorB = 1, 1, 1
        if private.GetClassRGB then
             classColorR, classColorG, classColorB = private.GetClassRGB(char.classFile)
        end
        if type(classColorR) ~= "number" then classColorR, classColorG, classColorB = 1, 1, 1 end

        -- Icon
        entry:ToggleIcon(true)
        SetPortraitTexture(entry.icon, "player") -- Fallback or placeholder, ideal would be class icon
        entry.icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        local coords =CLASS_ICON_TCOORDS[char.classFile]
        if coords then
            entry.icon:SetTexCoord(unpack(coords))
        else
            entry.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end

        local nameStr = "|c" .. hex .. char.name .. "|r"
        if charData.key == private.playerKey then nameStr = nameStr .. " |cff00ff00(" .. private.GetLocalizedText("CURRENT") .. ")" .. "|r" end
        entry.name:SetText(nameStr)
        entry.rightText:SetText(private.FormatTime(char.totalTime, format))

        
        local pct = totalAccountTime > 0 and (char.totalTime / totalAccountTime) or 0
        entry.bar:SetMinMaxValues(0, totalAccountTime > 0 and totalAccountTime or 1)
        entry.bar:SetValue(char.totalTime)
        entry.bar:SetStatusBarColor(classColorR, classColorG, classColorB)
        entry.barText:SetText(string.format("%.1f%%", pct * 100))
        
        -- Extra details line
        entry.subText:SetText(string.format("%s - Lvl %s %s", char.realm or "", char.level or "?", char.race or ""))
        
        yOffset = yOffset - 55
    end

    local neededHeight = math.abs(yOffset) + 50
    frame.charactersContent:SetHeight(math.max(450, neededHeight))
end


-- NEW: Update Activities Stats (AFK, Dungeons, Raids)
function private.UpdateActivitiesStats(frame)
    local activityType = frame.activityTypeDropdown.selectedActivity or "afk"
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    
    local currentYear = private.GetCurrentYear and private.GetCurrentYear() or date("%Y")
    local currentMonth = private.GetCurrentMonth()
    local currentWeek = private.GetCurrentWeek()
    local currentDate = private.GetCurrentDate()

    local characters = {}
    local totalActivityTime = 0
    local totalActivityYear = 0
    local totalActivityMonth = 0
    local totalActivityWeek = 0
    local totalActivityToday = 0

    local function GetActVal(historyTable, key, actType)
        if not historyTable or not historyTable[key] then return 0 end
        return historyTable[key][actType] or 0
    end
    
    for key, char in pairs(TimeTrackerDB.characters) do
        local actVal = 0
        local actYearVal = 0
        local actMonthVal = 0
        local actWeekVal = 0
        local actTodayVal = 0
        
        if char.activities then
             actVal = char.activities[activityType] or 0
        end
        
        -- Try to use history if available, fall back to yearly if old data
        if char.activityHistory then
            actYearVal = GetActVal(char.activityHistory.yearly, currentYear, activityType)
            actMonthVal = GetActVal(char.activityHistory.monthly, currentMonth, activityType)
            actWeekVal = GetActVal(char.activityHistory.weekly, currentWeek, activityType)
            actTodayVal = GetActVal(char.activityHistory.daily, currentDate, activityType)
        elseif char.activitiesYearly and char.activitiesYearly[currentYear] then
             -- Backwards compatibility for the short time it existed
             actYearVal = char.activitiesYearly[currentYear][activityType] or 0
        end

        if actVal > 0 or actYearVal > 0 then
            table.insert(characters, {
                key = key,
                char = char,
                val = actVal,
                valYear = actYearVal,
                valMonth = actMonthVal,
                valWeek = actWeekVal,
                valToday = actTodayVal
            })
            totalActivityTime = totalActivityTime + actVal
            totalActivityYear = totalActivityYear + actYearVal
            totalActivityMonth = totalActivityMonth + actMonthVal
            totalActivityWeek = totalActivityWeek + actWeekVal
            totalActivityToday = totalActivityToday + actTodayVal
        end
    end
    
    table.sort(characters, function(a,b) return a.val > b.val end)
    
    -- Cleanup
    if frame.activityFrames then for _, f in pairs(frame.activityFrames) do f:Hide() end end
    frame.activityFrames = frame.activityFrames or {}
    
    frame.actMiscFS = frame.actMiscFS or {}
    for _, fs in ipairs(frame.actMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscActFS()
        miscFSIndex = miscFSIndex + 1
        return CreateOrReuseFontString(frame.actMiscFS, frame.activitiesContent, miscFSIndex, "GameFontHighlight")
    end
    
    local yOffset = -10
    
    local yOffset = -10
    
    local nameMap = { 
        afk = private.GetLocalizedText("CATEGORY_AFK"), 
        dungeons = private.GetLocalizedText("CATEGORY_DUNGEONS"), 
        raids = private.GetLocalizedText("CATEGORY_RAIDS"),
        bgs = private.GetLocalizedText("CATEGORY_BGS"),
        arenas = private.GetLocalizedText("CATEGORY_ARENAS"),
        queues = private.GetLocalizedText("CATEGORY_QUEUES"),
        dead = private.GetLocalizedText("CATEGORY_DEAD"),
        petbattles = private.GetLocalizedText("CATEGORY_PETBATTLES"),
        taxi = private.GetLocalizedText("CATEGORY_TAXI"),
        scenarios = private.GetLocalizedText("CATEGORY_SCENARIOS"),
        auction = private.GetLocalizedText("CATEGORY_AUCTION"),
        professions = private.GetLocalizedText("CATEGORY_PROFESSIONS"),
        city = private.GetLocalizedText("CATEGORY_CITY"),
        world = private.GetLocalizedText("CATEGORY_WORLD")
    }
    local currentName = nameMap[activityType] or activityType
    
    -- Header Stats
    local h = GetMiscActFS(); h:SetFontObject("GameFontNormalLarge"); h:SetPoint("TOPLEFT", 10, yOffset); h:SetText(string.format(private.GetLocalizedText("TOTAL_ACTIVITY"), currentName)); h:SetTextColor(1, 0.8, 0); yOffset = yOffset - 30
    
    -- Use columns for totals
    local t = GetMiscActFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("TOTAL") .. ": " .. private.FormatTime(totalActivityTime, format)); t:SetTextColor(1,1,1); yOffset = yOffset - 20
    t = GetMiscActFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("THIS_YEAR_LABEL") .. ": " .. private.FormatTime(totalActivityYear, format)); t:SetTextColor(0,1,0); yOffset = yOffset - 20
    t = GetMiscActFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("THIS_MONTH_LABEL") .. ": " .. private.FormatTime(totalActivityMonth, format)); t:SetTextColor(0.4, 0.6, 1); yOffset = yOffset - 20
    t = GetMiscActFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("THIS_WEEK_LABEL") .. ": " .. private.FormatTime(totalActivityWeek, format)); t:SetTextColor(1, 0.6, 1); yOffset = yOffset - 20
    t = GetMiscActFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("TODAY") .. ": " .. private.FormatTime(totalActivityToday, format)); t:SetTextColor(1, 1, 0.6); yOffset = yOffset - 30
    
    h = GetMiscActFS(); h:SetFontObject("GameFontNormalLarge"); h:SetPoint("TOPLEFT", 10, yOffset); h:SetText(private.GetLocalizedText("CHARACTER_RANKING")); h:SetTextColor(0.6, 0.8, 1); yOffset = yOffset - 25
    
    if #characters == 0 then
        t = GetMiscActFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(private.GetLocalizedText("NO_DATA")); t:SetTextColor(0.5,0.5,0.5); yOffset = yOffset - 20
    end

    for i, data in ipairs(characters) do
        local entry = frame.activityFrames[i]
        if not entry then
            entry = CreateEntryFrame(frame.activitiesContent)
            frame.activityFrames[i] = entry
        end
        entry:SetPoint("TOPLEFT", frame.activitiesContent, "TOPLEFT", 10, yOffset)
        entry:Show()
        
        if i % 2 == 1 then 
            entry:SetBackdropColor(0.08, 0.08, 0.08, 0.8) 
        else 
            entry:SetBackdropColor(0.03, 0.03, 0.03, 0.4) 
        end
        
        local char = data.char
        local hex = private.GetClassHexColor and private.GetClassHexColor(char.classFile) or "ffffffff"
        local r,g,b = private.GetClassRGB and private.GetClassRGB(char.classFile) or 1,1,1
        
        -- Customizing the standard entry for activities
        entry:ToggleIcon(true)
        entry.icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        local coords = CLASS_ICON_TCOORDS[char.classFile]
        if coords then entry.icon:SetTexCoord(unpack(coords)) end

        entry.name:SetText("|c" .. hex .. char.name .. "|r (" .. (char.realm or "") .. ")")
        entry.rightText:SetText(private.FormatTime(data.val, format))

        
        local pct = totalActivityTime > 0 and (data.val / totalActivityTime) or 0
        entry.bar:SetMinMaxValues(0, totalActivityTime > 0 and totalActivityTime or 1)
        entry.bar:SetValue(data.val)
        entry.bar:SetStatusBarColor(r, g, b, 0.8)
        entry.barText:SetText(string.format("%.1f%%", pct * 100))
        
        entry.subText:SetText(
            private.GetLocalizedText("THIS_YEAR_LABEL") .. ": " .. private.FormatTime(data.valYear, format) .. " | " ..
            private.GetLocalizedText("TODAY") .. ": " .. private.FormatTime(data.valToday, format)
        )
        
        yOffset = yOffset - 55
    end
    
    local neededHeight = math.abs(yOffset) + 50
    frame.activitiesContent:SetHeight(math.max(450, neededHeight))
end

-- UI Helper: Create Custom Tab Button
local function CreateTabButton(parent, text, width)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, 32)
    
    btn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    btn:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
    btn:SetBackdropBorderColor(1, 1, 1, 0.1)
    
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.text:SetPoint("CENTER", 0, 1)
    btn.text:SetText(text)
    btn.text:SetScale(0.95)
    
    -- Highlight state
    btn:SetScript("OnEnter", function(self)
        if not self.selected then
            self:SetBackdropColor(0.15, 0.15, 0.2, 1)
            self:SetBackdropBorderColor(1, 1, 1, 0.3)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if not self.selected then
            self:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
            self:SetBackdropBorderColor(1, 1, 1, 0.1)
        end
    end)

    -- Selected Indicator (Top Bar - more modern)
    btn.selectedBar = btn:CreateTexture(nil, "OVERLAY")
    btn.selectedBar:SetHeight(2)
    btn.selectedBar:SetPoint("TOPLEFT", 1, -1)
    btn.selectedBar:SetPoint("TOPRIGHT", -1, -1)
    btn.selectedBar:SetColorTexture(0, 0.8, 1) -- Cyan accent for modern feel
    btn.selectedBar:Hide()

    -- Method to set state
    btn.SetSelected = function(self, isSelected)
        self.selected = isSelected
        if isSelected then
            self:SetBackdropColor(0.02, 0.02, 0.05, 1)
            self:SetBackdropBorderColor(0, 0.8, 1, 0.6)
            self.text:SetTextColor(1, 1, 1)
            self.selectedBar:Show()
        else
            self:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
            self:SetBackdropBorderColor(1, 1, 1, 0.1)
            self.text:SetTextColor(0.7, 0.7, 0.8)
            self.selectedBar:Hide()
        end
    end
    
    return btn
end


-- Update Tab Appearance (Updated for new buttons)
local function UpdateTabAppearance(frame)
    if not frame then return end
    local tabs = {frame.tabPersonal, frame.tabCharacters, frame.tabClasses, frame.tabRaces, frame.tabActivities, frame.tabSummary, frame.tabStatistics}
    for _, tab in ipairs(tabs) do
        if tab then tab:SetSelected(tab.selected) end
    end
end


-- NEW: Update Summary Stats
function private.UpdateSummaryStats(frame)
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    
    if not frame.summaryState then
        frame.summaryState = { view = "years", year = nil, month = nil }
    end
    local state = frame.summaryState
    
    if frame.summaryFrames then for _, f in pairs(frame.summaryFrames) do f:Hide() end end
    frame.summaryFrames = frame.summaryFrames or {}
    
    frame.summaryMiscFS = frame.summaryMiscFS or {}
    for _, fs in ipairs(frame.summaryMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscSummaryFS()
        miscFSIndex = miscFSIndex + 1
        return CreateOrReuseFontString(frame.summaryMiscFS, frame.summaryContent, miscFSIndex, "GameFontHighlight")
    end
    
    local yOffset = -10
    
    local headerText = ""
    if state.view == "years" then
        headerText = private.GetLocalizedText("VIEW_YEARS")
    elseif state.view == "months" then
        headerText = state.year
    elseif state.view == "days" then
        headerText = state.year .. " - " .. state.month
    elseif state.view == "day_detail" then
        headerText = state.day
    end
    
    local h = GetMiscSummaryFS()
    h:SetFontObject("GameFontNormalLarge")
    h:SetPoint("TOPLEFT", 10, yOffset)
    h:SetText(headerText)
    h:SetTextColor(1, 0.8, 0)
    
    if state.view ~= "years" then
        if not frame.summaryBackButton then
            frame.summaryBackButton = CreateFrame("Button", nil, frame.summaryPanel, "UIPanelButtonTemplate")
            frame.summaryBackButton:SetSize(80, 22)
            frame.summaryBackButton:SetText(private.GetLocalizedText("BACK"))
            frame.summaryBackButton:SetScript("OnClick", function()
                if frame.summaryState.view == "day_detail" then
                    frame.summaryState.view = "days"
                    frame.summaryState.day = nil
                elseif frame.summaryState.view == "days" then
                    frame.summaryState.view = "months"
                    frame.summaryState.month = nil
                elseif frame.summaryState.view == "months" then
                    frame.summaryState.view = "years"
                    frame.summaryState.year = nil
                end
                private.UpdateSummaryStats(frame)
            end)
        end
        frame.summaryBackButton:SetPoint("TOPRIGHT", frame.summaryPanel, "TOPRIGHT", -25, -5)
        frame.summaryBackButton:Show()
    else
        if frame.summaryBackButton then frame.summaryBackButton:Hide() end
    end
    
    yOffset = yOffset - 30

    local dataMap = {}
    local totalTimeInView = 0
    
    local function AddToMap(key, amount, details, activityMap)
        if not dataMap[key] then dataMap[key] = { time = 0, sortKey = key, activities = {} } end
        dataMap[key].time = dataMap[key].time + amount
        if activityMap then
             for act, val in pairs(activityMap) do
                 dataMap[key].activities[act] = (dataMap[key].activities[act] or 0) + val
             end
        end
    end

    if state.view == "years" then
        for _, char in pairs(TimeTrackerDB.characters) do
            if char.yearly then
                for y, t in pairs(char.yearly) do AddToMap(y, t) end
            end
        end
    elseif state.view == "months" then
        local targetYear = state.year
        for _, char in pairs(TimeTrackerDB.characters) do
            if char.monthly then
                for m, t in pairs(char.monthly) do
                    if string.sub(m, 1, 4) == targetYear then AddToMap(m, t) end
                end
            end
        end
    elseif state.view == "days" then
        local targetMonth = state.month 
        for _, char in pairs(TimeTrackerDB.characters) do
            if char.daily then
                for d, t in pairs(char.daily) do
                     if string.sub(d, 1, 7) == targetMonth then
                         AddToMap(d, t)
                     end
                end
            end
        end
    elseif state.view == "day_detail" then
        local targetDay = state.day
        -- Iterate all chars to get activity breakdown for this day
        for _, char in pairs(TimeTrackerDB.characters) do
            if char.activityHistory and char.activityHistory.daily and char.activityHistory.daily[targetDay] then
                for act, val in pairs(char.activityHistory.daily[targetDay]) do
                    AddToMap(act, val)
                end
            end
        end
    end
    
    local sortedList = {}
    for k, v in pairs(dataMap) do
        table.insert(sortedList, { key = k, time = v.time, sortKey = k, activities = v.activities })
        totalTimeInView = totalTimeInView + v.time
    end
    table.sort(sortedList, function(a,b) return a.sortKey > b.sortKey end)
    
    local tTotal = GetMiscSummaryFS()
    tTotal:SetPoint("TOPLEFT", 10, yOffset)
    tTotal:SetText(private.GetLocalizedText("TOTAL") .. ": " .. private.FormatTime(totalTimeInView, format))
    tTotal:SetTextColor(0, 1, 0)
    yOffset = yOffset - 25
    
    for i, data in ipairs(sortedList) do
        local entry = frame.summaryFrames[i]
        if not entry then
            entry = CreateEntryFrame(frame.summaryContent)
            frame.summaryFrames[i] = entry
            entry:RegisterForClicks("LeftButtonUp")
            entry:SetScript("OnClick", function(self)
                local clickedKey = self.dataKey
                if not clickedKey then return end
                if frame.summaryState.view == "years" then
                    frame.summaryState.view = "months"
                    frame.summaryState.year = clickedKey
                    private.UpdateSummaryStats(frame)
                elseif frame.summaryState.view == "months" then
                    frame.summaryState.view = "days"
                    frame.summaryState.month = clickedKey
                    private.UpdateSummaryStats(frame)
                elseif frame.summaryState.view == "days" then
                    frame.summaryState.view = "day_detail"
                    frame.summaryState.day = clickedKey
                    private.UpdateSummaryStats(frame)
                end
            end)
        end
        entry.dataKey = data.key
        entry:SetPoint("TOPLEFT", 10, yOffset)
        entry:Show()
        if i % 2 == 1 then 
            entry:SetBackdropColor(0.08, 0.08, 0.08, 0.8) 
        else 
            entry:SetBackdropColor(0.03, 0.03, 0.03, 0.4) 
        end

        entry:ToggleIcon(false)

        
        local displayName = data.key
        if state.view == "months" then
             local year, month = string.match(data.key, "(%d+)-(%d+)")
             if month and CALENDAR_FULLDATE_MONTH_NAMES then
                 displayName = CALENDAR_FULLDATE_MONTH_NAMES[tonumber(month)] .. " " .. year
             end
        elseif state.view == "days" then
            local y, m, d = string.match(data.key, "(%d+)-(%d+)-(%d+)")
            if y then
                local tDate = time({year=y, month=m, day=d})
                displayName = data.key .. " (" .. date("%A", tDate) .. ")"
            end
        end
        entry.name:SetText(displayName)
        entry.rightText:SetText(private.FormatTime(data.time, format))
        
        local pct = totalTimeInView > 0 and (data.time / totalTimeInView) or 0
        entry.bar:SetMinMaxValues(0, totalTimeInView > 0 and totalTimeInView or 1)
        entry.bar:SetValue(data.time)
        entry.bar:SetStatusBarColor(1, 0.82, 0)
        entry.barText:SetText(string.format("%.1f%%", pct * 100))
        
        local sub = ""
        if state.view == "day_detail" then
             -- Activity Entry
             local actKey = data.key
             local actName = private.GetLocalizedText("CATEGORY_" .. string.upper(actKey)) or actKey
             entry.name:SetText(actName)
             sub = private.GetLocalizedText("TIME_COLON") .. " " .. private.FormatTime(data.time, format)
             
             -- Colors only (No Icons)
             entry:ToggleIcon(false)
             local r, g, b = 1, 1, 1

             
             if actKey == "afk" then 
                r,g,b = 0.5, 0.5, 0.5 -- Grey
             elseif actKey == "dungeons" then
                r,g,b = 1, 0.5, 0 -- Orange
             elseif actKey == "raids" then
                r,g,b = 1, 0, 0 -- Red
             elseif actKey == "bgs" or actKey == "pvp" then
                r,g,b = 0, 0.5, 1 -- Blue
             elseif actKey == "arenas" then
                r,g,b = 0.6, 0, 1 -- Purple
             elseif actKey == "dead" then
                r,g,b = 0.3, 0.3, 0.3 -- Dark Grey
             elseif actKey == "petbattles" then
                r,g,b = 0.2, 0.8, 0.2 -- Greenish
             elseif actKey == "taxi" then
                r,g,b = 0.8, 0.8, 1 -- Light Blue
             elseif actKey == "scenarios" then
                r,g,b = 0, 0.8, 0.8 -- Teal
             elseif actKey == "auction" then
                r,g,b = 1, 0.8, 0 -- Gold
             elseif actKey == "professions" then
                r,g,b = 0.6, 0.4, 0.2 -- Brown
             elseif actKey == "city" then
                r,g,b = 0.4, 0.4, 1 -- Blue-ish
             elseif actKey == "world" then
                r,g,b = 0.2, 1, 0.2 -- Green
             elseif actKey == "queues" then
                r,g,b = 1, 1, 0 -- Yellow
             end
             
             entry.bar:SetStatusBarColor(r, g, b)
             
             -- Override display name as we set it above
             displayName = actName
        elseif state.view == "days" then

            sub = private.GetLocalizedText("CLICK_DETAILS") or "Click for details"
        elseif state.view == "years" then 
            sub = private.GetLocalizedText("TOTAL_YEAR")
        elseif state.view == "months" then 
            sub = private.GetLocalizedText("TOTAL_MONTH") 
        end
        
        if state.view == "day_detail" then
             -- No need to do date parsing for activity keys
             entry.name:SetText(displayName)
        elseif state.view == "days" then
             local y, m, d = string.match(data.key, "(%d+)-(%d+)-(%d+)")
             if y then
                local tDate = time({year=y, month=m, day=d})
                displayName = data.key .. " (" .. date("%A", tDate) .. ")"
             end
             entry.name:SetText(displayName)
        end
        
        entry.subText:SetText(sub)
        yOffset = yOffset - 55
    end
    local neededHeight = math.abs(yOffset) + 50
    frame.summaryContent:SetHeight(math.max(450, neededHeight))
end


-- NEW: Update Statistics Stats (Records and Insights)
function private.UpdateStatisticsStats(frame)
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    
    -- Clear previous frames
    if frame.statsFrames then for _, f in pairs(frame.statsFrames) do f:Hide() end end
    frame.statsFrames = frame.statsFrames or {}
    
    frame.statsMiscFS = frame.statsMiscFS or {}
    for _, fs in ipairs(frame.statsMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscStatsFS()
        miscFSIndex = miscFSIndex + 1
        return CreateOrReuseFontString(frame.statsMiscFS, frame.statsContent, miscFSIndex, "GameFontHighlight")
    end
    
    local yOffset = -20
    
    -- Initialization
    local maxDay = {key="", val=0}
    local maxWeek = {key="", val=0}
    local maxMonth = {key="", val=0}
    local maxYear = {key="", val=0}
    local totalAllTime = 0
    local firstLogin = time() -- default to now
    local dayOfWeekStats = {0,0,0,0,0,0,0} -- Sunday (1) to Saturday (7)
    
    -- Merge data from all characters to find account-wide records
    local accountDaily = {}
    local accountWeekly = {}
    local accountMonthly = {}
    local accountYearly = {}
    
    for _, char in pairs(TimeTrackerDB.characters) do
        if char.firstLogin and char.firstLogin < firstLogin then firstLogin = char.firstLogin end
        if char.totalTime then totalAllTime = totalAllTime + char.totalTime end
        
        if char.daily then
            for d, t in pairs(char.daily) do
                accountDaily[d] = (accountDaily[d] or 0) + t
                -- Day of Week Analysis
                 local y, m, day = string.match(d, "(%d+)-(%d+)-(%d+)")
                 if y then
                    local tDate = time({year=tonumber(y), month=tonumber(m), day=tonumber(day)})
                    local wday = tonumber(date("%w", tDate)) + 1 -- Lua returns 0-6 (Sun-Sat), we want 1-7
                    if dayOfWeekStats[wday] then
                        dayOfWeekStats[wday] = dayOfWeekStats[wday] + t
                    end
                 end
            end
        end
        if char.weekly then
            for w, t in pairs(char.weekly) do accountWeekly[w] = (accountWeekly[w] or 0) + t end
        end
        if char.monthly then
            for m, t in pairs(char.monthly) do accountMonthly[m] = (accountMonthly[m] or 0) + t end
        end
        if char.yearly then
            for y, t in pairs(char.yearly) do accountYearly[y] = (accountYearly[y] or 0) + t end
        end
    end
    
    -- Calculate Max Records
    for k, v in pairs(accountDaily) do if v > maxDay.val then maxDay.key = k; maxDay.val = v end end
    for k, v in pairs(accountWeekly) do if v > maxWeek.val then maxWeek.key = k; maxWeek.val = v end end
    for k, v in pairs(accountMonthly) do if v > maxMonth.val then maxMonth.key = k; maxMonth.val = v end end
    for k, v in pairs(accountYearly) do if v > maxYear.val then maxYear.key = k; maxYear.val = v end end
    
    -- Calculate Averages
    -- ISSUE FIX: totalAllTime includes historical /played which is HUGE.
    -- We should only average the time captured by THIS addon in the daily table.
    local totalRecordedTime = 0
    local countDays = 0
    for k, v in pairs(accountDaily) do
        totalRecordedTime = totalRecordedTime + v
        countDays = countDays + 1
    end
    
    local dailyAvg = 0
    if countDays > 0 then
        dailyAvg = totalRecordedTime / countDays
    end
    
    -- Calculate Favorite Day
    local favDayIndex = 1
    local favDayVal = -1
    for i=1, 7 do
        if dayOfWeekStats[i] > favDayVal then
            favDayVal = dayOfWeekStats[i]
            favDayIndex = i
        end
    end
    
    -- Localized Day Names
    local weekDays = {CALENDAR_SUNDAY, CALENDAR_MONDAY, CALENDAR_TUESDAY, CALENDAR_WEDNESDAY, CALENDAR_THURSDAY, CALENDAR_FRIDAY, CALENDAR_SATURDAY}
    if GetLocale() == "esES" or GetLocale() == "esMX" then
       weekDays = {"Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"}
    end
    
    local favDayName = weekDays[favDayIndex] or "?"
    
    -- Calculate Projection (Linear projection based on daily average)
    local projected = dailyAvg * 365

    -- RENDER UI
    local function AddHeader(text, r, g, b)
        local h = GetMiscStatsFS()
        h:SetFontObject("GameFontNormalLarge")
        h:SetPoint("TOPLEFT", 10, yOffset)
        h:SetText(text)
        h:SetTextColor(r, g, b)
        yOffset = yOffset - 30
    end

    local function AddRecordRow(label, valStr, dataKey, color)
        local l = GetMiscStatsFS()
        l:SetPoint("TOPLEFT", 20, yOffset)
        l:SetText(label .. ":")
        l:SetTextColor(0.7, 0.7, 0.7)
        
        local v = GetMiscStatsFS()
        v:SetPoint("TOPLEFT", 200, yOffset)
        
        local fullText = valStr
        if dataKey and dataKey ~= "" then 
            -- Format Key for better readability
            -- Week: 2026-W06 -> 9 Feb - 15 Feb (Localized)
            local wYear, wNum = string.match(dataKey, "(%d+)-W(%d+)")
            if wYear and wNum then
                local y, w = tonumber(wYear), tonumber(wNum)
                -- Calculate Start of Week (ISO)
                -- Jan 4th is always in Week 1
                local jan4 = time({year=y, month=1, day=4})
                local d = date("*t", jan4)
                local wday = d.wday -- Sun=1, Mon=2 ...
                local iso_wday = (wday - 2) % 7 + 1 -- Mon=1 ... Sun=7
                
                local mondayWeek1 = jan4 - (iso_wday - 1) * 86400
                local startWeek = mondayWeek1 + (w - 1) * 7 * 86400
                local endWeek = startWeek + 6 * 86400
                
                local sDay = date("%d", startWeek)
                local sMonth = date("%m", startWeek)
                local eDay = date("%d", endWeek)
                local eMonth = date("%m", endWeek)
                
                local sMonthName = (CALENDAR_FULLDATE_MONTH_NAMES and CALENDAR_FULLDATE_MONTH_NAMES[tonumber(sMonth)]) or sMonth
                local eMonthName = (CALENDAR_FULLDATE_MONTH_NAMES and CALENDAR_FULLDATE_MONTH_NAMES[tonumber(eMonth)]) or eMonth
                
                if GetLocale() == "esES" or GetLocale() == "esMX" then
                    dataKey = sDay .. " de " .. sMonthName .. " - " .. eDay .. " de " .. eMonthName
                else
                    dataKey = sDay .. " " .. sMonthName .. " - " .. eDay .. " " .. eMonthName
                end
            end
            
            -- Month: 2026-02 -> Febrero 2026
            local mYear, mNum = string.match(dataKey, "(%d+)-(%d+)")
            if mNum and not string.find(dataKey, "-W") and not string.find(dataKey, "%d%d-%d%d") then
                 if CALENDAR_FULLDATE_MONTH_NAMES then
                    dataKey = CALENDAR_FULLDATE_MONTH_NAMES[tonumber(mNum)] .. " " .. mYear
                 else
                    dataKey = mNum .. "/" .. mYear
                 end
            end
            
            fullText = fullText .. " |cff888888(" .. dataKey .. ")|r" 
        end
        v:SetText(fullText)
        if color then v:SetTextColor(unpack(color)) else v:SetTextColor(1,1,1) end
        
        yOffset = yOffset - 25
    end

    AddHeader(private.GetLocalizedText("RECORDS_TITLE"), 1, 0.8, 0)
    
    AddRecordRow(private.GetLocalizedText("RECORD_DAY"), private.FormatTime(maxDay.val, format), maxDay.key, {1, 0.5, 0})
    AddRecordRow(private.GetLocalizedText("RECORD_WEEK"), private.FormatTime(maxWeek.val, format), maxWeek.key, {1, 0.8, 0})
    AddRecordRow(private.GetLocalizedText("RECORD_MONTH"), private.FormatTime(maxMonth.val, format), maxMonth.key, {0, 1, 0})
    AddRecordRow(private.GetLocalizedText("RECORD_YEAR"), private.FormatTime(maxYear.val, format), maxYear.key, {0, 0.6, 1})
    
    yOffset = yOffset - 10
    AddHeader("--- Insights ---", 0.5, 0.8, 1) -- Keep Insights in English or localized

    AddRecordRow(private.GetLocalizedText("AVG_DAILY"), private.FormatTime(dailyAvg, format), nil, {1, 1, 1})
    AddRecordRow(private.GetLocalizedText("MOST_PLAYED_DAY"), favDayName, nil, {1, 1, 0})
    AddRecordRow(private.GetLocalizedText("PROJECTED_YEAR"), private.FormatTime(projected, format), currentYear, {0.8, 0.5, 1})

    local neededHeight = math.abs(yOffset) + 50
    frame.statsContent:SetHeight(math.max(450, neededHeight))
end

-- Update Backup Panel
function private.UpdateBackupPanel(frame)
    if not frame.backupPanel then return end
    -- The panel is static, but we can clear the box if needed
    -- frame.backupEditBox:SetText("")
end


-- Create Main Frame
function private.CreateMainFrame()
    local frame = CreateFrame("Frame", "TimeTrackerFrame", UIParent, "BasicFrameTemplateWithInset, BackdropTemplate")
    frame:SetSize(720, 620) -- Slightly larger for a more spacious feel
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    -- Close button override for better look
    if frame.CloseButton then
        frame.CloseButton:SetScale(0.8)
        frame.CloseButton:SetPoint("TOPRIGHT", -5, -5)
    end

    -- Main Frame Styling
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.95)
    frame:SetBackdropBorderColor(0, 0.8, 1, 0.5) -- Cyan glow

    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlightLarge")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -5)
    frame.title:SetText("|cff00ccff" .. private.GetLocalizedText("ADDON_NAME") .. "|r")

    if frame.Inset then
        frame.Inset:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -50)
        frame.Inset:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    end


    -- Tab Container (to center them if needed, or just position relative)
    local startX = 15
    local tabY = -28
    
    frame.tabPersonal = CreateTabButton(frame, private.GetLocalizedText("CURRENT_CHARACTER"), 100)
    frame.tabPersonal:SetPoint("TOPLEFT", frame, "TOPLEFT", startX, tabY)
    frame.tabPersonal.selected = true
    
    frame.tabCharacters = CreateTabButton(frame, private.GetLocalizedText("CHARACTERS_TAB"), 90)
    frame.tabCharacters:SetPoint("LEFT", frame.tabPersonal, "RIGHT", 5, 0)
    
    frame.tabClasses = CreateTabButton(frame, private.GetLocalizedText("CLASSES_TAB"), 70)
    frame.tabClasses:SetPoint("LEFT", frame.tabCharacters, "RIGHT", 5, 0)
    
    frame.tabRaces = CreateTabButton(frame, private.GetLocalizedText("RACES_TAB"), 70)
    frame.tabRaces:SetPoint("LEFT", frame.tabClasses, "RIGHT", 5, 0)
    
    frame.tabActivities = CreateTabButton(frame, private.GetLocalizedText("ACTIVITIES_TAB"), 90)
    frame.tabActivities:SetPoint("LEFT", frame.tabRaces, "RIGHT", 5, 0)
    
    frame.tabSummary = CreateTabButton(frame, private.GetLocalizedText("SUMMARY_TAB"), 80)
    frame.tabSummary:SetPoint("LEFT", frame.tabActivities, "RIGHT", 5, 0)
    
    -- Tab Statistics (New)
    frame.tabStatistics = CreateTabButton(frame, private.GetLocalizedText("STATISTICS_TAB"), 90)
    frame.tabStatistics:SetPoint("LEFT", frame.tabSummary, "RIGHT", 5, 0)
    
    -- Tab Backup (Newest)
    frame.tabBackup = CreateTabButton(frame, private.GetLocalizedText("BACKUP_TAB"), 70)
    frame.tabBackup:SetPoint("LEFT", frame.tabStatistics, "RIGHT", 5, 0)


    frame.personalPanel = CreateFrame("Frame", nil, frame)
    frame.personalPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.personalPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.personalPanel:Show()
    
    local personalFormatLabel = frame.personalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    personalFormatLabel:SetPoint("TOPLEFT", frame.personalPanel, "TOPLEFT", 10, -10)
    personalFormatLabel:SetText(private.GetLocalizedText("TIME_FORMAT"))
    
    frame.personalFormatDropdown = CreateTimeFormatDropdown(frame.personalPanel, 5, -30)

    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame.personalPanel, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", frame.personalFormatDropdown, "BOTTOMLEFT", 0, -20)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame.personalPanel, "BOTTOMRIGHT", -20, 5)
    frame.content = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.content:SetSize(430, 450)
    frame.scrollFrame:SetScrollChild(frame.content)

    frame.charactersPanel = CreateFrame("Frame", nil, frame)
    frame.charactersPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.charactersPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.charactersPanel:Hide()
    
    local charFormatLabel = frame.charactersPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    charFormatLabel:SetPoint("TOPLEFT", frame.charactersPanel, "TOPLEFT", 10, -10)
    charFormatLabel:SetText(private.GetLocalizedText("TIME_FORMAT"))
    
    frame.charFormatDropdown = CreateTimeFormatDropdown(frame.charactersPanel, 5, -30)
    
    frame.charactersScrollFrame = CreateFrame("ScrollFrame", nil, frame.charactersPanel, "UIPanelScrollFrameTemplate")
    frame.charactersScrollFrame:SetPoint("TOPLEFT", frame.charFormatDropdown, "BOTTOMLEFT", 0, -20)
    frame.charactersScrollFrame:SetPoint("BOTTOMRIGHT", frame.charactersPanel, "BOTTOMRIGHT", -20, 5)
    frame.charactersContent = CreateFrame("Frame", nil, frame.charactersScrollFrame)
    frame.charactersContent:SetSize(450, 500)
    frame.charactersScrollFrame:SetScrollChild(frame.charactersContent)

    frame.classesPanel = CreateFrame("Frame", nil, frame)
    frame.classesPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.classesPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.classesPanel:Hide()
    
    local classFormatLabel = frame.classesPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classFormatLabel:SetPoint("TOPLEFT", frame.classesPanel, "TOPLEFT", 10, -10)
    classFormatLabel:SetText(private.GetLocalizedText("TIME_FORMAT"))
    
    frame.classFormatDropdown = CreateTimeFormatDropdown(frame.classesPanel, 5, -30)
    
    frame.classesScrollFrame = CreateFrame("ScrollFrame", nil, frame.classesPanel, "UIPanelScrollFrameTemplate")
    frame.classesScrollFrame:SetPoint("TOPLEFT", frame.classFormatDropdown, "BOTTOMLEFT", 0, -20)
    frame.classesScrollFrame:SetPoint("BOTTOMRIGHT", frame.classesPanel, "BOTTOMRIGHT", -20, 5)
    frame.classesContent = CreateFrame("Frame", nil, frame.classesScrollFrame)
    frame.classesContent:SetSize(450, 500)
    frame.classesScrollFrame:SetScrollChild(frame.classesContent)

    frame.racesPanel = CreateFrame("Frame", nil, frame)
    frame.racesPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.racesPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.racesPanel:Hide()
    
    local raceFormatLabel = frame.racesPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    raceFormatLabel:SetPoint("TOPLEFT", frame.racesPanel, "TOPLEFT", 10, -10)
    raceFormatLabel:SetText(private.GetLocalizedText("TIME_FORMAT"))
    
    frame.raceFormatDropdown = CreateTimeFormatDropdown(frame.racesPanel, 5, -30)
    
    frame.racesScrollFrame = CreateFrame("ScrollFrame", nil, frame.racesPanel, "UIPanelScrollFrameTemplate")
    frame.racesScrollFrame:SetPoint("TOPLEFT", frame.raceFormatDropdown, "BOTTOMLEFT", 0, -20)
    frame.racesScrollFrame:SetPoint("BOTTOMRIGHT", frame.racesPanel, "BOTTOMRIGHT", -20, 5)
    frame.racesContent = CreateFrame("Frame", nil, frame.racesScrollFrame)
    frame.racesContent:SetSize(450, 500)
    frame.racesScrollFrame:SetScrollChild(frame.racesContent)

    -- Panel Activities
    frame.activitiesPanel = CreateFrame("Frame", nil, frame)
    frame.activitiesPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.activitiesPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.activitiesPanel:Hide()
    
    local actFormatLabel = frame.activitiesPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    actFormatLabel:SetPoint("TOPLEFT", frame.activitiesPanel, "TOPLEFT", 10, -10)
    actFormatLabel:SetText(private.GetLocalizedText("SELECT_ACTIVITY"))
    
    frame.activityTypeDropdown = CreateFrame("Button", nil, frame.activitiesPanel, "UIDropDownMenuTemplate")
    frame.activityTypeDropdown:SetPoint("TOPLEFT", frame.activitiesPanel, "TOPLEFT", 5, -30)
    UIDropDownMenu_SetWidth(frame.activityTypeDropdown, 150)
    UIDropDownMenu_SetText(frame.activityTypeDropdown, private.GetLocalizedText("CATEGORY_AFK"))
    frame.activityTypeDropdown.selectedActivity = "afk" -- default
    
    local function ActivityOnClick(self, arg1, arg2)
        frame.activityTypeDropdown.selectedActivity = arg1
        UIDropDownMenu_SetText(frame.activityTypeDropdown, arg2)
        private.UpdateActivitiesStats(frame)
    end
    
    UIDropDownMenu_Initialize(frame.activityTypeDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = ActivityOnClick
        
        info.text = private.GetLocalizedText("CATEGORY_AFK")
        info.arg1 = "afk"
        info.arg2 = private.GetLocalizedText("CATEGORY_AFK")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "afk")
        UIDropDownMenu_AddButton(info)
        
        info.text = private.GetLocalizedText("CATEGORY_DUNGEONS")
        info.arg1 = "dungeons"
        info.arg2 = private.GetLocalizedText("CATEGORY_DUNGEONS")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "dungeons")
        UIDropDownMenu_AddButton(info)
        
        info.text = private.GetLocalizedText("CATEGORY_RAIDS")
        info.arg1 = "raids"
        info.arg2 = private.GetLocalizedText("CATEGORY_RAIDS")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "raids")
        UIDropDownMenu_AddButton(info)
        
        info.text = private.GetLocalizedText("CATEGORY_BGS")
        info.arg1 = "bgs"
        info.arg2 = private.GetLocalizedText("CATEGORY_BGS")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "bgs")
        UIDropDownMenu_AddButton(info)

        info.text = private.GetLocalizedText("CATEGORY_ARENAS")
        info.arg1 = "arenas"
        info.arg2 = private.GetLocalizedText("CATEGORY_ARENAS")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "arenas")
        UIDropDownMenu_AddButton(info)
        
        info.text = private.GetLocalizedText("CATEGORY_QUEUES")
        info.arg1 = "queues"
        info.arg2 = private.GetLocalizedText("CATEGORY_QUEUES")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "queues")
        UIDropDownMenu_AddButton(info)

        info.text = private.GetLocalizedText("CATEGORY_DEAD")
        info.arg1 = "dead"
        info.arg2 = private.GetLocalizedText("CATEGORY_DEAD")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "dead")
        UIDropDownMenu_AddButton(info)

        info.text = private.GetLocalizedText("CATEGORY_PETBATTLES")
        info.arg1 = "petbattles"
        info.arg2 = private.GetLocalizedText("CATEGORY_PETBATTLES")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "petbattles")
        UIDropDownMenu_AddButton(info)

        info.text = private.GetLocalizedText("CATEGORY_TAXI")
        info.arg1 = "taxi"
        info.arg2 = private.GetLocalizedText("CATEGORY_TAXI")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "taxi")
        UIDropDownMenu_AddButton(info)

        info.text = private.GetLocalizedText("CATEGORY_SCENARIOS")
        info.arg1 = "scenarios"
        info.arg2 = private.GetLocalizedText("CATEGORY_SCENARIOS")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "scenarios")
        UIDropDownMenu_AddButton(info)

        info.text = private.GetLocalizedText("CATEGORY_AUCTION")
        info.arg1 = "auction"
        info.arg2 = private.GetLocalizedText("CATEGORY_AUCTION")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "auction")
        UIDropDownMenu_AddButton(info)

        info.text = private.GetLocalizedText("CATEGORY_PROFESSIONS")
        info.arg1 = "professions"
        info.arg2 = private.GetLocalizedText("CATEGORY_PROFESSIONS")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "professions")
        UIDropDownMenu_AddButton(info)

        info.text = private.GetLocalizedText("CATEGORY_CITY")
        info.arg1 = "city"
        info.arg2 = private.GetLocalizedText("CATEGORY_CITY")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "city")
        UIDropDownMenu_AddButton(info)

        info.text = private.GetLocalizedText("CATEGORY_WORLD")
        info.arg1 = "world"
        info.arg2 = private.GetLocalizedText("CATEGORY_WORLD")
        info.checked = (frame.activityTypeDropdown.selectedActivity == "world")
        UIDropDownMenu_AddButton(info)
    end)
    
    frame.activitiesScrollFrame = CreateFrame("ScrollFrame", nil, frame.activitiesPanel, "UIPanelScrollFrameTemplate")
    frame.activitiesScrollFrame:SetPoint("TOPLEFT", frame.activityTypeDropdown, "BOTTOMLEFT", 0, -20)
    frame.activitiesScrollFrame:SetPoint("BOTTOMRIGHT", frame.activitiesPanel, "BOTTOMRIGHT", -20, 5)
    frame.activitiesContent = CreateFrame("Frame", nil, frame.activitiesScrollFrame)
    frame.activitiesContent:SetSize(600, 500)
    frame.activitiesScrollFrame:SetScrollChild(frame.activitiesContent)

    -- Panel Summary
    frame.summaryPanel = CreateFrame("Frame", nil, frame)
    frame.summaryPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.summaryPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.summaryPanel:Hide()
    
    frame.summaryScrollFrame = CreateFrame("ScrollFrame", nil, frame.summaryPanel, "UIPanelScrollFrameTemplate")
    frame.summaryScrollFrame:SetPoint("TOPLEFT", frame.summaryPanel, "TOPLEFT", 5, -5)
    frame.summaryScrollFrame:SetPoint("BOTTOMRIGHT", frame.summaryPanel, "BOTTOMRIGHT", -20, 5)
    frame.summaryContent = CreateFrame("Frame", nil, frame.summaryScrollFrame)
    frame.summaryContent:SetSize(600, 500)
    frame.summaryScrollFrame:SetScrollChild(frame.summaryContent)

    -- Panel Statistics
    frame.statsPanel = CreateFrame("Frame", nil, frame)
    frame.statsPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.statsPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.statsPanel:Hide()
    
    frame.statsScrollFrame = CreateFrame("ScrollFrame", nil, frame.statsPanel, "UIPanelScrollFrameTemplate")
    frame.statsScrollFrame:SetPoint("TOPLEFT", frame.statsPanel, "TOPLEFT", 5, -5)
    frame.statsScrollFrame:SetPoint("BOTTOMRIGHT", frame.statsPanel, "BOTTOMRIGHT", -20, 5)
    frame.statsContent = CreateFrame("Frame", nil, frame.statsScrollFrame)
    frame.statsContent:SetSize(600, 500)
    frame.statsScrollFrame:SetScrollChild(frame.statsContent)

    -- Panel Backup
    frame.backupPanel = CreateFrame("Frame", nil, frame)
    frame.backupPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -55)
    frame.backupPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.backupPanel:Hide()

    local backupTitle = frame.backupPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    backupTitle:SetPoint("TOPLEFT", 10, -10)
    backupTitle:SetText(private.GetLocalizedText("BACKUP_TAB"))
    backupTitle:SetTextColor(1, 0.8, 0)

    local backupDesc = frame.backupPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    backupDesc:SetPoint("TOPLEFT", 10, -40)
    backupDesc:SetPoint("TOPRIGHT", -10, -40)
    backupDesc:SetJustifyH("LEFT")
    backupDesc:SetText(private.GetLocalizedText("BACKUP_DESC"))

    -- Scrollable EditBox for the code
    local ebScroll = CreateFrame("ScrollFrame", "TimeTrackerBackupScroll", frame.backupPanel, "UIPanelScrollFrameTemplate, BackdropTemplate")
    ebScroll:SetSize(600, 300)
    ebScroll:SetPoint("TOPLEFT", 10, -100)
    ebScroll:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    ebScroll:SetBackdropColor(0, 0, 0, 0.5)

    local editBox = CreateFrame("EditBox", nil, ebScroll)
    editBox:SetMultiLine(true)
    editBox:SetMaxLetters(0)
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetWidth(580)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    ebScroll:SetScrollChild(editBox)
    frame.backupEditBox = editBox

    -- Buttons
    local exportBtn = CreateFrame("Button", nil, frame.backupPanel, "UIPanelButtonTemplate")
    exportBtn:SetSize(150, 30)
    exportBtn:SetPoint("TOPLEFT", ebScroll, "BOTTOMLEFT", 0, -10)
    exportBtn:SetText(private.GetLocalizedText("EXPORT_BUTTON"))
    exportBtn:SetScript("OnClick", function()
        local code = private.SerializeDatabase()
        editBox:SetText(code)
        editBox:SetFocus()
        editBox:HighlightText()
        print("|cff00ff00Time Tracker:|r " .. private.GetLocalizedText("EXPORT_SUCCESS"))
    end)

    local importBtn = CreateFrame("Button", nil, frame.backupPanel, "UIPanelButtonTemplate")
    importBtn:SetSize(150, 30)
    importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 10, 0)
    importBtn:SetText(private.GetLocalizedText("IMPORT_BUTTON"))
    importBtn:SetScript("OnClick", function()
        StaticPopup_Show("TIMETRACKER_CONFIRM_IMPORT")
    end)

    -- Confirmation Popup
    StaticPopupDialogs["TIMETRACKER_CONFIRM_IMPORT"] = {
        text = private.GetLocalizedText("CONFIRM_IMPORT"),
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            local code = editBox:GetText()
            local success, count = private.DeserializeDatabase(code)
            if success then
                print("|cff00ff00Time Tracker:|r " .. string.format(private.GetLocalizedText("IMPORT_SUCCESS"), count or 0))
                ReloadUI()
            else
                print("|cffff0000Time Tracker:|r " .. private.GetLocalizedText("IMPORT_ERROR"))
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }


    -- Update Tabs
    local function HideAllPanels()
        frame.personalPanel:Hide()
        frame.charactersPanel:Hide()
        frame.classesPanel:Hide()
        frame.racesPanel:Hide()
        frame.activitiesPanel:Hide()
        frame.summaryPanel:Hide()
        frame.statsPanel:Hide()
        frame.backupPanel:Hide()

        
        -- Also hide temporary buttons from other tabs if any
        if frame.summaryBackButton then frame.summaryBackButton:Hide() end
    end
    
    local function DeselectAllTabs()
        frame.tabPersonal.selected = false
        frame.tabCharacters.selected = false
        frame.tabClasses.selected = false
        frame.tabRaces.selected = false
        frame.tabActivities.selected = false
        frame.tabSummary.selected = false
        frame.tabStatistics.selected = false
        frame.tabBackup.selected = false
    end


    frame.tabPersonal:SetScript("OnClick", function()
        DeselectAllTabs(); frame.tabPersonal.selected = true; UpdateTabAppearance(frame); HideAllPanels(); frame.personalPanel:Show(); private.UpdateCurrentCharacterStats(frame)
    end)
    frame.tabCharacters:SetScript("OnClick", function()
        DeselectAllTabs(); frame.tabCharacters.selected = true; UpdateTabAppearance(frame); HideAllPanels(); frame.charactersPanel:Show(); private.UpdateCharactersStats(frame)
    end)
    frame.tabClasses:SetScript("OnClick", function()
        DeselectAllTabs(); frame.tabClasses.selected = true; UpdateTabAppearance(frame); HideAllPanels(); frame.classesPanel:Show(); private.UpdateClassesStats(frame)
    end)
    frame.tabRaces:SetScript("OnClick", function()
        DeselectAllTabs(); frame.tabRaces.selected = true; UpdateTabAppearance(frame); HideAllPanels(); frame.racesPanel:Show(); private.UpdateRacesStats(frame)
    end)
    frame.tabActivities:SetScript("OnClick", function()
        DeselectAllTabs(); frame.tabActivities.selected = true; UpdateTabAppearance(frame); HideAllPanels(); frame.activitiesPanel:Show(); private.UpdateActivitiesStats(frame)
    end)
    frame.tabSummary:SetScript("OnClick", function()
        DeselectAllTabs(); frame.tabSummary.selected = true; UpdateTabAppearance(frame); HideAllPanels(); frame.summaryPanel:Show(); private.UpdateSummaryStats(frame)
    end)
    frame.tabStatistics:SetScript("OnClick", function()
        DeselectAllTabs(); frame.tabStatistics.selected = true; UpdateTabAppearance(frame); HideAllPanels(); frame.statsPanel:Show(); private.UpdateStatisticsStats(frame)
    end)
    frame.tabBackup:SetScript("OnClick", function()
        DeselectAllTabs(); frame.tabBackup.selected = true; UpdateTabAppearance(frame); HideAllPanels(); frame.backupPanel:Show(); private.UpdateBackupPanel(frame)
    end)


    UpdateTabAppearance(frame)
    TimeTrackerFrame = frame
    return frame
end


-- Minimap Button
function private.CreateMinimapButton()
    local button = CreateFrame("Button", "TimeTrackerMinimapButton", Minimap)
    button:SetFrameStrata("MEDIUM")
    button:SetSize(32, 32)
    local angle = (TimeTrackerDB.settings.minimapPos and TimeTrackerDB.settings.minimapPos.angle) or 45
    local radius = 105
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
    
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
    icon:SetSize(21, 21)
    icon:SetPoint("CENTER")
    button.icon = icon

    local mask = button:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    mask:SetSize(21, 21)
    mask:SetPoint("CENTER")
    icon:AddMaskTexture(mask)
    
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", 0, -1)
    button.border = border
    
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetScript("OnClick", function(self, buttonPressed)
        if buttonPressed == "RightButton" then
            SlashCmdList.TIMETRACKER("stats")
        else
            SlashCmdList.TIMETRACKER("show")
        end
    end)
    
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Time Tracker")
        GameTooltip:AddLine(private.GetLocalizedText("MINIMAP_TOOLTIP"), 1, 1, 1)
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    button:SetMovable(true)
    button:RegisterForDrag("LeftButton")
    
    button:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        self:SetScript("OnUpdate", function(self)
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            cx, cy = cx / scale, cy / scale
            local dx, dy = cx - mx, cy - my
            local angle = math.atan2(dy, dx)
            
            local radius = 105
            local newX = math.cos(angle) * radius
            local newY = math.sin(angle) * radius
            
            self:ClearAllPoints()
            self:SetPoint("CENTER", Minimap, "CENTER", newX, newY)
            
            if not TimeTrackerDB.settings.minimapPos then TimeTrackerDB.settings.minimapPos = {} end
            TimeTrackerDB.settings.minimapPos.angle = angle
        end)
    end)
    
    button:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self:SetScript("OnUpdate", nil)
    end)
    
    return button
end
