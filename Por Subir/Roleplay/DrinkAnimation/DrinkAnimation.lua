local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

frame:SetScript("OnEvent", function(self, event, unit, _, spellID)
    if unit == "player" and spellID == 12346 then -- Drink spell ID
        DoEmote("DRINK")
    end
end)
