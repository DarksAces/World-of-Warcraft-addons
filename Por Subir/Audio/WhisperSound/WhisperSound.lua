local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_WHISPER")

frame:SetScript("OnEvent", function()
    PlaySound(3081) -- Whisper sound
end)
