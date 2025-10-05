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
    
    -- Load settings
    self:LoadSettings()
    
    print("|cff00ff00Better Combat Text Enhanced|r loaded successfully!")
    print("|cff00ff00BCT Fix:|r Anti-freeze system activated")
    print("|cff00ff00Minimum panel size:|r 450x400 pixels for optimal text display")
end

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        BCT:OnLoad()
        
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local success, err = pcall(function()
            BCT:ParseCombatEvent(CombatLogGetCurrentEventInfo())
        end)
        if not success then
            -- Silently handle errors
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

-- Slash commands
SLASH_BCT1 = "/bct"
SLASH_BCT2 = "/bettercombattext"
SlashCmdList["BCT"] = function(msg)
    local cmd = string.lower(msg or "")
    
    if cmd == "toggle" then
        BCT.config.enabled = not BCT.config.enabled
        print("|cff00ff00BCT:|r " .. (BCT.config.enabled and "Enabled" or "Disabled"))
        
    elseif cmd == "panel" or cmd == "log" then
        BCT:ToggleCombatLogPanel()
        
    elseif cmd == "config" or cmd == "options" then
        BCT:ShowConfigFrame()
        
    elseif cmd == "test" then
        print("|cff00ff00BCT:|r Iniciando test de 10 segundos con todos los tipos...")
        
        -- Tabla con todos los tipos de daño/curación disponibles
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
                label = "Daño"
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
                label = "Crítico"
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
                label = "Overkill"
            },
            -- DoT normal
            {
                colors = BCT.Colors.dot or {0.8, 1, 0.5}, 
                size = BCT.config.fontSize * 0.9, 
                isCrit = false, 
                isOverkill = false, 
                isDot = true, 
                min = 50, 
                max = 400, 
                prefix = "", 
                school = "Nature", 
                label = "DoT"
            },
            -- DoT crítico
            {
                colors = BCT.Colors.critDot or {1, 0.8, 0.5}, 
                size = BCT.config.fontSize * (BCT.config.critMultiplier or 1.5) * 0.9, 
                isCrit = true, 
                isOverkill = false, 
                isDot = true, 
                min = 500, 
                max = 2000, 
                prefix = "", 
                school = "Shadow", 
                label = "DoT Crítico"
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
                label = "Curación"
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
                label = "Curación Crítica"
            },
            -- HoT normal
            {
                colors = BCT.Colors.hot or {0.5, 1, 0.5}, 
                size = BCT.config.fontSize * 0.9, 
                isCrit = false, 
                isOverkill = false, 
                isDot = true, 
                min = 100, 
                max = 500, 
                prefix = "+", 
                school = "Healing", 
                label = "HoT"
            },
            -- HoT crítico
            {
                colors = BCT.Colors.critHot or {0.5, 1, 0.8}, 
                size = BCT.config.fontSize * (BCT.config.critMultiplier or 1.5) * 0.9, 
                isCrit = true, 
                isOverkill = false, 
                isDot = true, 
                min = 300, 
                max = 1200, 
                prefix = "+", 
                school = "Healing", 
                label = "HoT Crítico"
            },
        }
        
        -- Programar 20 números durante 10 segundos (1 cada 0.5 segundos)
        for i = 0, 19 do
            C_Timer.After(i * 0.5, function()
                -- Seleccionar tipo aleatorio
                local testType = testTypes[math.random(1, #testTypes)]
                local amount = math.random(testType.min, testType.max)
                local text = testType.prefix .. tostring(amount)
                
                -- Mostrar texto flotante
                BCT:DisplayFloatingText(
                    text,
                    testType.colors,
                    testType.size,
                    testType.isCrit,
                    testType.isOverkill,
                    testType.isDot,
                    false
                )
                
                -- Añadir al log si existe la función
                if BCT.AddToCombatLog then
                    BCT:AddToCombatLog(
                        amount,
                        testType.school,
                        testType.isCrit,
                        testType.isOverkill,
                        string.find(testType.prefix, "+") ~= nil,
                        true
                    )
                end
            end)
        end
        
        -- Mensaje final después de 10 segundos
        C_Timer.After(10, function()
            print("|cff00ff00BCT:|r Test completado! Se mostraron 20 números de 9 tipos diferentes")
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