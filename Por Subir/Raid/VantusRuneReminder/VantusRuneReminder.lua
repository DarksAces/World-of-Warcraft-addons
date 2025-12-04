local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")

frame:SetScript("OnEvent", function(self, event, id, name)
    -- Check if Vantus Rune is active for this boss
    print("Vantus Rune check for " .. name)
end)
