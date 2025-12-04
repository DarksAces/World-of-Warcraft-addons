local start = 0
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        start = GetTime()
        print("Combat started.")
    else
        print("Combat ended. Duration: " .. string.format("%.1fs", GetTime() - start))
    end
end)
