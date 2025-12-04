local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function()
    local _, event, _, sourceGUID, _, _, _, _, destName, _, _, spellID, spellName, _, extraSpellID, extraSpellName = CombatLogGetCurrentEventInfo()
    
    if sourceGUID == UnitGUID("player") and event == "SPELL_INTERRUPT" then
        local msg = "Interrupted " .. destName .. "'s " .. extraSpellName
        SendChatMessage(msg, "SAY")
    end
end)
