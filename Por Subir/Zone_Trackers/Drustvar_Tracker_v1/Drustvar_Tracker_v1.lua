local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Drustvar" then
        print("Welcome to Drustvar! Watch out for dangers.")
    end
end)
