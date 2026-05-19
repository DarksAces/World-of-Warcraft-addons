local addonName, private = ...

local GetLocalizedText = private.GetLocalizedText

-- Slash Commands
SLASH_TIMETRACKER1 = "/timetrack"
SLASH_TIMETRACKER2 = "/timetracker"

function SlashCmdList.TIMETRACKER(msg)
    local command = string.lower(msg or "")
    if command == "show" or command == "" then
        if private.TimeTrackerFrame then
            if private.TimeTrackerFrame:IsShown() then
                private.TimeTrackerFrame:Hide()
            else
                private.TimeTrackerFrame:Show()
                -- Refresh active tab
                local f = private.TimeTrackerFrame
                if f.tabDashboard and f.tabDashboard.selected then
                    private.UpdateDashboard(f)
                elseif f.tabPersonal and f.tabPersonal.selected then
                    private.UpdateCurrentCharacterStats(f)
                elseif f.tabCharacters and f.tabCharacters.selected then
                    private.UpdateCharactersStats(f)
                elseif f.tabClasses and f.tabClasses.selected then
                    private.UpdateClassesStats(f)
                elseif f.tabRaces and f.tabRaces.selected then
                    private.UpdateRacesStats(f)
                elseif f.tabActivities and f.tabActivities.selected then
                    private.UpdateActivitiesStats(f)
                elseif f.tabSummary and f.tabSummary.selected then
                    private.UpdateSummaryStats(f)
                elseif f.tabStatistics and f.tabStatistics.selected then
                    private.UpdateStatisticsStats(f)
                elseif f.tabBackup and f.tabBackup.selected then
                    private.UpdateBackupPanel(f)
                end
                
                -- Update Buttons text if needed
                local fmt = TimeTrackerDB.settings.timeFormat or "complete"
                local textMap = {
                    hours = GetLocalizedText("ONLY_HOURS"), 
                    minutes = GetLocalizedText("ONLY_MINUTES"), 
                    seconds = GetLocalizedText("ONLY_SECONDS"), 
                    complete = GetLocalizedText("COMPLETE_FORMAT")
                }
                local text = textMap[fmt]
                if f.personalFormatDropdown then UIDropDownMenu_SetText(f.personalFormatDropdown, text) end
                if f.charFormatDropdown then UIDropDownMenu_SetText(f.charFormatDropdown, text) end
                if f.classFormatDropdown then UIDropDownMenu_SetText(f.classFormatDropdown, text) end
                if f.raceFormatDropdown then UIDropDownMenu_SetText(f.raceFormatDropdown, text) end
            end
        end
    elseif command == "time" then
        private.SafeRequestTime()
        print("Time Tracker: " .. GetLocalizedText("GETTING_TIME"))
    elseif command == "stats" then
        local char = TimeTrackerDB.characters[private.playerKey]
        if char then
            local fmt = TimeTrackerDB.settings.timeFormat
            print("Time Tracker - " .. GetLocalizedText("QUICK_STATS_TITLE"))
            print(GetLocalizedText("TOTAL") .. ": " .. private.FormatTime(char.totalTime, fmt))
            print(GetLocalizedText("TODAY") .. ": " .. private.FormatTime(char.daily[private.GetCurrentDate()] or 0, fmt))
            print(GetLocalizedText("THIS_WEEK") .. ": " .. private.FormatTime(char.weekly[private.GetCurrentWeek()] or 0, fmt))
        else
            print("Time Tracker: " .. GetLocalizedText("NO_DATA"))
        end
    elseif command == "format" then
        print("Time Tracker - " .. GetLocalizedText("FORMATS_AVAILABLE"))
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

-- Native Options Panel Setup
function private.CreateOptionsPanel()
    local optionsFrame = CreateFrame("Frame", "TimeTrackerOptionsPanel")
    optionsFrame.name = GetLocalizedText("ADDON_NAME")
    
    local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(GetLocalizedText("ADDON_NAME") .. " - Opciones")
    
    local showOnLoginBtn = CreateFrame("CheckButton", nil, optionsFrame, "ChatConfigCheckButtonTemplate")
    showOnLoginBtn:SetPoint("TOPLEFT", 16, -50)
    local cbText = showOnLoginBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cbText:SetPoint("LEFT", showOnLoginBtn, "RIGHT", 5, 0)
    cbText:SetText("Mostrar mensaje de bienvenida al conectar")
    showOnLoginBtn:SetChecked(TimeTrackerDB.settings.showOnLogin)
    showOnLoginBtn:SetScript("OnClick", function(self) TimeTrackerDB.settings.showOnLogin = self:GetChecked() end)
    
    local hideMinimapBtn = CreateFrame("CheckButton", nil, optionsFrame, "ChatConfigCheckButtonTemplate")
    hideMinimapBtn:SetPoint("TOPLEFT", 16, -90)
    local cbText2 = hideMinimapBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cbText2:SetPoint("LEFT", hideMinimapBtn, "RIGHT", 5, 0)
    cbText2:SetText("Ocultar botón del minimapa")
    if TimeTrackerDB.settings.hideMinimap == nil then TimeTrackerDB.settings.hideMinimap = false end
    hideMinimapBtn:SetChecked(TimeTrackerDB.settings.hideMinimap)
    hideMinimapBtn:SetScript("OnClick", function(self)
        TimeTrackerDB.settings.hideMinimap = self:GetChecked()
        if TimeTrackerMinimapButton then
            if TimeTrackerDB.settings.hideMinimap then TimeTrackerMinimapButton:Hide() else TimeTrackerMinimapButton:Show() end
        end
    end)
    
    local breakBtn = CreateFrame("CheckButton", nil, optionsFrame, "ChatConfigCheckButtonTemplate")
    breakBtn:SetPoint("TOPLEFT", 16, -130)
    local cbText3 = breakBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cbText3:SetPoint("LEFT", breakBtn, "RIGHT", 5, 0)
    cbText3:SetText("Activar recordatorio de descanso (cada 2 horas)")
    if TimeTrackerDB.settings.breakReminder == nil then TimeTrackerDB.settings.breakReminder = true end
    breakBtn:SetChecked(TimeTrackerDB.settings.breakReminder)
    breakBtn:SetScript("OnClick", function(self) TimeTrackerDB.settings.breakReminder = self:GetChecked() end)
    
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(optionsFrame, optionsFrame.name)
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(optionsFrame)
    end
end

-- Data Broker Initialization
function private.InitDataBroker()
    local ldb = LibStub and LibStub("LibDataBroker-1.1", true)
    if ldb then
        private.ldbObject = ldb:NewDataObject("TimeTracker", {
            type = "data source",
            text = "Time Tracker",
            icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
            OnClick = function(self, button)
                if button == "RightButton" then SlashCmdList.TIMETRACKER("stats") else SlashCmdList.TIMETRACKER("show") end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:SetText(GetLocalizedText("ADDON_NAME"))
                tooltip:AddLine(GetLocalizedText("MINIMAP_TOOLTIP"), 1, 1, 1)
            end,
        })
    end
end
