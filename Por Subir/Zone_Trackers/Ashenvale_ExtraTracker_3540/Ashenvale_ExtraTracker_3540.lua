local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Ashenvale" then
        print("Welcome to Ashenvale! Watch out for dangers.")
    end
end)
