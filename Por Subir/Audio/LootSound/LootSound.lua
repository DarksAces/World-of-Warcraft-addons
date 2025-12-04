local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_LOOT")

frame:SetScript("OnEvent", function(self, event, msg)
    if string.find(msg, "Epic") or string.find(msg, "Legendary") then
        PlaySound(1184) -- Epic loot sound
    end
end)
