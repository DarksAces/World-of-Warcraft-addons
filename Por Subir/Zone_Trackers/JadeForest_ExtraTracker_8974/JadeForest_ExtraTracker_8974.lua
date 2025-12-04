local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "JadeForest" then
        print("Welcome to JadeForest! Watch out for dangers.")
    end
end)
