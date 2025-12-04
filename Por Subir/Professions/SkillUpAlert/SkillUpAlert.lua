local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_SKILL")

frame:SetScript("OnEvent", function(self, event, msg)
    if string.find(msg, "increased") then
        RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo["RAID_WARNING"])
        PlaySound(888)
    end
end)
