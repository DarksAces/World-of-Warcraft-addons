-- Parser.lua - Combat log event parsing and processing
local addonName = "BetterCombatText"

-- Ensure global namespace exists
if not _G[addonName] then
    _G[addonName] = {}
end
local BCT = _G[addonName]

-- Parse combat events
function BCT:ParseCombatEvent(...)
    if not self.config.enabled then return end
    
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags = ...
    
    local playerGUID = UnitGUID("player")
    
    if not playerGUID or not (sourceGUID == playerGUID or destGUID == playerGUID) then
        return
    end
    
    if subevent == "SWING_DAMAGE" then
        local amount, overkill, school, resisted, blocked, absorbed, critical = select(12, ...)
        self:ShowDamageText(amount, critical, school, overkill > 0, sourceGUID == playerGUID)
        
    elseif subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical = select(12, ...)
        self:ShowDamageText(amount, critical, spellSchool, overkill > 0, sourceGUID == playerGUID)
        
    elseif subevent == "SPELL_HEAL" then
        local spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = select(12, ...)
        if destGUID == playerGUID or sourceGUID == playerGUID then
            self:ShowHealingText(amount, critical, overhealing > 0)
        end
        
    elseif subevent == "SPELL_PERIODIC_DAMAGE" then
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical = select(12, ...)
        self:ShowPeriodicDamageText(amount, critical, spellSchool, sourceGUID == playerGUID)
    end
end

-- Show damage text
function BCT:ShowDamageText(amount, isCrit, school, isOverkill, isOutgoing)
    if not self.config.showDamage or not amount then return end
    
    local color = self:GetDamageColor(school, isCrit, isOverkill, isOutgoing)
    local size = self.config.fontSize
    
    if isCrit then size = size * self.config.critMultiplier end
    if isOverkill then size = size * self.config.killBlowMultiplier end
    
    local damageType = self:GetSchoolName(school)
    self:AddToCombatLog(amount, damageType, isCrit, isOverkill, false, isOutgoing)
    
    if self:ShouldGroup(amount, isOutgoing) then
        self:AddToGroup(amount, color, size, isOutgoing)
    else
        self:DisplayFloatingText(self:FormatNumber(amount), color, size, isCrit, isOverkill)
    end
end

-- Show healing text
function BCT:ShowHealingText(amount, isCrit, isOverheal)
    if not self.config.showHealing or not amount then return end
    
    local color = isCrit and self.Colors.critHealing or self.Colors.healing
    local size = self.config.fontSize
    
    if isCrit then size = size * self.config.critMultiplier end
    
    self:AddToCombatLog(amount, "Healing", isCrit, false, true, true)
    
    local text = "+" .. self:FormatNumber(amount)
    if isOverheal then text = text .. "*" end
    
    self:DisplayFloatingText(text, color, size, isCrit, false)
end

-- Show periodic damage text
function BCT:ShowPeriodicDamageText(amount, isCrit, school, isOutgoing)
    if not self.config.showDamage or not amount then return end
    
    local color = self:GetDamageColor(school, isCrit, false, isOutgoing)
    local size = self.config.fontSize * 0.8
    
    self:DisplayFloatingText(self:FormatNumber(amount), color, size, false, false, true)
end