local frame = CreateFrame("Frame")
frame:RegisterEvent("DUEL_REQUESTED")

frame:SetScript("OnEvent", function(self, event, name)
    CancelDuel()
    print("Duel declined from " .. name)
end)
