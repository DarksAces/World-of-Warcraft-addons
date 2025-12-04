local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Winterspring" then
        print("Welcome to Winterspring! Watch out for dangers.")
    end
end)
