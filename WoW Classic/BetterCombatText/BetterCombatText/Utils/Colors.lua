-- Colors.lua - Color definitions and themes for BCT
local addonName = "BetterCombatText"

-- Ensure global namespace exists
if not _G[addonName] then
    _G[addonName] = {}
end
local BCT = _G[addonName]

-- Color definitions
BCT.Colors = {
    damage = {1, 1, 0, 1},
    critDamage = {1, 0.5, 0, 1},
    healing = {0, 1, 0, 1},
    critHealing = {0, 1, 0.5, 1},
    -- NUEVOS COLORES PARA HEALING OVER TIME (HoT)
    hot = {0.2, 0.8, 0.2, 1},
    critHot = {0.4, 1, 0.4, 1},
    -- Fin NUEVOS COLORES
    damageTaken = {1, 0, 0, 1},
    physical = {1, 0.8, 0.4, 1},
    magic = {0.4, 0.8, 1, 1},
    fire = {1, 0.2, 0.2, 1},
    frost = {0.5, 0.8, 1, 1},
    nature = {0.3, 1, 0.3, 1},
    shadow = {0.7, 0.3, 1, 1},
    holy = {1, 1, 0.8, 1},
    pvpDamage = {1, 0.3, 0.3, 1},
    overkill = {1, 0, 1, 1}
}

-- Theme definitions
BCT.Themes = {
    dark = {
        background = {0, 0, 0, 0.85},
        border = {0.3, 0.3, 0.3, 1},
        title = {1, 1, 1, 1},
        text = {0.9, 0.9, 0.9, 1},
        accent = {0.2, 0.6, 1, 1}
    },
    light = {
        background = {0.95, 0.95, 0.95, 0.9},
        border = {0.6, 0.6, 0.6, 1},
        title = {0.1, 0.1, 0.1, 1},
        text = {0.2, 0.2, 0.2, 1},
        accent = {0.1, 0.4, 0.8, 1}
    },
    custom = {
        background = {0.1, 0.1, 0.2, 0.8},
        border = {0.4, 0.2, 0.6, 1},
        title = {0.8, 0.6, 1, 1},
        text = {0.9, 0.8, 1, 1},
        accent = {0.6, 0.3, 0.9, 1}
    }
}

-- Get damage color based on school and conditions
-- Colors.lua (Función GetDamageColor CORREGIDA)

-- Get damage color based on school and conditions
function BCT:GetDamageColor(school, isCrit, isOverkill, isOutgoing)
    local defaultColor = self.Colors and self.Colors.damage or {1, 1, 0, 1} -- Color de fallback

    if isOverkill then 
        return self.Colors.overkill or defaultColor 
    end
    
    local inPvP = UnitIsPVP and UnitIsPVP("player") or false -- Usando UnitIsPVP de WoW API
    if inPvP and self.config.showPvP then 
        return self.Colors.pvpDamage or defaultColor 
    end
    
    local color
    
    if school == 1 then color = self.Colors.physical
    elseif school == 2 then color = self.Colors.holy
    elseif school == 4 then color = self.Colors.fire
    elseif school == 8 then color = self.Colors.nature
    elseif school == 16 then color = self.Colors.frost
    elseif school == 32 then color = self.Colors.shadow
    else
        -- Si el school es desconocido, usa crítico o normal
        color = isCrit and self.Colors.critDamage or self.Colors.damage
    end
    
    -- RETORNO FINAL: Asegura que el valor final nunca sea nil.
    return color or defaultColor
end

-- Get school name from ID
function BCT:GetSchoolName(school)
    if school == 1 then return "Physical"
    elseif school == 2 then return "Holy"
    elseif school == 4 then return "Fire"
    elseif school == 8 then return "Nature"
    elseif school == 16 then return "Frost"
    elseif school == 32 then return "Shadow"
    elseif school == 64 then return "Arcane"
    else return "Magic"
    end
end