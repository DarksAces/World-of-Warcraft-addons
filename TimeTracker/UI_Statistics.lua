local addonName, private = ...

-- NEW: Update Statistics Stats (Records and Insights)
function private.UpdateStatisticsStats(frame)
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    local panel = frame.statisticsPanel
    local content = panel.content
    
    -- Clear previous frames
    if panel.statsFrames then for _, f in pairs(panel.statsFrames) do f:Hide() end end
    panel.statsFrames = panel.statsFrames or {}
    
    panel.statsMiscFS = panel.statsMiscFS or {}
    for _, fs in ipairs(panel.statsMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscStatsFS()
        miscFSIndex = miscFSIndex + 1
        return private.CreateOrReuseFontString(panel.statsMiscFS, content, miscFSIndex, "GameFontHighlight")
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
    
    -- Calculate Projection
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
            local wYear, wNum = string.match(dataKey, "(%d+)-W(%d+)")
            if wYear and wNum then
                local y, w = tonumber(wYear), tonumber(wNum)
                local jan4 = time({year=y, month=1, day=4})
                local d = date("*t", jan4)
                local wday = d.wday 
                local iso_wday = (wday - 2) % 7 + 1 
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
    AddHeader("--- Insights ---", 0.5, 0.8, 1) 

    AddRecordRow(private.GetLocalizedText("AVG_DAILY"), private.FormatTime(dailyAvg, format), nil, {1, 1, 1})
    AddRecordRow(private.GetLocalizedText("MOST_PLAYED_DAY"), favDayName, nil, {1, 1, 0})
    AddRecordRow(private.GetLocalizedText("PROJECTED_YEAR"), private.FormatTime(projected, format), date("%Y"), {0.8, 0.5, 1})

    local neededHeight = math.abs(yOffset) + 50
    content:SetHeight(math.max(450, neededHeight))
end
