local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_HEALTH")

frame:SetScript("OnEvent", function(self, event, unit)
    if unit == "target" and not UnitIsFriend("player", "target") then
        local hp = UnitHealth("target")
        local max = UnitHealthMax("target")
        if (hp / max) < 0.2 and hp > 0 then
            RaidNotice_AddMessage(RaidWarningFrame, "EXECUTE!", ChatTypeInfo["RAID_WARNING"])
        end
    end
end)
