local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "GrizzlyHills" then
        print("Welcome to GrizzlyHills! Watch out for dangers.")
    end
end)
