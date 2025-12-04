local damage = 0
local start = 0
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        damage = 0
        start = GetTime()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, _, _, _, _, _, _, _, amount = CombatLogGetCurrentEventInfo()
        if subEvent == "SWING_DAMAGE" and sourceGUID == UnitGUID("player") then
            damage = damage + amount
        elseif subEvent == "SPELL_DAMAGE" and sourceGUID == UnitGUID("player") then
            damage = damage + amount -- amount is arg15 for spell_damage, simplified here
        end
    end
end)
