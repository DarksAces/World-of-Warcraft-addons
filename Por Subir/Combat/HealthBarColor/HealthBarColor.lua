local function ColorHealthBar(bar, unit)
    if unit and UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if class then
            local color = RAID_CLASS_COLORS[class]
            bar:SetStatusBarColor(color.r, color.g, color.b)
        end
    end
end

hooksecurefunc("UnitFrameHealthBar_Update", function(self, unit)
    ColorHealthBar(self, unit)
end)

hooksecurefunc("HealthBar_OnValueChanged", function(self)
    if self.unit then
        ColorHealthBar(self, self.unit)
    end
end)
