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
        self:ShowDamageText(amount, critical, school, overkill > 0, sourceGUID == playerGUID)
        
    elseif subevent == "SPELL_HEAL" then
        local spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = select(12, ...)
        if destGUID == playerGUID or sourceGUID == playerGUID then
            self:ShowHealingText(amount, critical, overhealing > 0)
        end
        
    elseif subevent == "SPELL_PERIODIC_DAMAGE" then
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical = select(12, ...)
        self:ShowPeriodicDamageText(amount, critical, school, sourceGUID == playerGUID)
        
    elseif subevent == "SPELL_PERIODIC_HEAL" then
        local spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = select(12, ...)
        if destGUID == playerGUID or sourceGUID == playerGUID then
            self:ShowPeriodicHealingText(amount, critical) 
        end
    end
end

-- Show damage text (APLICANDO FILTRO DE ESCUELA)
function BCT:ShowDamageText(amount, isCrit, school, isOverkill, isOutgoing)
    if not self.config.showDamage or not amount then return end
    
    local schoolName = self:GetSchoolName(school)
    -- *** FILTRADO ***
    if not self.config["filter_" .. schoolName] then return end
    
    local color = self:GetDamageColor(school, isCrit, isOverkill, isOutgoing)
    
    -- CORRECCIÓN CRÍTICA: Asegurar un color válido si GetDamageColor devuelve nil.
    if not color then 
        color = self.Colors and self.Colors.damage or {1, 1, 0, 1}
    end
    
    local size = self.config.fontSize
    
    if isCrit then size = size * self.config.critMultiplier end
    if isOverkill then size = size * self.config.killBlowMultiplier end
    
    local damageType = schoolName
    self:AddToCombatLog(amount, damageType, isCrit, isOverkill, false, isOutgoing)
    
    if self:ShouldGroup(amount, isOutgoing) then
        -- Asumiendo que ShouldGroup está corregido para manejar la lógica de visualización
        -- Si devuelve true, se acumuló/mostró el grupo, así que salimos.
        return
    else
        self:DisplayFloatingText(self:FormatNumber(amount), color, size, isCrit, isOverkill)
    end
end

-- Show healing text (APLICANDO FILTRO DE CURACIÓN DIRECTA)
function BCT:ShowHealingText(amount, isCrit, isOverheal)
    if not self.config.showHealing or not amount then return end
    
    -- *** FILTRADO ***
    if not self.config.filter_DirectHealing then return end
    
    local color = isCrit and self.Colors.critHealing or self.Colors.healing
    
    local size = self.config.fontSize
    
    if isCrit then size = size * self.config.critMultiplier end
    
    self:AddToCombatLog(amount, "Healing", isCrit, false, true, true)
    
    local text = "+" .. self:FormatNumber(amount)
    if isOverheal then text = text .. "*" end
    
    self:DisplayFloatingText(text, color, size, isCrit, false)
end

-- Show periodic damage text (APLICANDO FILTRO DoT)
function BCT:ShowPeriodicDamageText(amount, isCrit, school, isOutgoing)
    if not self.config.showDamage or not amount then return end
    
    -- *** FILTRADO ***
    if not self.config.filter_DoT then return end 
    
    local color = self:GetDamageColor(school, isCrit, false, isOutgoing)
    
    -- CORRECCIÓN CRÍTICA: Asegurar un color válido si GetDamageColor devuelve nil.
    if not color then 
        color = self.Colors and self.Colors.dot or {0.8, 1, 0.5, 1}
    end
    
    local size = self.config.fontSize * 0.8
    
    -- Added to Combat Log (Fix: Se añade al log)
    self:AddToCombatLog(amount, "Periodic", isCrit, false, false, isOutgoing)
    
    self:DisplayFloatingText(self:FormatNumber(amount), color, size, false, false, true)
end

-- Show periodic healing text (APLICANDO FILTRO HoT)
function BCT:ShowPeriodicHealingText(amount, isCrit)
    if not self.config.showHealing or not amount then return end
    
    -- *** FILTRADO ***
    if not self.config.filter_HoT then return end
    
    -- Los colores hot y critHot no están definidos en Colors.lua, 
    -- usamos colores de fallback seguros para evitar nil.
    local color = isCrit and (self.Colors.critHot or self.Colors.critHealing) or (self.Colors.hot or self.Colors.healing)
    local size = self.config.fontSize * 0.8
    
    self:AddToCombatLog(amount, "HoT", isCrit, false, true, true)
    
    local text = "+" .. self:FormatNumber(amount)
    
    self:DisplayFloatingText(text, color, size, isCrit, false, true)
end