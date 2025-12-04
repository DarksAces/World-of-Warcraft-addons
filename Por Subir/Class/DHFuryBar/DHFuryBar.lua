local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_POWER_UPDATE")

frame:SetScript("OnEvent", function(self, event, unit, powerType)
    if unit == "player" and powerType == "FURY" then
        local fury = UnitPower("player", Enum.PowerType.Fury)
        print("Fury: " .. fury)
    end
end)
