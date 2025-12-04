local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function()
    if C_PvP.IsPVPMap() then
        -- C_EquipmentSet.UseEquipmentSet("PVP")
        print("Switched to PVP Gear (Mockup)")
    end
end)
