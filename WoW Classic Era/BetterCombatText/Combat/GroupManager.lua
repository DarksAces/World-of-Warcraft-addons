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
    if (now - group.lastTime) > self.config.groupingTime then
        group.total = amount
        group.count = 1
        group.lastTime = now
        return false
    else
        group.count = group.count + 1
        return group.count >= self.config.groupingThreshold
    end
end

-- Add to group
function BCT:AddToGroup(amount, color, size, isOutgoing)
    local key = isOutgoing and "out" or "in"
    local group = self.damageGroups[key]
    group.total = group.total + amount
    group.lastTime = GetTime()
    
    local text = self:FormatNumber(group.total) .. " (" .. group.count .. ")"
    self:DisplayFloatingText(text, color, size, false, false, false, true)
end

-- Reset damage groups
function BCT:ResetDamageGroups()
    self.damageGroups = {}
end