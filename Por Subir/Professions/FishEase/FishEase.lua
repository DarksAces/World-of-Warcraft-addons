local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")

frame:SetScript("OnEvent", function(self, event, unit, _, spellID)
    if unit == "player" and spellID == 131474 then -- Fishing spell ID
        SetCVar("Sound_EnableSFX", 1) -- Ensure sound is on
        print("Fishing started! Volume up.")
    end
end)
