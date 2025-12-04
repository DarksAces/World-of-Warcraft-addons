SLASH_PULLTIMER1 = "/pull"
SlashCmdList["PULLTIMER"] = function(msg)
    local seconds = tonumber(msg) or 10
    C_PartyInfo.DoCountdown(seconds)
end
