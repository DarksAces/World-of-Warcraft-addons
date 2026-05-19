local addonName, private = ...

-- Helper: Confirmation for character deletion
if not StaticPopupDialogs["TIMETRACKER_CONFIRM_DELETE"] then
    StaticPopupDialogs["TIMETRACKER_CONFIRM_DELETE"] = {
        text = private.GetLocalizedText("CONFIRM_DELETE"),
        button1 = YES,
        button2 = NO,
        OnAccept = function(self, data)
            if data and TimeTrackerDB.characters[data] then
                TimeTrackerDB.characters[data] = nil
                print("|cff00ff00Time Tracker:|r " .. "Character deleted.")
                if TimeTrackerFrame and TimeTrackerFrame:IsShown() then
                    private.UpdateCharactersStats(TimeTrackerFrame)
                end
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
end

-- Update Characters Stats
function private.UpdateCharactersStats(frame)
    local format = TimeTrackerDB.settings.timeFormat or "complete"
    local panel = frame.charactersPanel
    local content = panel.content
    local characters = {}
    local totalAccountTime = 0
    
    local currentDate = private.GetCurrentDate()
    local currentWeek = private.GetCurrentWeek()
    local currentMonth = private.GetCurrentMonth()
    local currentYear = private.GetCurrentYear and private.GetCurrentYear() or date("%Y")

    -- Search Filter Logic
    if not panel.charSearchBox then
        local search = CreateFrame("EditBox", nil, panel, "BackdropTemplate")
        search:SetSize(200, 24)
        search:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -30, -35)
        search:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile = true, tileSize = 16, edgeSize = 1,
        })
        search:SetBackdropColor(0, 0, 0, 0.5)
        search:SetBackdropBorderColor(1, 1, 1, 0.2)
        search:SetFontObject("ChatFontNormal")
        search:SetAutoFocus(false)
        search:SetTextInsets(8, 8, 0, 0)
        
        local pText = search:CreateFontString(nil, "OVERLAY", "GameFontDisable")
        pText:SetPoint("LEFT", 8, 0)
        pText:SetText(private.GetLocalizedText("SEARCH_PLACEHOLDER"))
        search.placeholder = pText
        
        search:SetScript("OnTextChanged", function(self)
            if self:GetText() ~= "" then self.placeholder:Hide() else self.placeholder:Show() end
            private.UpdateCharactersStats(frame)
        end)
        search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        panel.charSearchBox = search
    end

    local filter = panel.charSearchBox:GetText():lower()

    local totalToday, totalWeek, totalMonth, totalYear = 0, 0, 0, 0
    for key, char in pairs(TimeTrackerDB.characters) do
        local t = char.totalTime or 0
        totalAccountTime = totalAccountTime + t
        
        totalToday = totalToday + (char.daily and char.daily[currentDate] or 0)
        totalWeek = totalWeek + (char.weekly and char.weekly[currentWeek] or 0)
        totalMonth = totalMonth + (char.monthly and char.monthly[currentMonth] or 0)
        totalYear = totalYear + (char.yearly and char.yearly[currentYear] or 0)

        if filter == "" or char.name:lower():find(filter) or (char.realm and char.realm:lower():find(filter)) then
            table.insert(characters, {key = key, char = char, totalTime = t})
        end
    end
    table.sort(characters, function(a,b) return a.totalTime > b.totalTime end)

    if panel.accountFrames then for _, f in pairs(panel.accountFrames) do f:Hide() end end
    panel.accountFrames = panel.accountFrames or {}
    
    panel.charMiscFS = panel.charMiscFS or {}
    for _, fs in ipairs(panel.charMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscCharFS()
        miscFSIndex = miscFSIndex + 1
        return private.CreateOrReuseFontString(panel.charMiscFS, content, miscFSIndex, "GameFontHighlight")
    end

    local yOffset = -10
    local h = GetMiscCharFS(); h:SetFontObject("GameFontNormalLarge"); h:SetPoint("TOPLEFT", 10, yOffset); h:SetText(private.GetLocalizedText("GENERAL_SUMMARY")); h:SetTextColor(0.4, 0.8, 1); yOffset = yOffset - 30
    
    local function AddStat(label, val, r, g, b)
        local t = GetMiscCharFS(); t:SetPoint("TOPLEFT", 20, yOffset); t:SetText(label .. ": |cffffffff" .. val .. "|r"); t:SetTextColor(r,g,b); yOffset = yOffset - 18
    end
    
    AddStat(private.GetLocalizedText("TOTAL_ALL_CHARS"), private.FormatTime(totalAccountTime, format), 1, 0.8, 0)
    AddStat(private.GetLocalizedText("THIS_YEAR_LABEL"), private.FormatTime(totalYear, format), 0, 1, 0)
    AddStat(private.GetLocalizedText("THIS_MONTH_LABEL"), private.FormatTime(totalMonth, format), 0.4, 0.6, 1)
    AddStat(private.GetLocalizedText("THIS_WEEK_LABEL"), private.FormatTime(totalWeek, format), 1, 0.6, 1)
    AddStat(private.GetLocalizedText("TODAY_LABEL"), private.FormatTime(totalToday, format), 1, 1, 0.6)
    
    yOffset = yOffset - 20
    h = GetMiscCharFS(); h:SetFontObject("GameFontNormalLarge"); h:SetPoint("TOPLEFT", 10, yOffset); h:SetText(private.GetLocalizedText("CHARACTER_RANKING")); h:SetTextColor(1, 0.8, 0); yOffset = yOffset - 30

    for i, charData in ipairs(characters) do
        local entry = panel.accountFrames[i]
        if not entry then
            entry = private.CreateEntryFrame(content)
            panel.accountFrames[i] = entry
            
            -- Delete button
            local del = CreateFrame("Button", nil, entry)
            del:SetSize(20, 20)
            del:SetPoint("RIGHT", -10, 0)
            del:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
            del:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight")
            del:SetScript("OnClick", function(self)
                StaticPopup_Show("TIMETRACKER_CONFIRM_DELETE", self:GetParent().charName, nil, self:GetParent().charKey)
            end)
            entry.deleteBtn = del
        end
        entry:SetPoint("TOPLEFT", 10, yOffset); entry:Show()
        entry:SetBackdropColor(i % 2 == 1 and 0.08 or 0.03, i % 2 == 1 and 0.08 or 0.03, i % 2 == 1 and 0.08 or 0.03, i % 2 == 1 and 0.8 or 0.4)
        
        local char = charData.char
        local hex = private.GetClassHexColor and private.GetClassHexColor(char.classFile) or "ffffffff"
        local r, g, b = 1, 1, 1
        if private.GetClassRGB then r, g, b = private.GetClassRGB(char.classFile) end

        entry:ToggleIcon(true)
        local coords = CLASS_ICON_TCOORDS[char.classFile]
        if coords then entry.icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"); entry.icon:SetTexCoord(unpack(coords))
        else entry.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark"); entry.icon:SetTexCoord(0,1,0,1) end

        entry.charName = char.name; entry.charKey = charData.key
        local nameStr = "|c" .. hex .. char.name .. "|r"
        if charData.key == private.playerKey then nameStr = nameStr .. " |cff00ff00(" .. private.GetLocalizedText("CURRENT") .. ")" .. "|r"; entry.deleteBtn:Hide() else entry.deleteBtn:Show() end
        entry.name:SetText(nameStr)
        entry.rightText:SetText(private.FormatTime(char.totalTime, format))
        entry.rightText:SetPoint("TOPRIGHT", -35, -8) -- Move it left to make room for delete btn

        local pct = totalAccountTime > 0 and (char.totalTime / totalAccountTime) or 0
        entry.bar:SetMinMaxValues(0, totalAccountTime > 0 and totalAccountTime or 1)
        entry.bar:SetValue(char.totalTime); entry.bar:SetStatusBarColor(r, g, b)
        entry.barText:SetText(string.format("%.1f%%", pct * 100))
        entry.subText:SetText(string.format("%s - Lvl %s %s", char.realm or "", char.level or "?", char.race or ""))
        
        yOffset = yOffset - 55
    end
    content:SetHeight(math.max(450, math.abs(yOffset) + 50))
end
