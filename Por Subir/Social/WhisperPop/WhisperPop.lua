local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_WHISPER")

frame:SetScript("OnEvent", function()
    PlaySound(12867) -- Pop sound
end)
