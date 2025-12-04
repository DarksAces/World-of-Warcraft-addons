local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        -- PlayMusic("Interface\\AddOns\\CombatMusic\\combat.mp3")
        print("Combat music started (Mockup)")
    else
        -- StopMusic()
        print("Combat music stopped (Mockup)")
    end
end)
