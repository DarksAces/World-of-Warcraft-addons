local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("GUILD_MOTD")

frame:SetScript("OnEvent", function()
    local motd = GetGuildRosterMOTD()
    if motd and motd ~= "" then
        RaidNotice_AddMessage(RaidWarningFrame, "Guild MOTD: " .. motd, ChatTypeInfo["RAID_WARNING"])
    end
end)
