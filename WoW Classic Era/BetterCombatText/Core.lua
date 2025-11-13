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
    -- Load settings first to get maxNumbers for pool
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
    
    -- Create UI components (uses loaded settings for position/size)
    -- NOTA: Esto llama a BCT:CreateCombatLogPanel() que está en UI/CombatLog.lua
    self:CreateCombatLogPanel() 
    
    print("|cff00ff00Better Combat Text Enhanced|r loaded successfully!")
    print("|cff00ff00BCT Fix:|r Anti-freeze system activated")
    print("|cff00ff00Minimum panel size:|r 450x400 pixels for optimal text display")
end

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        BCT:OnLoad()
        
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- FIX CRÍTICO: Obtiene los argumentos y verifica si son válidos antes de llamar a Parse
        local eventArgs = {CombatLogGetCurrentEventInfo()}
        
        -- Verifica si el primer argumento (timestamp) no es nil.
        if eventArgs and eventArgs[1] then 
            local success, err = pcall(function()
                -- Llama a la función con todos los argumentos del evento
                BCT:ParseCombatEvent(unpack(eventArgs))
            end)
            if not success then
                -- Print error for better debugging (Debugging)
                print("|cffff0000BCT Error:|r Failed to parse combat event: " .. tostring(err))
            end
        end
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Combat ended, cleanup after delay
        C_Timer.After(2, function()
            BCT:CleanupAllFloatingText()
        end)
        
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Combat started, cleanup old numbers
        BCT:ForceCleanupStuckText()
        
    elseif event == "PLAYER_LOGOUT" then
        -- Save settings and cleanup (Persistencia)
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
-- DEFINICIÓN DEL SLASH COMMAND (DEBE ESTAR AQUÍ)
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
    
    -- BLOQUE MEJORADO: Maneja /bct percent, /bct percent on, y /bct percent off
    elseif cmd == "percent" or cmd == "percent on" or cmd == "percent off" then 
        local newState
        
        if cmd == "percent on" then
            newState = true
        elseif cmd == "percent off" then
            newState = false
        else 
            -- Si solo se escribió /bct percent, muestra el estado actual
            print("|cff00ff00BCT Percentage Status:|r " .. (BCT.config.showPercentages and "Enabled" or "Disabled"))
            return
        end
        
        BCT.config.showPercentages = newState
        print("|cff00ff00BCT:|r Percentage display " .. (newState and "Enabled" or "Disabled"))
        
    elseif cmd == "config" or cmd == "options" then
        BCT:ShowConfigFrame()
        
    elseif cmd == "test" then
        print("|cff00ff00BCT:|r Iniciando test de 10 segundos con todos los tipos...")
        
        local testTypes = {
            -- Daño normal
            {
                colors = BCT.Colors.damage or {1, 1, 0}, 
                size = BCT.config.fontSize, 
                isCrit = false, 
                isOverkill = false, 
                isDot = false, 
                min = 100, 
                max = 800, 
                prefix = "", 
                school = "Physical", 
                label = "Daño",
                isHealing = false
            },
            -- Daño crítico
            {
                colors = BCT.Colors.critDamage or {1, 0.5, 0}, 
                size = BCT.config.fontSize * (BCT.config.critMultiplier or 1.5), 
                isCrit = true, 
                isOverkill = false, 
                isDot = false, 
                min = 1000, 
                max = 5000, 
                prefix = "", 
                school = "Fire", 
                label = "Crítico",
                isHealing = false
            },
            -- Overkill
            {
                colors = BCT.Colors.overkill or {1, 0, 0}, 
                size = BCT.config.fontSize * (BCT.config.killBlowMultiplier or 1.8), 
                isCrit = false, 
                isOverkill = true, 
                isDot = false, 
                min = 3000, 
                max = 15000, 
                prefix = "", 
                school = "Physical", 
                label = "Overkill",
                isHealing = false
            },
            -- DoT normal
            {
                colors = BCT.Colors.dot or {0.8, 1, 0.5}, 
                size = BCT.config.fontSize * 0.8, 
                isCrit = false, 
                isOverkill = false, 
                isDot = true, 
                min = 50, 
                max = 400, 
                prefix = "", 
                school = "Nature", 
                label = "DoT",
                isHealing = false
            },
            -- Curación normal
            {
                colors = BCT.Colors.healing or {0, 1, 0}, 
                size = BCT.config.fontSize, 
                isCrit = false, 
                isOverkill = false, 
                isDot = false, 
                min = 200, 
                max = 1000, 
                prefix = "+", 
                school = "Healing", 
                label = "Curación",
                isHealing = true
            },
            -- Curación crítica
            {
                colors = BCT.Colors.critHealing or {0, 1, 0.5}, 
                size = BCT.config.fontSize * (BCT.config.critMultiplier or 1.5), 
                isCrit = true, 
                isOverkill = false, 
                isDot = false, 
                min = 800, 
                max = 3000, 
                prefix = "+", 
                school = "Healing", 
                label = "Curación Crítica",
                isHealing = true
            }
        }
        
        -- Programar 20 números
        for i = 0, 19 do
            C_Timer.After(i * 0.5, function()
                local testType = testTypes[math.random(1, #testTypes)]
                local amount = math.random(testType.min, testType.max)
                local text = testType.prefix .. BCT:FormatNumber(amount)
                
                BCT:DisplayFloatingText(
                    text,
                    testType.colors,
                    testType.size,
                    testType.isCrit,
                    testType.isOverkill,
                    testType.isDot,
                    false
                )
                
                if BCT.AddToCombatLog then
                    BCT:AddToCombatLog(
                        amount,
                        testType.school,
                        testType.isCrit,
                        testType.isOverkill,
                        testType.isHealing,
                        true 
                    )
                end
            end)
        end
        
        C_Timer.After(10, function()
            print("|cff00ff00BCT:|r Test completado! Se mostraron 20 números de 6 tipos diferentes")
        end)
        
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
        print("  |cff00ffff/bct test|r - Test de 10 segundos con todos los tipos")
        print("  |cff00ffff/bct clear|r - Clear combat log")
        print("  |cff00ffff/bct cleanup|r - Force cleanup")
        print("  |cff00ffff/bct reset|r - Reset settings")
        
    else
        print("|cffFF0000BCT:|r Unknown command. Type |cff00ffff/bct help|r")
    end
end


print("|cff00ff00Better Combat Text Enhanced|r code loaded. Ready for initialization!")