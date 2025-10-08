local addonName = "BetterRepText"
local f = CreateFrame("Frame")
local enabled = true

local function ShowRep(amount, faction)
    local msg = "+"..amount.." "..faction
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, 0.2, 0.8, 0.2, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, 0.2, 0.8, 0.2, 53, 3)
    end
end

f:RegisterEvent("COMBAT_TEXT_UPDATE")
f:SetScript("OnEvent", function(_, _, arg1, arg2)
    if not enabled then return end
    if arg1=="FACTION" and arg2 then
        local name, _, _, _, value = GetWatchedFactionInfo()
        if name and value then ShowRep(value,name) end
    end
end)

SLASH_REPTEXT1 = "/reptext"
SlashCmdList["REPTEXT"] = function(msg)
    msg = msg:lower()
    if msg=="off" then enabled=false print("|cffff8800[BetterRepText]|r Desactivado")
    elseif msg=="on" then enabled=true print("|cff88ff00[BetterRepText]|r Activado")
    else print("|cffffff00Uso:|r /reptext on | off") end
end
