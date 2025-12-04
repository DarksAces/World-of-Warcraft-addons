local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Tirisfal" then
        print("Welcome to Tirisfal! Watch out for dangers.")
    end
end)
