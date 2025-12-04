local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function()
    local _, class = UnitClass("player")
    if class == "MAGE" then
        -- Check for food in bags (Mockup)
        print("Mage: Don't forget to conjure food!")
    end
end)
