local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Stranglethorn" then
        print("Welcome to Stranglethorn! Watch out for dangers.")
    end
end)
