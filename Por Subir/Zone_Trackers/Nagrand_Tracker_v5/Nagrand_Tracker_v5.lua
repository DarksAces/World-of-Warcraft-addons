local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Nagrand" then
        print("Welcome to Nagrand! Watch out for dangers.")
    end
end)
