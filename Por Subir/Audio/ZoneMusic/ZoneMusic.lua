local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

frame:SetScript("OnEvent", function()
    local zone = GetZoneText()
    print("Entered " .. zone .. ". Playing theme... (Mockup)")
end)
