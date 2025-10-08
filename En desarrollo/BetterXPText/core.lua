local addonName = "BetterXPText"
local f = CreateFrame("Frame")
local enabled = true

local function ShowXP(amount)
    local msg = "+"..amount.." XP"
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, 0.7, 0.4, 1, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, 0.7, 0.4, 1, 53, 3)
    end
end

f:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
f:SetScript("OnEvent", function(_, _, msg)
    if not enabled then return end
    local xp = msg:match("([0-9]+) experience")
    if xp then
        ShowXP(xp)
    end
end)

SLASH_XPTEXT1 = "/xptext"
SlashCmdList["XPTEXT"] = function(msg)
    msg = msg:lower()
    if msg == "off" then enabled=false print("|cffff8800[BetterXPText]|r Desactivado") 
    elseif msg=="on" then enabled=true print("|cff88ff00[BetterXPText]|r Activado") 
    else print("|cffffff00Uso:|r /xptext on | off") end
end
