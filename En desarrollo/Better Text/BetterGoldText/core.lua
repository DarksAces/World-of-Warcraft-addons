local addonName = "BetterGoldText"
local f = CreateFrame("Frame")
local enabled = true

local function ShowGold(amount)
    local msg = "+"..amount.."g"
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, 1, 0.8, 0, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, 1, 0.8, 0, 53, 3)
    end
end

f:RegisterEvent("CHAT_MSG_MONEY")
f:SetScript("OnEvent", function(_, _, msg)
    if not enabled then return end
    local amount = msg:match("([%d,]+) gold") or msg
    ShowGold(amount)
end)

SLASH_GOLDTEXT1 = "/goldtext"
SlashCmdList["GOLDTEXT"] = function(msg)
    msg=msg:lower()
    if msg=="off" then enabled=false print("|cffff8800[BetterGoldText]|r Desactivado")
    elseif msg=="on" then enabled=true print("|cff88ff00[BetterGoldText]|r Activado")
    else print("|cffffff00Uso:|r /goldtext on | off") end
end
