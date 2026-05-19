local addonName, private = ...

-- Update Personal Stats
function private.UpdateCurrentCharacterStats(frame)
    local char = TimeTrackerDB.characters[private.playerKey]
    local format = TimeTrackerDB.settings.timeFormat
    local panel = frame.personalPanel
    local content = panel.content
    local yOffset = -10

    panel.characterFontStrings = panel.characterFontStrings or {}
    for _, fs in pairs(panel.characterFontStrings) do fs:Hide() end
    content:SetHeight(450) -- Reset

    if not char then
        if not panel.noDataText then
            panel.noDataText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            panel.noDataText:SetPoint("CENTER", content, "CENTER", 0, 0)
            panel.noDataText:SetTextColor(1, 0.5, 0)
        end
        panel.noDataText:SetText(private.GetLocalizedText("NO_DATA"))
        panel.noDataText:Show()
        return
    end
    if panel.noDataText then panel.noDataText:Hide() end

    -- Helper
    -- Helper para crear lineas interactivas
    local function AddLine(text, font, r, g, b, extraY, isClickable, rawTextToLink)
        local index = #panel.characterFontStrings + 1
        local btn = panel.characterFontStrings[index]
        if not btn then
            btn = CreateFrame("Button", nil, content)
            btn.text = btn:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
            btn.text:SetPoint("LEFT", btn, "LEFT", 0, 0)
            panel.characterFontStrings[index] = btn
        end
        btn:Show()
        btn:SetSize(400, 20)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)
        btn.text:SetFontObject(font or "GameFontNormal")
        btn.text:SetText(text)
        if r then btn.text:SetTextColor(r, g, b) end
        
        if isClickable and rawTextToLink then
            btn:EnableMouse(true)
            btn:SetScript("OnClick", function(self)
                if IsShiftKeyDown() then
                    local chatEditBox = ChatEdit_ChooseBoxForSend()
                    if chatEditBox and not chatEditBox:IsVisible() then
                        ChatFrame_OpenChat(rawTextToLink)
                    elseif chatEditBox then
                        chatEditBox:Insert(rawTextToLink)
                    end
                end
            end)
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Shift-Click para compartir en el chat", 1, 1, 1)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        else
            btn:EnableMouse(false)
            btn:SetScript("OnClick", nil)
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
        end
        
        yOffset = yOffset - (extraY or 20)
        return btn
    end

    local nameText = AddLine(char.name .. " - " .. char.realm, "GameFontHighlightLarge", 1, 1, 1, 25)
    
    local classText = AddLine(private.GetLocalizedText("LEVEL") .. " " .. (char.level or "?") .. " " .. (char.class or "") .. " " .. (char.race or ""), "GameFontHighlight", 0.8, 0.8, 0.8, 40)
    
    AddLine(private.GetLocalizedText("MAIN_STATS"), "GameFontNormalLarge", 1, 0.8, 0, 25)
    
    local totalFormatted = private.FormatTime(char.totalTime, format)
    local chatTextTotal = "Mi personaje " .. char.name .. " ha jugado un total de: " .. totalFormatted
    AddLine(private.GetLocalizedText("TOTAL_TIME") .. ": " .. totalFormatted, "GameFontHighlight", 1, 1, 0, 20, true, chatTextTotal)
    
    local levelFormatted = private.FormatTime(char.levelTime or 0, format)
    local chatTextLevel = "Mi personaje " .. char.name .. " ha jugado en nivel " .. (char.level or 0) .. " un total de: " .. levelFormatted
    AddLine(string.format(private.GetLocalizedText("LEVEL_TIME"), char.level or 0) .. ": " .. levelFormatted, "GameFontHighlight", 0.8, 0.8, 1, 35, true, chatTextLevel)

    AddLine(private.GetLocalizedText("PLAY_TIME"), "GameFontNormalLarge", 0, 1, 1, 25)
    AddLine(private.GetLocalizedText("TODAY_LABEL") .. ": " .. private.FormatTime(char.daily[private.GetCurrentDate()] or 0, format), "GameFontHighlight", 0, 1, 0)
    AddLine(private.GetLocalizedText("THIS_WEEK_LABEL") .. ": " .. private.FormatTime(char.weekly[private.GetCurrentWeek()] or 0, format), "GameFontHighlight", 0, 0.8, 1)
    AddLine(private.GetLocalizedText("THIS_MONTH_LABEL") .. ": " .. private.FormatTime(char.monthly[private.GetCurrentMonth()] or 0, format), "GameFontHighlight", 1, 0, 1)
    
    local currentYear = private.GetCurrentYear and private.GetCurrentYear() or date("%Y")
    local yearTime = (char.yearly and char.yearly[currentYear]) or 0
    AddLine(private.GetLocalizedText("THIS_YEAR_LABEL") .. ": " .. private.FormatTime(yearTime, format), "GameFontHighlight", 1, 0.5, 0, 35)

    AddLine(private.GetLocalizedText("LAST_7_DAYS"), "GameFontNormalLarge", 1, 0.6, 1, 25)
    
    local today = time()
    local shortDays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
    if GetLocale() == "esES" or GetLocale() == "esMX" then
       shortDays = {"Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"}
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
    content:SetHeight(math.max(450, neededHeight))
end
