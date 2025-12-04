local startMoney = GetMoney()
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_MONEY")

frame:SetScript("OnEvent", function()
    local currentMoney = GetMoney()
    local diff = currentMoney - startMoney
    print("Session Gold: " .. GetCoinTextureString(diff))
end)
