local frame = CreateFrame("Frame")
frame:RegisterEvent("PARTY_INVITE_REQUEST")

frame:SetScript("OnEvent", function(self, event, name)
    if C_FriendList.IsFriend(name) or IsGuildMember(name) then
        AcceptGroup()
        StaticPopup_Hide("PARTY_INVITE")
        print("Auto-accepted invite from " .. name)
    end
end)
