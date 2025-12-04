local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Silithus" then
        print("Welcome to Silithus! Watch out for dangers.")
    end
end)
