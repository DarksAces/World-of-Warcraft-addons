local Module = NexusCommand:NewModule("Economy")

function Module:OnEnable()
    self:RegisterEvent("PLAYER_MONEY")
    self.startMoney = GetMoney()
    print("NexusCommand: Economy Module Enabled")
end

function Module:RegisterEvent(event)
    local f = CreateFrame("Frame")
    f:RegisterEvent(event)
    f:SetScript("OnEvent", function() Module:UpdateMoney() end)
end

function Module:UpdateMoney()
    local current = GetMoney()
    local diff = current - self.startMoney
    
    -- Record history
    table.insert(NexusDB.profile.economy.history, {
        time = time(),
        amount = current
    })
    
    if diff > 0 then
        print("NexusEconomy: Profit +" .. GetCoinTextureString(diff))
    elseif diff < 0 then
        print("NexusEconomy: Loss " .. GetCoinTextureString(math.abs(diff)))
    end
end
