local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Durotar" then
        print("Welcome to Durotar! Watch out for dangers.")
    end
end)
