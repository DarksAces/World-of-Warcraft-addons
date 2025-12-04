-- Auto-loot speedup by hiding the loot frame immediately if auto-loot is on
local frame = CreateFrame("Frame")
frame:RegisterEvent("LOOT_READY")

frame:SetScript("OnEvent", function()
    if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        for i = GetNumLootItems(), 1, -1 do
            LootSlot(i)
        end
    end
end)
