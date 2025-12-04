local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_POWER_UPDATE")

frame:SetScript("OnEvent", function(self, event, unit, powerType)
    if unit == "player" and powerType == "SOUL_SHARDS" then
        local shards = UnitPower("player", Enum.PowerType.SoulShards)
        print("Shards: " .. shards)
    end
end)
