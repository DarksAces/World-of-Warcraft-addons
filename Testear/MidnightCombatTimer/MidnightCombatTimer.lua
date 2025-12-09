local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

local combatStart = 0

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        combatStart = GetTime()
        print("|cFFFF0000Combat Started|r")
    elseif event == "PLAYER_REGEN_ENABLED" then
        if combatStart > 0 then
            local duration = GetTime() - combatStart
            print(string.format("|cFF00FF00Combat Ended:|r Duration: %.2f seconds", duration))
            combatStart = 0
        end
    end
end)
