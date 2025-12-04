local Module = NexusCommand:NewModule("TacticalMap")

function Module:OnEnable()
    self.frame = CreateFrame("Frame", "NexusMapFrame", UIParent)
    self.frame:SetSize(200, 200)
    self.frame:SetPoint("TOPRIGHT", -20, -20)
    
    self.bg = self.frame:CreateTexture(nil, "BACKGROUND")
    self.bg:SetAllPoints()
    self.bg:SetColorTexture(0, 0, 0, 0.8)
    
    self.playerDot = self.frame:CreateTexture(nil, "OVERLAY")
    self.playerDot:SetSize(10, 10)
    self.playerDot:SetPoint("CENTER")
    self.playerDot:SetColorTexture(1, 1, 1, 1)
    
    self.frame:SetScript("OnUpdate", function()
        -- Radar logic: Render dots for party members relative to player
        -- Mockup: Just spinning a dot around
        local t = GetTime()
        local x = math.cos(t) * 50
        local y = math.sin(t) * 50
        
        if not self.targetDot then
            self.targetDot = self.frame:CreateTexture(nil, "OVERLAY")
            self.targetDot:SetSize(8, 8)
            self.targetDot:SetColorTexture(1, 0, 0, 1)
        end
        self.targetDot:SetPoint("CENTER", x, y)
    end)
    
    print("NexusCommand: Tactical Map Module Enabled")
end
