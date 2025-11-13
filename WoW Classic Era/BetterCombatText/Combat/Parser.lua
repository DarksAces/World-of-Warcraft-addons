-- Parser.lua - Combat log event parsing and processing
local addonName = "BetterCombatText"

-- Ensure global namespace exists
if not _G[addonName] then
    _G[addonName] = {}
end
local BCT = _G[addonName]

-- Obtiene el porcentaje de salud/poder de un GUID
local function GetUnitPercentage(guid)
    if not guid then return "" end

    local unit 
    if guid == UnitGUID("player") then
        unit = "player"
    elseif UnitGUID("target") == guid then
        unit = "target"
    else
        return ""
    end
    
    -- Usar UnitHealth y UnitHealthMax para obtener la vida
    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)
    
    if health and healthMax and healthMax > 0 then
        local percent = math.floor((health / healthMax) * 100)
        return " (" .. percent .. "%)"
    end
    return ""
end


-- Parse combat events
function BCT:ParseCombatEvent(...)
    if not self.config.enabled then return end
    
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags = select(1, ...)
    
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
        
    elseif subevent == "SPELL_PERIODIC_HEAL" then
        local spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = select(12, ...)
        if destGUID == playerGUID or sourceGUID == playerGUID then
            self:ShowPeriodicHealingText(amount, critical) -- Nueva función para HoT
        end
    end
end

-- Show damage text (FIX aplicado)
function BCT:ShowDamageText(amount, isCrit, school, isOverkill, isOutgoing)
    if not self.config.showDamage or not amount then return end
    
    local color = self:GetDamageColor(school, isCrit, isOverkill, isOutgoing)
    
    -- CORRECCIÓN CRÍTICA: Asegurar un color válido si GetDamageColor devuelve nil.
    if not color then 
        color = self.Colors and self.Colors.damage or {1, 1, 0, 1}
    end
    
    local size = self.config.fontSize
    
    if isCrit then size = size * self.config.critMultiplier end
    if isOverkill then size = size * self.config.killBlowMultiplier end
    
    local damageType = self:GetSchoolName(school)
    self:AddToCombatLog(amount, damageType, isCrit, isOverkill, false, isOutgoing)
    
    -- LÓGICA DE PORCENTAJE (NUEVO)
    local percentageText = ""
    if BCT.config.showPercentages then
        -- Usar target para daño saliente, player para daño entrante
        local unitGuid = isOutgoing and UnitGUID("target") or UnitGUID("player")
        percentageText = GetUnitPercentage(unitGuid) 
    end
    
    local text = self:FormatNumber(amount) .. percentageText -- <--- ¡TEXTO MODIFICADO!
    
    if self:ShouldGroup(amount, isOutgoing) then
        self:AddToGroup(amount, color, size, isOutgoing)
    else
        self:DisplayFloatingText(text, color, size, isCrit, isOverkill)
    end
end

-- Show healing text
function BCT:ShowHealingText(amount, isCrit, isOverheal)
    if not self.config.showHealing or not amount then return end
    
    local color = isCrit and self.Colors.critHealing or self.Colors.healing
    
    local size = self.config.fontSize
    
    if isCrit then size = size * self.config.critMultiplier end
    
    self:AddToCombatLog(amount, "Healing", isCrit, false, true, true)
    
    -- LÓGICA DE PORCENTAJE (NUEVO)
    local percentageText = ""
    if BCT.config.showPercentages then
        percentageText = GetUnitPercentage(UnitGUID("player")) -- Curación siempre va al jugador
    end
    
    local text = "+" .. self:FormatNumber(amount) .. percentageText
    if isOverheal then text = text .. "*" end
    
    self:DisplayFloatingText(text, color, size, isCrit, false)
end

-- Show periodic damage text (FIX aplicado)
function BCT:ShowPeriodicDamageText(amount, isCrit, school, isOutgoing)
    if not self.config.showDamage or not amount then return end
    
    local color = self:GetDamageColor(school, isCrit, false, isOutgoing)
    
    -- CORRECCIÓN CRÍTICA: Asegurar un color válido si GetDamageColor devuelve nil.
    if not color then 
        color = self.Colors and self.Colors.dot or {0.8, 1, 0.5, 1}
    end
    
    local size = self.config.fontSize * 0.8
    
    -- Added to Combat Log (Fix: Se añade al log)
    self:AddToCombatLog(amount, "Periodic", isCrit, false, false, isOutgoing)

    -- LÓGICA DE PORCENTAJE (NUEVO)
    local percentageText = ""
    if BCT.config.showPercentages then
        -- Usar target para daño saliente, player para daño entrante
        local unitGuid = isOutgoing and UnitGUID("target") or UnitGUID("player")
        percentageText = GetUnitPercentage(unitGuid) 
    end
    
    local text = self:FormatNumber(amount) .. percentageText
    
    self:DisplayFloatingText(text, color, size, false, false, true)
end

-- Show periodic healing text (NEW)
function BCT:ShowPeriodicHealingText(amount, isCrit)
    if not self.config.showHealing or not amount then return end
    
    -- Los colores hot y critHot no están definidos en Colors.lua, 
    -- usamos colores de fallback seguros para evitar nil.
    local color = isCrit and (self.Colors.critHot or self.Colors.critHealing) or (self.Colors.hot or self.Colors.healing)
    local size = self.config.fontSize * 0.8
    
    self:AddToCombatLog(amount, "HoT", isCrit, false, true, true)
    
    -- LÓGICA DE PORCENTAJE (NUEVO)
    local percentageText = ""
    if BCT.config.showPercentages then
        percentageText = GetUnitPercentage(UnitGUID("player")) -- Curación HoT siempre va al jugador
    end

    local text = "+" .. self:FormatNumber(amount) .. percentageText
    
    self:DisplayFloatingText(text, color, size, isCrit, false, true)
end