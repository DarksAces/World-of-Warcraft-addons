GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
    local _, link = tooltip:GetItem()
    if link then
        local count = GetItemCount(link)
        tooltip:AddLine("Count: " .. count)
    end
end)
