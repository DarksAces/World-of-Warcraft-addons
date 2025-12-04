local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_TURNED_IN")

frame:SetScript("OnEvent", function()
    PlaySound(618) -- Quest complete sound
end)
