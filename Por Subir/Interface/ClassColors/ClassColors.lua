-- Enable class colors in all chat channels
for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G["ChatFrame"..i]
    if frame then
        SetChatWindowColor(i, "SAY", 1, 1, 1)
        SetChatWindowColor(i, "EMOTE", 1, 1, 1)
        SetChatWindowColor(i, "YELL", 1, 1, 1)
        SetChatWindowColor(i, "GUILD", 1, 1, 1)
        SetChatWindowColor(i, "OFFICER", 1, 1, 1)
        SetChatWindowColor(i, "GUILD_ACHIEVEMENT", 1, 1, 1)
        SetChatWindowColor(i, "ACHIEVEMENT", 1, 1, 1)
        SetChatWindowColor(i, "WHISPER", 1, 1, 1)
        SetChatWindowColor(i, "PARTY", 1, 1, 1)
        SetChatWindowColor(i, "PARTY_LEADER", 1, 1, 1)
        SetChatWindowColor(i, "RAID", 1, 1, 1)
        SetChatWindowColor(i, "RAID_LEADER", 1, 1, 1)
        SetChatWindowColor(i, "RAID_WARNING", 1, 1, 1)
        SetChatWindowColor(i, "BATTLEGROUND", 1, 1, 1)
        SetChatWindowColor(i, "BATTLEGROUND_LEADER", 1, 1, 1)
        SetChatWindowColor(i, "CHANNEL1", 1, 1, 1)
        SetChatWindowColor(i, "CHANNEL2", 1, 1, 1)
        SetChatWindowColor(i, "CHANNEL3", 1, 1, 1)
        SetChatWindowColor(i, "CHANNEL4", 1, 1, 1)
        SetChatWindowColor(i, "CHANNEL5", 1, 1, 1)
    end
end
-- Force CVar
SetCVar("chatClassColorOverride", 0)
