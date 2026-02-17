-- Core.lua - Main addon initialization and event handling
local addonName = "BetterCombatText"

-- Ensure global namespace exists and get reference
if not _G[addonName] then
    _G[addonName] = {}
end
local BCT = _G[addonName]

-- Create event frame (separate from BCT namespace)
local eventFrame = CreateFrame("Frame", addonName .. "EventFrame")
BCT.eventFrame = eventFrame

-- Cleanup timer
local cleanupTimer = nil

-- Initialize addon
function BCT:OnLoad()
    -- Load settings first
    self:LoadSettings()
    
    -- Initialize text pool
    self:InitializeTextPool()
    
    -- Initialize auto-cleanup system
    if cleanupTimer then
        cleanupTimer:Cancel()
    end
    cleanupTimer = C_Timer.NewTicker(5, function()
        BCT:ForceCleanupStuckText()
    end)
    
    -- Create UI components
    self:CreateCombatLogPanel() 
    
    print("|cff00ff00Better Combat Text Enhanced|r loaded successfully!")
    print("|cff00ff00BCT Fix:|r Beta/11.0 Compatibility Mode Active")
end

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        BCT:OnLoad()
        
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- FIX CRÍTICO PARA BETA/11.0+:
        -- Eliminado 'pcall' y el empaquetado de tablas {...}
        -- Esto evita el error de "Blocked Action" o Taint al leer el combat log
        BCT:ParseCombatEvent(CombatLogGetCurrentEventInfo())
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Combat ended, cleanup after delay
        C_Timer.After(2, function()
            BCT:CleanupAllFloatingText()
        end)
        
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Combat started, cleanup old numbers
        BCT:ForceCleanupStuckText()
        
    elseif event == "PLAYER_LOGOUT" then
        -- Save settings and cleanup
        BCT:SaveSettings()
        BCT:CleanupAllFloatingText()
        if cleanupTimer then
            cleanupTimer:Cancel()
        end
    end
end)

-- Register events
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

-- =============================================================
-- DEFINICIÓN DEL SLASH COMMAND
-- =============================================================
SLASH_BCT1 = "/bct"
SLASH_BCT2 = "/bettercombattext"
SlashCmdList["BCT"] = function(msg)
    local cmd = string.lower(msg or "")
    
    if cmd == "toggle" then
        BCT.config.enabled = not BCT.config.enabled
        print("|cff00ff00BCT:|r " .. (BCT.config.enabled and "Enabled" or "Disabled"))
        
    elseif cmd == "panel" or cmd == "log" then
        BCT:ToggleCombatLogPanel()
    
    -- NOTA: Se han eliminado los comandos "percent" como se solicitó
        
    elseif cmd == "config" or cmd == "options" then
        BCT:ShowConfigFrame()
        
    elseif cmd == "test" then
        print("|cff00ff00BCT:|r Iniciando test rápido...")
        
        local amount = math.random(1000, 5000)
        local text = BCT:FormatNumber(amount)
        
        -- Test seguro
        BCT:DisplayFloatingText(
            text,
            {1, 1, 0, 1}, -- Amarillo
            BCT.config.fontSize,
            true, -- Crítico para probar animación
            false,
            false,
            false
        )
        
    elseif cmd == "clear" then
        BCT.combatLogData = {}
        BCT:CleanupAllFloatingText()
        if BCT.combatLogFrame then BCT:UpdateCombatLogDisplay() end
        print("|cff00ff00BCT:|r Combat log cleared")
        
    elseif cmd == "cleanup" or cmd == "clean" then
        BCT:CleanupAllFloatingText()
        BCT:ForceCleanupStuckText()
        print("|cff00ff00BCT:|r Forced cleanup completed")
        
    elseif cmd == "reset" then
        BCT:ResetSettings()
        
    elseif cmd == "help" or cmd == "" then
        print("|cff00ff00Better Combat Text Enhanced|r - Commands:")
        print("  |cff00ffff/bct toggle|r - Enable/disable addon")
        print("  |cff00ffff/bct panel|r - Toggle combat log")
        print("  |cff00ffff/bct config|r - Open configuration")
        print("  |cff00ffff/bct test|r - Test de un número")
        print("  |cff00ffff/bct clear|r - Clear combat log")
        print("  |cff00ffff/bct cleanup|r - Force cleanup")
        print("  |cff00ffff/bct reset|r - Reset settings")
        
    else
        print("|cffFF0000BCT:|r Unknown command. Type |cff00ffff/bct help|r")
    end
end

print("|cff00ff00Better Combat Text Enhanced|r code loaded. Ready!")