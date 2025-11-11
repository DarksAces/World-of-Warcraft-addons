-- GroupManager.lua - Damage grouping and aggregation system
local addonName = "BetterCombatText"

-- Ensure global namespace exists
if not _G[addonName] then
    _G[addonName] = {}
end
local BCT = _G[addonName]

BCT.damageGroups = BCT.damageGroups or {} -- Asegurar inicialización

-- Función auxiliar para mostrar el grupo acumulado
local function DisplayGroup(key)
    local group = BCT.damageGroups[key]
    if group and group.count > 0 then
        -- Determinamos los parámetros del hit más reciente (esto es un compromiso, ya que el color/tamaño 
        -- podría variar ligeramente, pero usamos los últimos conocidos para la visualización del grupo).
        local amount = group.total
        local isOutgoing = (key == "out")
        
        -- Si no tenemos el color, usamos uno por defecto de daño
        local color = group.lastColor or BCT.Colors.damage or {1, 1, 0}
        local size = group.lastSize or BCT.config.fontSize
        
        local text = BCT:FormatNumber(amount) .. " (" .. group.count .. ")"
        BCT:DisplayFloatingText(text, color, size, false, false, false, true)
        
        -- Reiniciar el grupo después de la visualización
        group.total = 0
        group.count = 0
        -- NOTA: group.lastTime NO se actualiza aquí, se actualiza en ShouldGroup cuando llega el nuevo hit.
        
        print("|cff00ff00BCT Group:|r Grupo mostrado por umbral o expiración. Daño total: " .. amount)
    end
end

-- Check if damage should be grouped (FIX aplicado)
function BCT:ShouldGroup(amount, color, size, isOutgoing) -- Añadir color y size como argumentos
    local now = GetTime()
    local key = isOutgoing and "out" or "in"
    
    if not self.damageGroups[key] then
        self.damageGroups[key] = {total = 0, count = 0, lastTime = now, lastColor = color, lastSize = size}
        return false -- Primer hit, no agrupar
    end
    
    local group = self.damageGroups[key]
    local groupingTime = self.config.groupingTime or 2.0
    
    -- 1. EXPIRACIÓN: Si el tiempo de agrupación ha expirado
    if (now - group.lastTime) > groupingTime then
        
        -- Si hay daño acumulado (que no alcanzó el umbral), lo mostramos antes de resetear
        if group.count > 0 then
            DisplayGroup(key) 
        end
        
        -- Reinicia el grupo con el hit actual
        group.total = amount
        group.count = 1
        group.lastTime = now
        group.lastColor = color
        group.lastSize = size
        return false -- El primer hit de un nuevo grupo siempre es flotante
    end
    
    -- 2. ACUMULACIÓN: Si no ha expirado el tiempo
    group.total = group.total + amount
    group.count = group.count + 1
    group.lastTime = now -- Actualiza el tiempo del último hit
    group.lastColor = color -- Actualiza color/tamaño para el eventual DisplayGroup
    group.lastSize = size
    
    -- 3. UMBRAL ALCANZADO: Si se alcanza el umbral, se muestra y se reinicia el contador de ese grupo.
    if group.count >= (self.config.groupingThreshold or 5) then
        DisplayGroup(key)
        return true -- Indica que el número agrupado fue mostrado
    end
    
    return true -- Se acumuló, no mostrar número flotante individual
end

-- Add to group: La lógica de agrupamiento y display ahora está en ShouldGroup.
-- Esta función ya no es necesaria con la lógica corregida.
function BCT:AddToGroup(amount, color, size, isOutgoing)
    -- Esta función ahora está obsoleta. 
    -- La llamada a DisplayFloatingText y el reseteo del grupo se manejan en BCT:ShouldGroup.
    -- La llamaremos para evitar errores hasta que Parser.lua sea corregido, pero no hará nada.
end

-- Reset damage groups
function BCT:ResetDamageGroups()
    self.damageGroups = {}
end