local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

frame:SetScript("OnEvent", function()
    local _, class = UnitClass("player")
    if class == "PRIEST" then
        -- Check for Fortitude
        print("Priest: Fortitude missing?")
    end
end)
