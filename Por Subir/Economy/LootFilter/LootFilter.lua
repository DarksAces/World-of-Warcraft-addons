local frame = CreateFrame("Frame")
frame:RegisterEvent("LOOT_OPENED")

frame:SetScript("OnEvent", function()
    -- Logic to filter loot
    print("Loot Filter active (Mockup)")
end)
