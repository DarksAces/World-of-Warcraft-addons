local addonName, private = ...

-- Activity Categories
local activityCategories = {
    { "afk", "CATEGORY_AFK" },
    { "dungeons", "CATEGORY_DUNGEONS" },
    { "raids", "CATEGORY_RAIDS" },
    { "bgs", "CATEGORY_BGS" },
    { "arenas", "CATEGORY_ARENAS" },
    { "queues", "CATEGORY_QUEUES" },
    { "dead", "CATEGORY_DEAD" },
    { "petbattles", "CATEGORY_PETBATTLES" },
    { "taxi", "CATEGORY_TAXI" },
    { "scenarios", "CATEGORY_SCENARIOS" },
    { "auction", "CATEGORY_AUCTION" },
    { "professions", "CATEGORY_PROFESSIONS" },
    { "city", "CATEGORY_CITY" },
    { "world", "CATEGORY_WORLD" }
}

function private.InitializeActivitiesDropdown(frame)
    local dropdown = frame.activityTypeDropdown
    if not dropdown then return end

    local function OnClick(self, arg1, arg2)
        dropdown.selectedActivity = arg1
        UIDropDownMenu_SetText(dropdown, arg2)
        private.UpdateActivitiesStats(frame)
    end

    UIDropDownMenu_Initialize(dropdown, function()
        local info = UIDropDownMenu_CreateInfo()
        info.func = OnClick
        info.padding = 10

        for _, cat in ipairs(activityCategories) do
            info.text = "|cffffffff" .. private.GetLocalizedText(cat[2]) .. "|r"
            info.arg1 = cat[1]
            info.arg2 = private.GetLocalizedText(cat[2])
            info.checked = (dropdown.selectedActivity == cat[1] or (not dropdown.selectedActivity and cat[1] == "afk"))
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    dropdown.selectedActivity = "afk"
    UIDropDownMenu_SetText(dropdown, private.GetLocalizedText("CATEGORY_AFK"))
end

-- NEW: Update Activities Stats (AFK, Dungeons, Raids)
function private.UpdateActivitiesStats(frame)
    local panel = frame.activitiesPanel
    local content = panel.content
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
    if panel.activityFrames then for _, f in pairs(panel.activityFrames) do f:Hide() end end
    panel.activityFrames = panel.activityFrames or {}
    
    panel.actMiscFS = panel.actMiscFS or {}
    for _, fs in ipairs(panel.actMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscActFS()
        miscFSIndex = miscFSIndex + 1
        return private.CreateOrReuseFontString(panel.actMiscFS, content, miscFSIndex, "GameFontHighlight")
    end
    
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
        local entry = panel.activityFrames[i]
        if not entry then
            entry = private.CreateEntryFrame(content)
            panel.activityFrames[i] = entry
        end
        entry:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)
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
    
    content:SetHeight(math.max(450, math.abs(yOffset) + 50))
end
