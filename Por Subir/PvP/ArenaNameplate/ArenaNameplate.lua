local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")

frame:SetScript("OnEvent", function(self, event, unit)
    if C_PvP.IsArena() then
        -- Add arena number to nameplate
        print("Arena Nameplate: " .. UnitName(unit))
    end
end)
