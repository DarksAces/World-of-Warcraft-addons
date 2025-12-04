local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_DETAIL")

frame:SetScript("OnEvent", function()
    AcceptQuest()
    print("Quest accepted automatically.")
end)
