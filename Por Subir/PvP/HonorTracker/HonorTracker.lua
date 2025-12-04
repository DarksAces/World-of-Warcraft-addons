local frame = CreateFrame("Frame")
frame:RegisterEvent("HONOR_XP_UPDATE")

frame:SetScript("OnEvent", function()
    local current = UnitHonor("player")
    local max = UnitHonorMax("player")
    print("Honor: " .. current .. "/" .. max)
end)
