local frame = CreateFrame("Frame")
frame:RegisterEvent("PARTY_INVITE_REQUEST")
frame:RegisterEvent("CONFIRM_SUMMON")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PARTY_INVITE_REQUEST" then
        local sender = ...
        local isFriend = C_FriendList.IsFriend(sender)
        
        if not isFriend then
            local numBNet = BNGetNumFriends()
            for i=1, numBNet do
                local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
                if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.characterName == sender then
                    isFriend = true
                    break
                end
            end
        end

        if isFriend then
            AcceptGroup()
            StaticPopup_Hide("PARTY_INVITE")
            print("|cFF00FF00PartyPass:|r Accepted invite from " .. sender)
        end
    elseif event == "CONFIRM_SUMMON" then
        C_SummonInfo.ConfirmSummon()
        StaticPopup_Hide("CONFIRM_SUMMON")
        print("|cFF00FF00PartyPass:|r Auto accepted summon.")
    end
end)
