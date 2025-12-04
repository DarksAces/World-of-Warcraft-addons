local frame = CreateFrame("Frame")
frame:RegisterEvent("RUNE_POWER_UPDATE")

frame:SetScript("OnEvent", function(self, event, runeIndex, isEnergize)
    if isEnergize then
        print("Rune " .. runeIndex .. " ready.")
    end
end)
