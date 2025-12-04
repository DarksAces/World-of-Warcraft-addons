local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")

frame:SetScript("OnEvent", function(self, event, unit)
    if unit == "target" then
        local isTanking, status, threatpct = UnitDetailedThreatSituation("player", "target")
        if threatpct then
            print("Threat: " .. math.floor(threatpct) .. "%")
        end
    end
end)
