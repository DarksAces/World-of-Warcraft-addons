local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function()
    local _, event, _, _, _, _, _, _, _, _, _, spellId = CombatLogGetCurrentEventInfo()
    if event == "SPELL_INTERRUPT" then
        print("Interrupt used!")
    end
end)
