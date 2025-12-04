local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

frame:SetScript("OnEvent", function()
    if IsResting() then
        print("You are in a Safe Zone.")
    else
        print("You are in a Contested Zone.")
    end
end)
