local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_MONEY")

frame:SetScript("OnEvent", function()
    local money = GetMoney()
    print("Gold: " .. GetCoinTextureString(money))
end)
