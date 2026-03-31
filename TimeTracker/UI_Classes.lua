local addonName, private = ...

-- Update Classes Stats
function private.UpdateClassesStats(frame)
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    local panel = frame.classesPanel
    local content = panel.content
    local totalAccountTime = 0
    local classTotals = {}
    local classYearly = {}
    local classToEnglish = {}
    local currentYear = private.GetCurrentYear and private.GetCurrentYear() or date("%Y")
    
    local currentPlayerClass, currentClassFile = UnitClass("player")
    
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

    local maleClasses = {}
    local femaleClasses = {}
    if FillLocalizedClassList then
        FillLocalizedClassList(maleClasses, false)
        FillLocalizedClassList(femaleClasses, true)
    end
    
    local nameToClassFile = {}
    for k, v in pairs(maleClasses) do nameToClassFile[v] = k end
    for k, v in pairs(femaleClasses) do nameToClassFile[v] = k end

    for key, char in pairs(TimeTrackerDB.characters) do
        local t = char.totalTime or 0
        totalAccountTime = totalAccountTime + t
        
        -- Backfill classFile if missing and we can map it
        if not char.classFile and char.class and nameToClassFile[char.class] then
            char.classFile = nameToClassFile[char.class]
        end
        
        local className = (char.classFile and LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[char.classFile]) or char.class or private.GetLocalizedText("UNKNOWN")
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
    
    if panel.classFrames then for _, f in pairs(panel.classFrames) do f:Hide() end end
    panel.classFrames = panel.classFrames or {}
    
    panel.classMiscFS = panel.classMiscFS or {}
    for _, fs in ipairs(panel.classMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscClassFS()
        miscFSIndex = miscFSIndex + 1
        return private.CreateOrReuseFontString(panel.classMiscFS, content, miscFSIndex, "GameFontHighlight")
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
        local entry = panel.classFrames[i]
        if not entry then
            entry = private.CreateEntryFrame(content)
            panel.classFrames[i] = entry
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
    content:SetHeight(math.max(450, neededHeight))
end
