local frame = CreateFrame("Frame")
frame:RegisterEvent("HONOR_LEVEL_UPDATE")

frame:SetScript("OnEvent", function()
    local level = UnitHonorLevel("player")
    print("Honor Level: " .. level)
end)
