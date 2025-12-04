local frame = CreateFrame("Frame")
frame:RegisterEvent("BOSS_KILL")

frame:SetScript("OnEvent", function(self, event, id, name)
    print("Boss " .. name .. " down! Cheese!")
    Screenshot()
end)
