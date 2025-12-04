local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_AURA")

frame:SetScript("OnEvent", function(self, event, unit)
    if unit == "target" then
        -- Track my DoTs on target
    end
end)
