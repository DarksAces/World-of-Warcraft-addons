local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_YELL")

frame:SetScript("OnEvent", function(self, event, msg, author)
    if author == UnitName("player") and IsInRaid() then
        SendChatMessage("[YELL]: " .. msg, "RAID")
    end
end)
