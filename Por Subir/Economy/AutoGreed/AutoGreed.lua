local frame = CreateFrame("Frame")
frame:RegisterEvent("START_LOOT_ROLL")

frame:SetScript("OnEvent", function(self, event, rollID)
    RollOnLoot(rollID, 2) -- 2 is Greed
    print("Auto Greed rolled.")
end)
