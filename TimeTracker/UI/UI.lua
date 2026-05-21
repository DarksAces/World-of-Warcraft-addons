local addonName, private = ...

-- Global Frame Reference
local TimeTrackerFrame = nil

-- UI Helpers (Shared across modules)
function private.CreateOrReuseFontString(framePool, parent, index, fontTemplate)
    local fs = framePool[index]
    if not fs then
        fs = parent:CreateFontString(nil, "OVERLAY", fontTemplate or "GameFontNormal")
        framePool[index] = fs
    end
    fs:Show()
    return fs
end

local dropdownIndex = 0
local function CreateTimeFormatDropdown(parent, xOffset, yOffset)
    dropdownIndex = dropdownIndex + 1
    local name = addonName .. "Dropdown" .. dropdownIndex
    local dropdown = CreateFrame("Button", name, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    UIDropDownMenu_SetWidth(dropdown, 150)
    
    local text = _G[name.."Text"]
    if text then text:SetFontObject("GameFontNormal") end

    UIDropDownMenu_SetText(dropdown, private.GetLocalizedText("COMPLETE_FORMAT"))
    
    local function OnClick(self, arg1, arg2)
        TimeTrackerDB.settings.timeFormat = arg1
        UIDropDownMenu_SetText(dropdown, arg2)
        if TimeTrackerFrame and TimeTrackerFrame:IsShown() then
            if TimeTrackerFrame.tabPersonal.selected then private.UpdateCurrentCharacterStats(TimeTrackerFrame)
            elseif TimeTrackerFrame.tabCharacters.selected then private.UpdateCharactersStats(TimeTrackerFrame)
            elseif TimeTrackerFrame.tabClasses.selected then private.UpdateClassesStats(TimeTrackerFrame)
            elseif TimeTrackerFrame.tabRaces.selected then private.UpdateRacesStats(TimeTrackerFrame)
            elseif TimeTrackerFrame.tabActivities.selected then private.UpdateActivitiesStats(TimeTrackerFrame)
            elseif TimeTrackerFrame.tabSummary.selected then private.UpdateSummaryStats(TimeTrackerFrame)
            elseif TimeTrackerFrame.tabStatistics.selected then private.UpdateStatisticsStats(TimeTrackerFrame)
            end
        end
    end
    
    UIDropDownMenu_Initialize(dropdown, function()
        local info = UIDropDownMenu_CreateInfo()
        info.func = OnClick
        info.padding = 10

        local formats = {
            { "hours", "ONLY_HOURS" },
            { "minutes", "ONLY_MINUTES" },
            { "seconds", "ONLY_SECONDS" },
            { "complete", "COMPLETE_FORMAT" }
        }

        for _, fmt in ipairs(formats) do
            info.text = "|cffffffff" .. private.GetLocalizedText(fmt[2]) .. "|r"
            info.arg1 = fmt[1]
            info.arg2 = private.GetLocalizedText(fmt[2])
            info.checked = (TimeTrackerDB.settings.timeFormat == fmt[1])
            UIDropDownMenu_AddButton(info)
        end
    end)
    return dropdown
end

function private.CreateEntryFrame(parent)
    local frame = CreateFrame("Button", nil, parent, "BackdropTemplate")
    frame:SetSize(430, 52)
    
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
    
    frame.iconContainer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.iconContainer:SetSize(38, 38)
    frame.iconContainer:SetPoint("LEFT", 6, 0)
    frame.iconContainer:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    frame.iconContainer:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.5)

    frame.icon = frame.iconContainer:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.name:SetPoint("TOPLEFT", 50, -8)
    frame.name:SetJustifyH("LEFT")
    
    frame.rightText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.rightText:SetPoint("TOPRIGHT", -12, -8)
    
    frame.bar = CreateFrame("StatusBar", nil, frame)
    frame.bar:SetSize(370, 10)
    frame.bar:SetPoint("TOPLEFT", frame.name, "BOTTOMLEFT", 0, -4)
    frame.bar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    
    local barBg = frame.bar:CreateTexture(nil, "BACKGROUND")
    barBg:SetAllPoints(); barBg:SetColorTexture(0, 0, 0, 0.6)
    
    frame.barText = frame.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.barText:SetPoint("CENTER", 0, 1); frame.barText:SetScale(0.9)
    
    frame.subText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.subText:SetPoint("TOPLEFT", frame.bar, "BOTTOMLEFT", 0, -3)
    frame.subText:SetTextColor(0.5, 0.5, 0.5)

    frame.ToggleIcon = function(self, show)
        if show then
            self.iconContainer:Show(); self.name:SetPoint("TOPLEFT", 50, -8); self.bar:SetWidth(370)
        else
            self.iconContainer:Hide(); self.name:SetPoint("TOPLEFT", 10, -8); self.bar:SetWidth(410)
        end
    end
    
    return frame
end

