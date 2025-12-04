local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")

frame:SetScript("OnEvent", function(self, event, msg)
    if string.find(msg, "Orb") then
        print("Orb update: " .. msg)
    end
end)
