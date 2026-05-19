local addonName, private = ...

-- NEW: Update Summary Stats (Yearly/Monthly/Daily drill-down)
function private.UpdateSummaryStats(frame)
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    local panel = frame.summaryPanel
    local content = panel.content
    
    if not panel.summaryState then
        panel.summaryState = { view = "years", year = nil, month = nil }
    end
    local state = panel.summaryState
    
    if panel.summaryFrames then for _, f in pairs(panel.summaryFrames) do f:Hide() end end
    panel.summaryFrames = panel.summaryFrames or {}
    
    panel.summaryMiscFS = panel.summaryMiscFS or {}
    for _, fs in ipairs(panel.summaryMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscSummaryFS()
        miscFSIndex = miscFSIndex + 1
        return private.CreateOrReuseFontString(panel.summaryMiscFS, content, miscFSIndex, "GameFontHighlight")
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
        if not panel.summaryBackButton then
            panel.summaryBackButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            panel.summaryBackButton:SetSize(80, 22)
            panel.summaryBackButton:SetText(private.GetLocalizedText("BACK"))
            panel.summaryBackButton:SetScript("OnClick", function()
                if state.view == "day_detail" then
                    state.view = "days"
                    state.day = nil
                elseif state.view == "days" then
                    state.view = "months"
                    state.month = nil
                elseif state.view == "months" then
                    state.view = "years"
                    state.year = nil
                end
                private.UpdateSummaryStats(frame)
            end)
        end
        panel.summaryBackButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -25, -5)
        panel.summaryBackButton:Show()
    else
        if panel.summaryBackButton then panel.summaryBackButton:Hide() end
    end
    
    yOffset = yOffset - 30

    local dataMap = {}
    local totalTimeInView = 0
    
    local function AddToMap(key, amount, activityMap)
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
        local entry = panel.summaryFrames[i]
        if not entry then
            entry = private.CreateEntryFrame(content)
            panel.summaryFrames[i] = entry
            entry:RegisterForClicks("LeftButtonUp")
            entry:SetScript("OnClick", function(self)
                local clickedKey = self.dataKey
                if not clickedKey then return end
                if state.view == "years" then
                    state.view = "months"
                    state.year = clickedKey
                    private.UpdateSummaryStats(frame)
                elseif state.view == "months" then
                    state.view = "days"
                    state.month = clickedKey
                    private.UpdateSummaryStats(frame)
                elseif state.view == "days" then
                    state.view = "day_detail"
                    state.day = clickedKey
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
                displayName = data.key .. " (" .. (date("%A", tDate) or "") .. ")"
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
             local actKey = data.key
             local actName = private.GetLocalizedText("CATEGORY_" .. string.upper(actKey)) or actKey
             entry.name:SetText(actName)
             sub = private.GetLocalizedText("TIME_COLON") .. " " .. private.FormatTime(data.time, format)
             entry:ToggleIcon(false)
             local r, g, b = 1, 1, 1
             if actKey == "afk" then r,g,b = 0.5, 0.5, 0.5
             elseif actKey == "dungeons" then r,g,b = 1, 0.5, 0
             elseif actKey == "raids" then r,g,b = 1, 0, 0
             elseif actKey == "bgs" or actKey == "pvp" then r,g,b = 0, 0.5, 1
             elseif actKey == "arenas" then r,g,b = 0.6, 0, 1
             elseif actKey == "dead" then r,g,b = 0.3, 0.3, 0.3
             elseif actKey == "petbattles" then r,g,b = 0.2, 0.8, 0.2
             elseif actKey == "taxi" then r,g,b = 0.8, 0.8, 1
             elseif actKey == "scenarios" then r,g,b = 0, 0.8, 0.8
             elseif actKey == "auction" then r,g,b = 1, 0.8, 0
             elseif actKey == "professions" then r,g,b = 0.6, 0.4, 0.2
             elseif actKey == "city" then r,g,b = 0.4, 0.4, 1
             elseif actKey == "world" then r,g,b = 0.2, 1, 0.2
             elseif actKey == "queues" then r,g,b = 1, 1, 0
             end
             entry.bar:SetStatusBarColor(r, g, b)
             displayName = actName
        elseif state.view == "days" then
            sub = private.GetLocalizedText("CLICK_DETAILS") or "Click for details"
        elseif state.view == "years" then 
            sub = private.GetLocalizedText("TOTAL_YEAR")
        elseif state.view == "months" then 
            sub = private.GetLocalizedText("TOTAL_MONTH") 
        end
        
        if state.view == "day_detail" then
             entry.name:SetText(displayName)
        elseif state.view == "days" then
             local y, m, d = string.match(data.key, "(%d+)-(%d+)-(%d+)")
             if y then
                local tDate = time({year=y, month=m, day=d})
                displayName = data.key .. " (" .. (date("%A", tDate) or "") .. ")"
             end
             entry.name:SetText(displayName)
        end
        
        entry.subText:SetText(sub)
        yOffset = yOffset - 55
    end
    content:SetHeight(math.max(450, math.abs(yOffset) + 50))
end
