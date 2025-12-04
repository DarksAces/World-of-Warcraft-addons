local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

frame:SetScript("OnEvent", function()
    local _, class = UnitClass("player")
    if class == "WARRIOR" then
        -- Check for Battle Shout buff
        print("Warrior: Check your shout!")
    end
end)
