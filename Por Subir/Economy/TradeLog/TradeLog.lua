local frame = CreateFrame("Frame")
frame:RegisterEvent("TRADE_ACCEPT_UPDATE")

frame:SetScript("OnEvent", function(self, event, playerAccepted, targetAccepted)
    if playerAccepted and targetAccepted then
        print("Trade successful.")
    end
end)
