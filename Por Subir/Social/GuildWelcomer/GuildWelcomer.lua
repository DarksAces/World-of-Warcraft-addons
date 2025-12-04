local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_SYSTEM")

frame:SetScript("OnEvent", function(self, event, msg)
    if string.find(msg, "has come online") then
        -- SendChatMessage("Welcome back!", "GUILD") -- Commented out to avoid spam in testing
        print("Guild member online: " .. msg)
    end
end)
