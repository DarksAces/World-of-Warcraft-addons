local lastSkin = 0
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function()
    local _, event, _, sourceGUID, _, _, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
    if event == "SPELL_CAST_SUCCESS" and sourceGUID == UnitGUID("player") and spellName == "Skinning" then
        local now = GetTime()
        if lastSkin > 0 then
            print("Time since last skin: " .. string.format("%.1fs", now - lastSkin))
        end
        lastSkin = now
    end
end)
