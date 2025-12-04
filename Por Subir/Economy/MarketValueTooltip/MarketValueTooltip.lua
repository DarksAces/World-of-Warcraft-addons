GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
    local _, link = tooltip:GetItem()
    if link then
        -- local value = GetMarketValue(link)
        tooltip:AddLine("Market Value: 100g (Mockup)")
    end
end)
