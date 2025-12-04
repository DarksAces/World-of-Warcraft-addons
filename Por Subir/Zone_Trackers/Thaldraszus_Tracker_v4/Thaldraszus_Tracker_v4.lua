local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Thaldraszus" then
        print("Welcome to Thaldraszus! Watch out for dangers.")
    end
end)
