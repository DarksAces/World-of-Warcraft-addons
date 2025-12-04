-- Hook into chat frame message event
local function AddTimestamp(self, event, msg, ...)
    if type(msg) == "string" then
        msg = "|cff888888[" .. date("%H:%M") .. "]|r " .. msg
    end
    return false, msg, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", AddTimestamp)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", AddTimestamp)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", AddTimestamp)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", AddTimestamp)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", AddTimestamp)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", AddTimestamp)
-- Add more as needed
