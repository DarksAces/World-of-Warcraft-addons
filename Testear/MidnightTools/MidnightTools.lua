local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")

frame:SetScript("OnEvent", function(self, event)
    if event == "MERCHANT_SHOW" then
        -- Auto Sell Grey Items
        local bag, slot
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info then
                    local itemLink = info.hyperlink
                    if itemLink then
                        local _, _, quality, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemLink)
                        if quality == 0 and sellPrice > 0 then
                            C_Container.UseContainerItem(bag, slot)
                        end
                    end
                end
            end
        end

        -- Auto Repair
        if CanMerchantRepair() then
            local repairCost = GetRepairAllCost()
            if repairCost > 0 and GetMoney() >= repairCost then
                RepairAllItems()
                print("|cFF00FF00MidnightTools:|r Repaired all items for " .. GetCoinTextureString(repairCost))
            end
        end
    end
end)
