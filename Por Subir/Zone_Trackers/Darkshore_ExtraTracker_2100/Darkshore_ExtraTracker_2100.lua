local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Darkshore" then
        print("Welcome to Darkshore! Watch out for dangers.")
    end
end)
