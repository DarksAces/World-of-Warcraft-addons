local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")

frame:SetScript("OnEvent", function(self, event, msg)
    -- SendChatMessage("Gz!", "GUILD")
    print("Achievement detected: " .. msg)
end)