local function CreateTabButton(parent, text, width)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, 32)
    btn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
    })
    btn:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
    btn:SetBackdropBorderColor(1, 1, 1, 0.1)
    
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.text:SetPoint("CENTER", 0, 1); btn.text:SetText(text); btn.text:SetScale(0.95)
    
    btn:SetScript("OnEnter", function(self) if not self.selected then self:SetBackdropColor(0.15, 0.15, 0.2, 1); self:SetBackdropBorderColor(1, 1, 1, 0.3) end end)
    btn:SetScript("OnLeave", function(self) if not self.selected then self:SetBackdropColor(0.08, 0.08, 0.1, 0.95); self:SetBackdropBorderColor(1, 1, 1, 0.1) end end)
    return btn
end

-- Create Main Frame
function private.CreateMainFrame()
    local frame = CreateFrame("Frame", "TimeTrackerFrame", UIParent, "BasicFrameTemplateWithInset, BackdropTemplate")
    frame:SetSize(1095, 620); frame:SetPoint("CENTER"); frame:SetMovable(true); frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton"); frame:SetScript("OnDragStart", frame.StartMoving); frame:SetScript("OnDragStop", frame.StopMovingOrSizing); frame:Hide()
    
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
    })
    frame:SetBackdropColor(0, 0, 0, 0.95); frame:SetBackdropBorderColor(0, 0.8, 1, 0.5)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.title:SetPoint("TOP", 0, -5); frame.title:SetText("|cff00ccff" .. private.GetLocalizedText("ADDON_NAME") .. "|r")

    -- Tab Setup
    local tabs = {
        { "Dashboard", "DASHBOARD_TAB", 90 },
        { "Personal", "CURRENT_CHARACTER", 110 },
        { "Characters", "CHARACTERS_TAB", 110 },
        { "Classes", "CLASSES_TAB", 80 },
        { "Races", "RACES_TAB", 80 },
        { "Activities", "ACTIVITIES_TAB", 100 },
        { "Summary", "SUMMARY_TAB", 90 },
        { "Statistics", "STATISTICS_TAB", 110 },
        { "Backup", "BACKUP_TAB", 130 },
        { "Collaborators", "COLLABORATORS_TAB", 120 }
    }

    local lastTab = nil
    for _, tData in ipairs(tabs) do
        local id, locKey, width = unpack(tData)
        local tab = CreateTabButton(frame, private.GetLocalizedText(locKey), width)
        if not lastTab then tab:SetPoint("TOPLEFT", 15, -28) else tab:SetPoint("LEFT", lastTab, "RIGHT", 5, 0) end
        frame["tab" .. id] = tab
        lastTab = tab
    end

    local function UpdateTabAppearance()
        for _, tData in ipairs(tabs) do
            local tab = frame["tab" .. tData[1]]
            if tab.selected then
                tab:SetBackdropColor(0, 0.5, 0.8, 1); tab:SetBackdropBorderColor(0, 1, 1, 1)
                tab.text:SetTextColor(1, 1, 1)
            else
                tab:SetBackdropColor(0.08, 0.08, 0.1, 0.95); tab:SetBackdropBorderColor(1, 1, 1, 0.1)
                tab.text:SetTextColor(0.8, 0.8, 0.8)
            end
        end
    end

    -- Panels Creation
    local function CreatePanel(name, hideScroll)
        local p = CreateFrame("Frame", nil, frame)
        p:SetPoint("TOPLEFT", 15, -55); p:SetPoint("BOTTOMRIGHT", -15, 15); p:Hide()
        if not hideScroll then
            local sf = CreateFrame("ScrollFrame", nil, p, "UIPanelScrollFrameTemplate")
            sf:SetPoint("TOPLEFT", 5, -50); sf:SetPoint("BOTTOMRIGHT", -25, 10)
            local c = CreateFrame("Frame", nil, sf)
            c:SetSize(600, 450); sf:SetScrollChild(c)
            p.content = c; p.scrollFrame = sf
        end
        return p
    end

    frame.dashboardPanel = CreatePanel("Dashboard")
    frame.personalPanel = CreatePanel("Personal")
    frame.charactersPanel = CreatePanel("Characters")
    frame.classesPanel = CreatePanel("Classes")
    frame.racesPanel = CreatePanel("Races")
    frame.activitiesPanel = CreatePanel("Activities")
    frame.summaryPanel = CreatePanel("Summary")
    frame.statisticsPanel = CreatePanel("Statistics")
    frame.backupPanel = CreatePanel("Backup", true)
    frame.collaboratorsPanel = CreatePanel("Collaborators")

    -- Shared Dropdowns
    frame.personalFormatDropdown = CreateTimeFormatDropdown(frame.personalPanel, 5, -30)
    frame.charFormatDropdown = CreateTimeFormatDropdown(frame.charactersPanel, 5, -30)
    frame.classFormatDropdown = CreateTimeFormatDropdown(frame.classesPanel, 5, -30)
    frame.raceFormatDropdown = CreateTimeFormatDropdown(frame.racesPanel, 5, -30)
    
    for _, p in ipairs({frame.personalPanel, frame.charactersPanel, frame.classesPanel, frame.racesPanel}) do
        local label = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 10, -10); label:SetText(private.GetLocalizedText("TIME_FORMAT"))
    end

