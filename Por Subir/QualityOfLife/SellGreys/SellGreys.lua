local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")

frame:SetScript("OnEvent", function()
    local total = 0
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info then
                local quality = C_Item.GetItemQualityByID(info.itemID)
                if quality == 0 then -- 0 is Poor (Gray)
                    local price = select(11, C_Item.GetItemInfo(info.itemID))
                    if price and price > 0 then
                        C_Container.UseContainerItem(bag, slot)
                        total = total + (price * info.stackCount)
                    end
                end
            end
        end
    end
    if total > 0 then
        print("|cff00ff00[SellGreys]|r Sold junk for: " .. GetCoinTextureString(total))
    end
end)
