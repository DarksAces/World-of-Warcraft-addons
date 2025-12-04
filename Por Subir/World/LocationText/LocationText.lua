local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED")

frame:SetScript("OnEvent", function()
    print("Location: " .. GetMinimapZoneText())
end)
