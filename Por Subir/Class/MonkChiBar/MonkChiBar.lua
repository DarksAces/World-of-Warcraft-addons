local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_POWER_UPDATE")

frame:SetScript("OnEvent", function(self, event, unit, powerType)
    if unit == "player" and powerType == "CHI" then
        local chi = UnitPower("player", Enum.PowerType.Chi)
        print("Chi: " .. chi)
    end
end)
