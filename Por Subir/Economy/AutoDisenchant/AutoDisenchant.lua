local frame = CreateFrame("Frame")
frame:RegisterEvent("START_LOOT_ROLL")

frame:SetScript("OnEvent", function(self, event, rollID)
    RollOnLoot(rollID, 3) -- 3 is Disenchant
    print("Auto Disenchant rolled.")
end)
