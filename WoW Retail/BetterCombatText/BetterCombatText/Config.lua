-- Config.lua - Configuration and settings for BCT
local addonName = "BetterCombatText"

-- Ensure global namespace exists
if not _G[addonName] then
    _G[addonName] = {}
end
local BCT = _G[addonName]

-- Default configuration
BCT.defaults = {
    enabled = true,
    showDamage = true,
    showHealing = true,
    showPvP = true,
    animationSpeed = 1.2,
    fontSize = 16,
    critMultiplier = 1.5,
    killBlowMultiplier = 2.0,
    fadeTime = 1.5,
    maxNumbers = 20,
    groupingThreshold = 5,
    groupingTime = 2.0,
    textScale = 1.0, -- Default value for scale
    showBackground = true,
    theme = "dark",
    opacity = 0.85,
    soundEnabled = true,
    showIcons = true,
    compactMode = false,
    autoHide = false,
    autoHideDelay = 5.0,
    -- Added defaults for combat log frame position/size (Persistencia)
    logPanelX = 0,
    logPanelY = 0,
    logPanelW = 500,
    logPanelH = 650,
    
    -- NUEVOS DEFAULTS PARA FILTROS AVANZADOS (Todos true por defecto)
    filter_Physical = true,
    filter_Holy = true,
    filter_Fire = true,
    filter_Nature = true,
    filter_Frost = true,
    filter_Shadow = true,
    filter_Arcane = true, -- Aunque Arcane no está en GetSchoolName, se añade por completitud.
    filter_DoT = true,        -- Daño periódico
    filter_HoT = true,        -- Curación periódica
    filter_DirectHealing = true -- Curación directa
    -- FIN NUEVOS DEFAULTS
}

-- Initialize config with defaults
BCT.config = BCT.config or {}
for k, v in pairs(BCT.defaults) do
    if BCT.config[k] == nil then
        BCT.config[k] = v
    end
end

-- Load saved settings
function BCT:LoadSettings()
    if BCT_SavedSettings then
        for key, value in pairs(BCT_SavedSettings) do
            if self.config[key] ~= nil then
                self.config[key] = value
            end
        end
        print("|cff00ff00BCT:|r Settings loaded")
    end
end

-- Save settings
function BCT:SaveSettings()
    BCT_SavedSettings = {}
    for key, value in pairs(self.config) do
        BCT_SavedSettings[key] = value
    end
end

-- Reset to defaults
function BCT:ResetSettings()
    for k, v in pairs(self.defaults) do
        self.config[k] = v
    end
    print("|cff00ff00BCT:|r Settings reset to defaults")
end