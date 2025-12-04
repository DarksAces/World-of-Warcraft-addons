local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

frame:SetScript("OnEvent", function(self, event, unit, _, spellID)
    if unit == "player" and spellID == 12345 then -- Food spell ID
        DoEmote("EAT")
    end
end)
