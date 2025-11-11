-- GroupManager.lua - Damage grouping and aggregation system
local addonName = "BetterCombatText"

-- Ensure global namespace exists
if not _G[addonName] then
    _G[addonName] = {}
end
local BCT = _G[addonName]

BCT.damageGroups = {}

-- Check if damage should be grouped
function BCT:ShouldGroup(amount, isOutgoing)
    local now = GetTime()
    local key = isOutgoing and "out" or "in"
    
    if not self.damageGroups[key] then
        self.damageGroups[key] = {total = 0, count = 0, lastTime = now}
        return false
    end
    
    local group = self.damageGroups[key]
    
    -- Si el tiempo de agrupación ha expirado, reinicia el grupo con el hit actual
    if (now - group.lastTime) > self.config.groupingTime then
        group.total = amount
        group.count = 1
        group.lastTime = now
        return false
    else
        -- Si no ha expirado el tiempo, suma el hit actual
        group.total = group.total + amount
        group.count = group.count + 1
        group.lastTime = now -- Actualiza el tiempo del último hit
        
        -- Si se alcanza el umbral, se muestra el grupo
        return group.count >= self.config.groupingThreshold
    end
end

-- Add to group
function BCT:AddToGroup(amount, color, size, isOutgoing)
    local key = isOutgoing and "out" or "in"
    local group = self.damageGroups[key]
    
    -- El total y count ya fueron actualizados en ShouldGroup
    
    local text = self:FormatNumber(group.total) .. " (" .. group.count .. ")"
    self:DisplayFloatingText(text, color, size, false, false, false, true)
    
    -- IMPORTANTE: Reiniciar el grupo después de mostrar el número acumulado (Fix)
    group.total = 0
    group.count = 0
    group.lastTime = GetTime()
end

-- Reset damage groups
function BCT:ResetDamageGroups()
    self.damageGroups = {}
end