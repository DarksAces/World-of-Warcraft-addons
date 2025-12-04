local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local emotes = {"ROAR", "CHEER", "FLEX", "DANCE"}

frame:SetScript("OnEvent", function()
    local _, event, _, sourceGUID, _, _, _, _, _, _, _, _, _, _, _, _, critical = CombatLogGetCurrentEventInfo()
    if sourceGUID == UnitGUID("player") and critical then
        if math.random(100) > 90 then -- 10% chance
            DoEmote(emotes[math.random(#emotes)])
        end
    end
end)
