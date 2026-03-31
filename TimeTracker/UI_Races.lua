local addonName, private = ...

-- Update Races Stats
function private.UpdateRacesStats(frame)
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    local panel = frame.racesPanel
    local content = panel.content
    local totalAccountTime = 0
    local raceTotals = {}
    local raceYearly = {}
    local currentYear = private.GetCurrentYear and private.GetCurrentYear() or date("%Y")
    
    local currentPlayerRace, currentRaceFile = UnitRace("player")
    
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
    
    if panel.raceFrames then for _, f in pairs(panel.raceFrames) do f:Hide() end end
    panel.raceFrames = panel.raceFrames or {}
    
    panel.raceMiscFS = panel.raceMiscFS or {}
    for _, fs in ipairs(panel.raceMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscRaceFS()
        miscFSIndex = miscFSIndex + 1
        return private.CreateOrReuseFontString(panel.raceMiscFS, content, miscFSIndex, "GameFontHighlight")
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
        local entry = panel.raceFrames[i]
        if not entry then
            entry = private.CreateEntryFrame(content)
            panel.raceFrames[i] = entry
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
    content:SetHeight(math.max(450, neededHeight))
end
