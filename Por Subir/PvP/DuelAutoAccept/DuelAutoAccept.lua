local frame = CreateFrame("Frame")
frame:RegisterEvent("DUEL_REQUESTED")

frame:SetScript("OnEvent", function(self, event, name)
    AcceptDuel()
    print("Duel accepted from " .. name)
end)
