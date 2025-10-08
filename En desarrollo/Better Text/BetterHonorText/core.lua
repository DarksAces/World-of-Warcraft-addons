local addonName = "BetterHonorText"
local f = CreateFrame("Frame")
local enabled = true

local function ShowHonor(msg)
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, 1, 0, 0, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, 1, 0, 0, 53, 3)
    end
end

f:RegisterEvent("PLAYER_PVP_KILLS")
f:SetScript("OnEvent", function(_, _, msg)
    if not enabled then return end
    ShowHonor("PvP Kill!")
end)

SLASH_HONORTEXT1 = "/honortext"
SlashCmdList["HONORTEXT"] = function(msg)
    msg=msg:lower()
    if msg=="off" then enabled=false print("|cffff8800[BetterHonorText]|r Desactivado")
    elseif msg=="on" then enabled=true print("|cff88ff00[BetterHonorText]|r Activado")
    else print("|cffffff00Uso:|r /honortext on | off") end
end
