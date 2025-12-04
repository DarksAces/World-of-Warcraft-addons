local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function()
    local _, event, _, _, _, _, _, _, _, _, _, spellId = CombatLogGetCurrentEventInfo()
    if event == "SPELL_CAST_SUCCESS" and (spellId == 31884 or spellId == 1719) then -- Avenging Wrath / Recklessness
        print("BURST INCOMING!")
        PlaySound(11466)
    end
end)
