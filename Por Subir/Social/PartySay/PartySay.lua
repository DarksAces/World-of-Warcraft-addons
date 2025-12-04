local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_SAY")

frame:SetScript("OnEvent", function(self, event, msg, author)
    if author == UnitName("player") and IsInGroup() then
        SendChatMessage("[SAY]: " .. msg, "PARTY")
    end
end)
