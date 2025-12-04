local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LEVEL_UP")

frame:SetScript("OnEvent", function(self, event, level)
    print("|cff00ff00[ScreenshotLevel]|r Level " .. level .. " reached! Cheese!")
    Screenshot()
end)
