local frame = CreateFrame("Button", "OpenAllMailButton", MailFrame, "UIPanelButtonTemplate")
frame:SetSize(100, 25)
frame:SetPoint("TOP", 0, 20)
frame:SetText("Open All")
frame:SetScript("OnClick", function()
    -- Logic to open all mail
    print("Opening all mail... (Mockup)")
end)