-- Activity Dropdown specialized
    local actP = frame.activitiesPanel
    frame.activityTypeDropdown = CreateFrame("Button", addonName .. "ActDrop", actP, "UIDropDownMenuTemplate")
    frame.activityTypeDropdown:SetPoint("TOPLEFT", actP, "TOPLEFT", 5, -30)
    UIDropDownMenu_SetWidth(frame.activityTypeDropdown, 150)
    
    local actLabel = actP:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    actLabel:SetPoint("TOPLEFT", 10, -10)
    actLabel:SetText(private.GetLocalizedText("CATEGORY"))
    
    if private.InitializeActivitiesDropdown then
        private.InitializeActivitiesDropdown(frame)
    end

    -- Tab Click Logic
    local function ShowTab(id, updateFunc)
        for _, t in ipairs(tabs) do frame["tab" .. t[1]].selected = false end
        frame["tab" .. id].selected = true
        UpdateTabAppearance()
        frame.dashboardPanel:Hide(); frame.personalPanel:Hide(); frame.charactersPanel:Hide(); frame.classesPanel:Hide(); frame.racesPanel:Hide()
        frame.activitiesPanel:Hide(); frame.summaryPanel:Hide(); frame.statisticsPanel:Hide(); frame.backupPanel:Hide(); frame.collaboratorsPanel:Hide()
        frame[id:lower() .. "Panel"]:Show()
        if updateFunc then updateFunc(frame) end
    end

    frame.tabDashboard:SetScript("OnClick", function() ShowTab("Dashboard", private.UpdateDashboard) end)
    frame.tabPersonal:SetScript("OnClick", function() ShowTab("Personal", private.UpdateCurrentCharacterStats) end)
    frame.tabCharacters:SetScript("OnClick", function() ShowTab("Characters", private.UpdateCharactersStats) end)
    frame.tabClasses:SetScript("OnClick", function() ShowTab("Classes", private.UpdateClassesStats) end)
    frame.tabRaces:SetScript("OnClick", function() ShowTab("Races", private.UpdateRacesStats) end)
    frame.tabActivities:SetScript("OnClick", function() ShowTab("Activities", private.UpdateActivitiesStats) end)
    frame.tabSummary:SetScript("OnClick", function() ShowTab("Summary", private.UpdateSummaryStats) end)
    frame.tabStatistics:SetScript("OnClick", function() ShowTab("Statistics", private.UpdateStatisticsStats) end)
    frame.tabBackup:SetScript("OnClick", function() ShowTab("Backup", private.UpdateBackupPanel) end)
    frame.tabCollaborators:SetScript("OnClick", function() ShowTab("Collaborators", private.UpdateCollaboratorsPanel) end)

    frame.tabDashboard.selected = true
    UpdateTabAppearance()
    TimeTrackerFrame = frame
    return frame
end

-- Minimap Button
function private.CreateMinimapButton()
    local button = CreateFrame("Button", "TimeTrackerMinimapButton", Minimap)
    button:SetFrameStrata("MEDIUM"); button:SetSize(32, 32)
    local angle = (TimeTrackerDB.settings.minimapPos and TimeTrackerDB.settings.minimapPos.angle) or 45
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle)*105, math.sin(angle)*105)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local icon = button:CreateTexture(nil, "BACKGROUND"); icon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01"); icon:SetSize(21, 21); icon:SetPoint("CENTER")
    local border = button:CreateTexture(nil, "OVERLAY"); border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); border:SetSize(54, 54); border:SetPoint("TOPLEFT", 0, -1)
    
    if TimeTrackerDB and TimeTrackerDB.settings.hideMinimap then button:Hide() end
    
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetScript("OnClick", function(_, b) if b == "RightButton" then SlashCmdList.TIMETRACKER("stats") else SlashCmdList.TIMETRACKER("show") end end)
    button:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_LEFT"); GameTooltip:SetText("Time Tracker"); GameTooltip:AddLine(private.GetLocalizedText("MINIMAP_TOOLTIP"), 1, 1, 1); GameTooltip:Show() end)
    button:SetScript("OnLeave", GameTooltip_Hide)
    button:SetMovable(true); button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(self) self:LockHighlight(); self:SetScript("OnUpdate", function(self)
        local mx, my = Minimap:GetCenter(); local cx, cy = GetCursorPosition(); local scale = Minimap:GetEffectiveScale()
        local angle = math.atan2(cy/scale - my, cx/scale - mx)
        self:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle)*105, math.sin(angle)*105)
        if not TimeTrackerDB.settings.minimapPos then TimeTrackerDB.settings.minimapPos = {} end
        TimeTrackerDB.settings.minimapPos.angle = angle
    end) end)
    button:SetScript("OnDragStop", function(self) self:UnlockHighlight(); self:SetScript("OnUpdate", nil) end)
    return button
end
