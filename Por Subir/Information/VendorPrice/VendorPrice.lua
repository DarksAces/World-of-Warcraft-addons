local function OnTooltipSetItem(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return end
    
    local price = select(11, C_Item.GetItemInfo(link))
    if price and price > 0 then
        local count = 1
        -- Try to get stack count if possible (limited in basic tooltip hook)
        -- For simplicity, we show unit price
        tooltip:AddLine("Sell Price: " .. GetCoinTextureString(price), 1, 1, 1)
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
