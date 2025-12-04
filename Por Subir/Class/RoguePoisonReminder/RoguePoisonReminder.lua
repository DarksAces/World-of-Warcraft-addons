local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

frame:SetScript("OnEvent", function()
    local _, class = UnitClass("player")
    if class == "ROGUE" then
        -- Check weapon enchants
        local hasMain, _, _, hasOff = GetWeaponEnchantInfo()
        if not hasMain or not hasOff then
            print("Rogue: Missing poisons!")
        end
    end
end)
