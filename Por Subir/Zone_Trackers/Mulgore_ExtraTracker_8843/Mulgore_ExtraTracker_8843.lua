local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Mulgore" then
        print("Welcome to Mulgore! Watch out for dangers.")
    end
end)
