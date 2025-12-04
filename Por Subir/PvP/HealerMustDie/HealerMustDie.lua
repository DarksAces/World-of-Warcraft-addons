local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")

frame:SetScript("OnEvent", function(self, event, unit)
    -- Check if unit is a healer role
    -- Set raid target icon to Skull
    print("Healer detected! (Mockup)")
end)
