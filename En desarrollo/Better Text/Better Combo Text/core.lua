local addonName = "BetterComboText"
local f = CreateFrame("Frame")
local enabled = true

local function ShowCombo(msg)
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, 1, 0, 1, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, 1, 0, 1, 53, 3)
    end
end

f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(_, _, ...)
    if not enabled then return end
    local timestamp, subevent, _, _, _, _, _, _, _, _, _, spellId = CombatLogGetCurrentEventInfo()
    if subevent=="SPELL_DAMAGE" or subevent=="SWING_DAMAGE" then
        ShowCombo("Combo!")
    end
end)

SLASH_COMBOTEXT1 = "/combotext"
SlashCmdList["COMBOTEXT"] = function(msg)
    msg=msg:lower()
    if msg=="off" then enabled=false print("|cffff8800[BetterComboText]|r Desactivado")
    elseif msg=="on" then enabled=true print("|cff88ff00[BetterComboText]|r Activado")
    else print("|cffffff00Uso:|r /combotext on | off") end
end
