local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function()
    local _, event, _, sourceGUID, _, _, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
    if event == "SPELL_CAST_SUCCESS" and sourceGUID == UnitGUID("player") then
        if spellName == "Herb Gathering" then
            local mapID = C_Map.GetBestMapForUnit("player")
            local pos = C_Map.GetPlayerMapPosition(mapID, "player")
            print("Herb gathered at " .. pos.x .. ", " .. pos.y)
        end
    end
end)
