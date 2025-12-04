local function OnTooltipSetItem(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return end
    
    local ilvl = C_Item.GetDetailedItemLevelInfo(link)
    if ilvl then
        tooltip:AddLine("iLvl: " .. ilvl, 1, 0.8, 0)
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
