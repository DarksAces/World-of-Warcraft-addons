local badWords = {"badword1", "badword2"} -- Example list

local function Filter(self, event, msg, ...)
    for _, word in ipairs(badWords) do
        if string.find(string.lower(msg), word) then
            return true -- Filter it
        end
    end
    return false, msg, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", Filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", Filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", Filter)
