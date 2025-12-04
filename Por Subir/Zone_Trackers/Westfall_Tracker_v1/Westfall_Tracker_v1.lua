local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Westfall" then
        print("Welcome to Westfall! Watch out for dangers.")
    end
end)
