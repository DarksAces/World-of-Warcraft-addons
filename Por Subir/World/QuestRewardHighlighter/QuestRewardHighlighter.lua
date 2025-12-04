local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_COMPLETE")

frame:SetScript("OnEvent", function()
    -- Logic to highlight most expensive item
    print("Best reward highlighted (Mockup)")
end)
