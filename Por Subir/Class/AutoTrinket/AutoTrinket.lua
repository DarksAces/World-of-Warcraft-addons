local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

frame:SetScript("OnEvent", function()
    -- UseInventoryItem(13)
    -- UseInventoryItem(14)
    print("Trinkets used (Mockup)")
end)
