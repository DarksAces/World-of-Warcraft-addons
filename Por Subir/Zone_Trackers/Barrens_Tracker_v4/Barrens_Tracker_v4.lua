local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Barrens" then
        print("Welcome to Barrens! Watch out for dangers.")
    end
end)
