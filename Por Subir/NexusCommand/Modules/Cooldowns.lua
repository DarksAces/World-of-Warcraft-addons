local Module = NexusCommand:NewModule("Cooldowns")

function Module:OnEnable()
    self.frame = CreateFrame("Frame", "NexusCooldownsFrame", UIParent)
    self.frame:SetSize(300, 30)
    self.frame:SetPoint("TOP", 0, -50)
    
    self.bg = self.frame:CreateTexture(nil, "BACKGROUND")
    self.bg:SetAllPoints()
    self.bg:SetColorTexture(0, 0, 0, 0.5)
    
    self.text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.text:SetPoint("CENTER")
    self.text:SetText("Raid Cooldown Timeline")
    
    local f = CreateFrame("Frame")
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    f:SetScript("OnEvent", function()
        local _, event, _, _, _, _, _, _, _, _, _, spellId = CombatLogGetCurrentEventInfo()
        if event == "SPELL_CAST_SUCCESS" then
            if spellId == 2825 or spellId == 32182 then -- Bloodlust / Heroism
                self.text:SetText("MAJOR CD USED: " .. spellId)
                self.bg:SetColorTexture(1, 0, 0, 0.8)
                C_Timer.After(5, function() self.bg:SetColorTexture(0, 0, 0, 0.5) end)
            end
        end
    end)
    
    print("NexusCommand: Cooldowns Module Enabled")
end
