local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

frame:SetScript("OnEvent", function()
    print("Zone: " .. GetZoneText())
    print("Subzone: " .. GetSubZoneText())
end)
