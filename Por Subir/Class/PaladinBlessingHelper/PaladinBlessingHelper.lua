local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

frame:SetScript("OnEvent", function()
    local _, class = UnitClass("player")
    if class == "PALADIN" then
        -- Check for blessings
        print("Paladin: Buff your allies!")
    end
end)
