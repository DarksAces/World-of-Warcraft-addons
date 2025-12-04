local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_POWER_UPDATE")

frame:SetScript("OnEvent", function(self, event, unit, powerType)
    if unit == "player" and powerType == "ESSENCE" then
        local essence = UnitPower("player", Enum.PowerType.Essence)
        print("Essence: " .. essence)
    end
end)
