local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Bastion" then
        print("Welcome to Bastion! Watch out for dangers.")
    end
end)
