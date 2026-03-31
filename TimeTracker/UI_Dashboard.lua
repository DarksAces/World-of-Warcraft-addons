local addonName, private = ...

-- Dashboard Panel Logic
function private.UpdateDashboard(frame)
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    local panel = frame.dashboardPanel
    local content = panel.content
    local yOffset = -20

    -- Clear/Reuse logic
    panel.dashMiscFS = panel.dashMiscFS or {}
    for _, fs in ipairs(panel.dashMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscDashFS()
        miscFSIndex = miscFSIndex + 1
        return private.CreateOrReuseFontString(panel.dashMiscFS, content, miscFSIndex, "GameFontHighlight")
    end

    -- Header
    local h = GetMiscDashFS(); h:SetFontObject("GameFontNormalLarge"); h:SetPoint("TOPLEFT", 10, yOffset); h:SetText(private.GetLocalizedText("DASHBOARD_TAB")); h:SetTextColor(0, 0.8, 1); yOffset = yOffset - 40

    -- Quick Stats
    local totalAll = 0
    local charCount = 0
    local accountDaily = {}
    local currentDate = private.GetCurrentDate()
    
    for _, char in pairs(TimeTrackerDB.characters) do
        charCount = charCount + 1
        totalAll = totalAll + (char.totalTime or 0)
        if char.daily then
            for d, t in pairs(char.daily) do accountDaily[d] = (accountDaily[d] or 0) + t end
        end
    end

    local function AddStatBox(label, val, r, g, b)
        local l = GetMiscDashFS(); l:SetPoint("TOPLEFT", 20, yOffset); l:SetText(label .. ":"); l:SetTextColor(0.6, 0.6, 0.6)
        local v = GetMiscDashFS(); v:SetPoint("TOPLEFT", 180, yOffset); v:SetText(val); v:SetTextColor(r, g, b)
        yOffset = yOffset - 20
    end

    AddStatBox(private.GetLocalizedText("TOTAL_ALL_CHARS"), private.FormatTime(totalAll, format), 1, 0.8, 0)
    AddStatBox(private.GetLocalizedText("NUMBER_OF_CHARS"), charCount, 1, 1, 1)
    
    local todayTime = accountDaily[currentDate] or 0
    AddStatBox(private.GetLocalizedText("TODAY_LABEL"), private.FormatTime(todayTime, format), 0, 1, 0)
    
    yOffset = yOffset - 30

    -- Heatmap Section
    local hHeat = GetMiscDashFS(); hHeat:SetFontObject("GameFontNormal"); hHeat:SetPoint("TOPLEFT", 10, yOffset); hHeat:SetText(private.GetLocalizedText("ACTIVITY_HEATMAP")); hHeat:SetTextColor(1, 0.8, 0); yOffset = yOffset - 30

    if not panel.heatmapBoxes then
        panel.heatmapBoxes = {}
        local boxSize = 18
        local spacing = 4
        local startX = 20
        
        for i = 1, 30 do
            local box = CreateFrame("Frame", nil, content, "BackdropTemplate")
            box:SetSize(boxSize, boxSize)
            box:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Buttons\\WHITE8X8",
                tile = true, tileSize = 1, edgeSize = 1,
            })
            box:SetBackdropBorderColor(1, 1, 1, 0.1)
            
            -- Tooltip
            box:SetScript("OnEnter", function(self)
                if self.dateStr then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(self.dateStr)
                    GameTooltip:AddLine(private.FormatTime(self.val or 0, format), 1, 1, 1)
                    GameTooltip:Show()
                end
            end)
            box:SetScript("OnLeave", GameTooltip_Hide)
            
            table.insert(panel.heatmapBoxes, box)
        end
    end

    -- Update Heatmap Data
    local now = time()
    local boxSize = 18
    local spacing = 4
    local startX = 20
    
    for i = 1, 30 do
        local box = panel.heatmapBoxes[i]
        local tDate = now - (30 - i) * 86400
        local dateStr = date("%Y-%m-%d", tDate)
        local val = accountDaily[dateStr] or 0
        
        box.dateStr = dateStr
        box.val = val
        box:SetPoint("TOPLEFT", content, "TOPLEFT", startX + (i-1)*(boxSize+spacing), yOffset)
        
        -- Color calculation (0 to 8+ hours)
        local hours = val / 3600
        local r, g, b = 0.1, 0.1, 0.1 -- Default empty
        if hours > 0 then
            -- Scale from dark green to bright green/yellow
            g = math.min(0.2 + (hours / 8) * 0.8, 1)
            r = math.min((hours / 12), 0.5) -- Slight yellowing for high hours
            b = 0.1
        end
        box:SetBackdropColor(r, g, b, 0.8)
        box:Show()
    end
    
    yOffset = yOffset - 50
    local label30 = GetMiscDashFS(); label30:SetPoint("TOPLEFT", 10, yOffset); label30:SetText(private.GetLocalizedText("LAST_30_DAYS")); label30:SetTextColor(0.5, 0.5, 0.5); yOffset = yOffset - 20

    content:SetHeight(math.max(450, math.abs(yOffset) + 50))
end
