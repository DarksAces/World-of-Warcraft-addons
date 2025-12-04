local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Tanaris" then
        print("Welcome to Tanaris! Watch out for dangers.")
    end
end)
