local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_DEAD")

frame:SetScript("OnEvent", function()
    -- Show arrow to corpse
    print("Corpse Arrow activated.")
end)
