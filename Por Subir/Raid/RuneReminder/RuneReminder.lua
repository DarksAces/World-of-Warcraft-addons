local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

frame:SetScript("OnEvent", function()
    if IsInRaid() then
        -- Check for rune buff
        print("Rune check!")
    end
end)
