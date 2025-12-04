local function OnTooltipSetSpell(tooltip)
    local _, id = tooltip:GetSpell()
    if id then
        tooltip:AddLine("Spell ID: " .. id, 1, 1, 1)
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnTooltipSetSpell)
