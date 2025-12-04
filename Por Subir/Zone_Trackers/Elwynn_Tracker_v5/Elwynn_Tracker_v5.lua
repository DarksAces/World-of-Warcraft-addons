local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "Elwynn" then
        print("Welcome to Elwynn! Watch out for dangers.")
    end
end)
