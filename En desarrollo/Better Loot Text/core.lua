local addonName = "BetterLootText"
local f = CreateFrame("Frame")
local enabled = true

local function ShowLoot(msg)
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, 1, 0.82, 0, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, 1, 0.82, 0, 53, 3)
    end
end

f:RegisterEvent("CHAT_MSG_LOOT")
f:SetScript("OnEvent", function(_, _, msg)
    if not enabled then return end
    ShowLoot(msg)
end)

SLASH_LOOTTEXT1 = "/loottext"
SlashCmdList["LOOTTEXT"] = function(msg)
    msg = msg:lower()
    if msg=="off" then enabled=false print("|cffff8800[BetterLootText]|r Desactivado")
    elseif msg=="on" then enabled=true print("|cff88ff00[BetterLootText]|r Activado")
    else print("|cffffff00Uso:|r /loottext on | off") end
end
