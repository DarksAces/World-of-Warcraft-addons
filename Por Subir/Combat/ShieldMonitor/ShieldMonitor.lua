local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_AURA")

frame:SetScript("OnEvent", function(self, event, unit)
    if unit == "player" then
        -- Check for shield buffs (PW:S, Ice Barrier)
    end
end)
