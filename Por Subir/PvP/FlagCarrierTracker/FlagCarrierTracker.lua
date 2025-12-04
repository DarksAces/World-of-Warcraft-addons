local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
frame:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")

frame:SetScript("OnEvent", function(self, event, msg)
    if string.find(msg, "picked up") then
        print("Flag picked up!")
        PlaySound(12867)
    end
end)
