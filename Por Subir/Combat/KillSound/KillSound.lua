local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function()
    local _, event, _, sourceGUID = CombatLogGetCurrentEventInfo()
    if event == "PARTY_KILL" and sourceGUID == UnitGUID("player") then
        PlaySound(120) -- "Ding" sound or similar
    end
end)
