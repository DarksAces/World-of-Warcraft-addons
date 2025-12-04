SLASH_RAIDFRAMESCALER1 = "/rfs"
SlashCmdList["RAIDFRAMESCALER"] = function(msg)
    local scale = tonumber(msg) or 1.0
    if CompactRaidFrameContainer then
        CompactRaidFrameContainer:SetScale(scale)
    end
end
