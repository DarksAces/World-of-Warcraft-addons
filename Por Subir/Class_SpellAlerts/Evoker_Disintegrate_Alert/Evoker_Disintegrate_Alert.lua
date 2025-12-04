local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function()
    local _, event, _, _, _, _, _, _, _, _, _, spellName = CombatLogGetCurrentEventInfo()
    if event == "SPELL_CAST_SUCCESS" and spellName == "Disintegrate" then
        print("Disintegrate cast detected!")
        PlaySound(12867)
    end
end)
