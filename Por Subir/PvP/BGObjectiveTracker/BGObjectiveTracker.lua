local frame = CreateFrame("Frame")
frame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")

frame:SetScript("OnEvent", function()
    -- GetBattlefieldScore()
    print("BG Status Update")
end)
