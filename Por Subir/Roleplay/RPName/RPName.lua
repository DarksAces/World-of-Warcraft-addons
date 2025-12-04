-- Mockup: Would normally save/load names
local function OnTooltipSetUnit(tooltip)
    local _, unit = tooltip:GetUnit()
    if not unit then return end
    if UnitIsPlayer(unit) then
        tooltip:AddLine("RP Name: " .. UnitName(unit), 1, 0.8, 0)
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
