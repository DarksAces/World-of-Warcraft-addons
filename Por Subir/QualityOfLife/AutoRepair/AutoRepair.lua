local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")

frame:SetScript("OnEvent", function()
    if CanMerchantRepair() then
        local cost = GetRepairAllCost()
        if cost > 0 then
            if CanGuildBankRepair() and cost <= GetGuildBankWithdrawMoney() then
                RepairAllItems(true)
                print("|cff00ff00[AutoRepair]|r Repaired using Guild Bank: " .. GetCoinTextureString(cost))
            elseif cost <= GetMoney() then
                RepairAllItems()
                print("|cff00ff00[AutoRepair]|r Repaired: " .. GetCoinTextureString(cost))
            else
                print("|cffff0000[AutoRepair]|r Not enough money to repair!")
            end
        end
    end
end)
