local addonName = "BetterProfessionXP"
local f = CreateFrame("Frame")
local enabled = true

local function ShowProfXP(amount, skill)
    local msg = "+"..amount.." XP "..skill
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, 0, 0.6, 1, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, 0, 0.6, 1, 53, 3)
    end
end

f:RegisterEvent("TRADE_SKILL_UPDATE")
f:SetScript("OnEvent", function()
    if not enabled then return end
    -- placeholder: puedes mejorar para leer la XP real de la profesión
end)

SLASH_PROFTEXT1 = "/proftext"
SlashCmdList["PROFTEXT"] = function(msg)
    msg=msg:lower()
    if msg=="off" then enabled=false print("|cffff8800[BetterProfessionXP]|r Desactivado")
    elseif msg=="on" then enabled=true print("|cff88ff00[BetterProfessionXP]|r Activado")
    else print("|cffffff00Uso:|r /proftext on | off") end
end
