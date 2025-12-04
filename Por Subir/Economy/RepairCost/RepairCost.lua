local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")

frame:SetScript("OnEvent", function()
    local cost, canRepair = GetRepairAllCost()
    if canRepair then
        print("Repair Cost: " .. GetCoinTextureString(cost))
    end
end)
