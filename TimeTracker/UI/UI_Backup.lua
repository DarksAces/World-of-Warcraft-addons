local addonName, private = ...

-- Backup / Import Logic
function private.UpdateBackupPanel(frame)
    local panel = frame.backupPanel
    if not panel then return end

    -- Initialize UI elements if they don't exist
    if not panel.backupDesc then
        local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        desc:SetPoint("TOPLEFT", 20, -20)
        desc:SetPoint("TOPRIGHT", -20, -20)
        desc:SetJustifyH("LEFT")
        desc:SetText(private.GetLocalizedText("BACKUP_DESC"))
        panel.backupDesc = desc

        local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
        scroll:SetSize(780, 400)
        scroll:SetPoint("TOPLEFT", 20, -100)
        
        local eb = CreateFrame("EditBox", nil, scroll)
        eb:SetMultiLine(true)
        eb:SetMaxLetters(999999)
        eb:SetFontObject("ChatFontNormal")
        eb:SetWidth(760)
        eb:SetAutoFocus(false)
        scroll:SetScrollChild(eb)
        panel.backupEditBox = eb
        
        local bg = CreateFrame("Frame", nil, panel, "BackdropTemplate")
        bg:SetPoint("TOPLEFT", scroll, -5, 5)
        bg:SetPoint("BOTTOMRIGHT", scroll, 5, -5)
        bg:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile = true, tileSize = 16, edgeSize = 1,
        })
        bg:SetBackdropColor(0, 0, 0, 0.5)
        bg:SetBackdropBorderColor(1, 1, 1, 0.2)
        bg:SetFrameLevel(panel:GetFrameLevel())

        -- Buttons
        local exportBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        exportBtn:SetSize(120, 30)
        exportBtn:SetPoint("TOPLEFT", 20, -60)
        exportBtn:SetText(private.GetLocalizedText("EXPORT_BUTTON"))
        exportBtn:SetScript("OnClick", function()
            local code = private.SerializeDatabase()
            panel.backupEditBox:SetText(code)
            panel.backupEditBox:HighlightText()
            panel.backupEditBox:SetFocus()
            print("|cff00ff00Time Tracker:|r " .. private.GetLocalizedText("EXPORT_SUCCESS"))
        end)

        local importBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        importBtn:SetSize(120, 30)
        importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 10, 0)
        importBtn:SetText(private.GetLocalizedText("IMPORT_BUTTON"))
        importBtn:SetScript("OnClick", function()
            StaticPopup_Show("TIMETRACKER_CONFIRM_IMPORT")
        end)
    end

    -- Update content
    local code = private.SerializeDatabase()
    panel.backupEditBox:SetText(code)
end

-- Confirmation Popup setup
if not StaticPopupDialogs["TIMETRACKER_CONFIRM_IMPORT"] then
    StaticPopupDialogs["TIMETRACKER_CONFIRM_IMPORT"] = {
        text = private.GetLocalizedText("CONFIRM_IMPORT"),
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            local editBox = TimeTrackerFrame.backupPanel.backupEditBox
            if editBox then
                local code = editBox:GetText()
                local success, count = private.DeserializeDatabase(code)
                if success then
                    print("|cff00ff00Time Tracker:|r " .. string.format(private.GetLocalizedText("IMPORT_SUCCESS"), count or 0))
                    ReloadUI()
                else
                    print("|cffff0000Time Tracker:|r " .. private.GetLocalizedText("IMPORT_ERROR"))
                end
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
end
