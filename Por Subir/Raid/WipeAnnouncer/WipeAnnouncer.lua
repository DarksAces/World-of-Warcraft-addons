local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_RAID_LEADER")

frame:SetScript("OnEvent", function(self, event, msg)
    if string.lower(msg) == "wipe" then
        SendChatMessage("WIPE CALLED!", "RAID_WARNING")
        PlaySound(12867)
    end
end)
