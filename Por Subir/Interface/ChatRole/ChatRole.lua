local function AddRoleIcon(self, event, msg, author, ...)
    local name = strsplit("-", author)
    local role = UnitGroupRolesAssigned(name)
    local icon = ""
    
    if role == "TANK" then icon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAIT:0:0:0:0:64:64:0:19:22:41|t"
    elseif role == "HEALER" then icon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAIT:0:0:0:0:64:64:20:39:1:20|t"
    elseif role == "DAMAGER" then icon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAIT:0:0:0:0:64:64:20:39:22:41|t"
    end
    
    if icon ~= "" then
        msg = icon .. " " .. msg
    end
    
    return false, msg, author, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", AddRoleIcon)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", AddRoleIcon)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", AddRoleIcon)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", AddRoleIcon)
