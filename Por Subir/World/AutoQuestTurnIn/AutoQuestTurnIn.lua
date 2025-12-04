local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")

frame:SetScript("OnEvent", function(self, event)
    if event == "QUEST_PROGRESS" then
        CompleteQuest()
    elseif event == "QUEST_COMPLETE" then
        if GetNumQuestChoices() <= 1 then
            GetQuestReward(1)
        end
    end
end)
