-- BloodHunt Configuration and Commands
local BH = BloodHunt

-- Comandos slash
SLASH_BLOODHUNT1 = "/bloodhunt"
SLASH_BLOODHUNT2 = "/bh"

SlashCmdList["BLOODHUNT"] = function(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word:lower())
    end
    
    local command = args[1] or "help"
    
    if command == "help" or command == "ayuda" then
        BH:ShowHelp()
    elseif command == "show" or command == "mostrar" then
        BH:ShowUI()
    elseif command == "hide" or command == "ocultar" then
        BH:HideUI()
    elseif command == "toggle" then
        BH:ToggleUI()
    elseif command == "stats" or command == "estadisticas" then
        BH:ShowStats()
    elseif command == "history" or command == "historial" then
        BH:ShowHistory(args[2])
    elseif command == "vengeance" or command == "venganza" then
        BH:ShowVengeanceList()
    elseif command == "reset" then
        BH:ResetData(args[2] or "all")
    elseif command == "settings" or command == "config" then
        BH:ShowSettings()
    elseif command == "notifications" or command == "notificaciones" then
        BH:ToggleSetting("notificationsEnabled")
    elseif command == "ui" then
        BH:ToggleSetting("uiEnabled")
    elseif command == "auto" or command == "automatico" then
        BH:ToggleSetting("autoStart")
    elseif command == "enemies" or command == "enemigos" then
        BH:ShowCurrentEnemies()
    elseif command == "debug" then
        BH:ToggleDebug()
    elseif command == "start" or command == "iniciar" then
        BH:ManualStart()
    else
        print("|cffff0000BloodHunt|r: Comando desconocido. Usa /bh help para ver comandos disponibles.")
    end
end

-- Mostrar ayuda
function BH:ShowHelp()
    print("|cff00ff00=== BloodHunt Comandos ===|r")
    print("|cffff0000/bh show|r - Mostrar interfaz")
    print("|cffff0000/bh hide|r - Ocultar interfaz")
    print("|cffff0000/bh toggle|r - Alternar interfaz")
    print("|cffff0000/bh stats|r - Ver estadísticas")
    print("|cffff0000/bh history [nombre]|r - Ver historial")
    print("|cffff0000/bh vengeance|r - Ver lista de venganza")
    print("|cffff0000/bh reset [tipo]|r - Resetear datos")
    print("  |cff888888Tipos: all, points, vengeance, history|r")
    print("|cffff0000/bh settings|r - Ver configuración")
    print("|cffff0000/bh notifications|r - Alternar notificaciones")
    print("|cffff0000/bh ui|r - Alternar interfaz automática")
    print("|cffff0000/bh auto|r - Alternar inicio automático")
    print("|cffff0000/bh enemies|r - Ver enemigos detectados")
    print("|cffff0000/bh start|r - Iniciar manualmente")
    print("|cffff0000/bh debug|r - Alternar modo debug")
end

-- Inicio manual con enemigos reales
function BH:ManualStart()
    print("|cff00ff00BloodHunt|r: Iniciando manualmente...")
    self.isInBattleground = true
    
    local enemies = self:GetVisibleEnemies()
    print("|cff00ff00BloodHunt|r: Encontrados " .. #enemies .. " enemigos reales")
    
    if #enemies > 0 then
        self:PickTargets(enemies)
        self:ShowUI()
        print("|cff00ff00BloodHunt|r: Iniciado con " .. #enemies .. " enemigos reales")
    else
        print("|cffff0000BloodHunt|r: No se encontraron enemigos reales")
        print("Asegúrate de:")
        print("1. Estar en un campo de batalla")
        print("2. Que haya jugadores enemigos presentes")
        print("3. Activar debug con /bh debug para más información")
    end
end

-- Alternar modo debug
function BH:ToggleDebug()
    BloodHuntDB.settings.debugMode = not (BloodHuntDB.settings.debugMode or false)
    local status = BloodHuntDB.settings.debugMode and "activado" or "desactivado"
    print("|cff00ff00BloodHunt|r: Modo debug " .. status)
end

-- Mostrar estadísticas
function BH:ShowStats()
    local stats = self:GetStats()
    print("|cff00ff00=== BloodHunt Estadísticas ===|r")
    print("Puntos totales: |cffff0000" .. stats.totalPoints .. "|r")
    print("Enemigos eliminados: |cff00ff00" .. stats.totalKills .. "|r")
    print("Venganzas activas: |cffff0000" .. stats.activeVengeances .. "|r")
    
    local inInstance, instanceType = IsInInstance()
    print("En instancia: " .. (inInstance and "Sí" or "No") .. " (" .. (instanceType or "ninguna") .. ")")
    
    if self.isInBattleground then
        print("Estado: |cff00ff00En campo de batalla|r")
        print("Objetivos activos: |cffff0000" .. #self.activeTargets .. "/3|r")
    else
        print("Estado: |cff888888Fuera de combate|r")
    end
end

-- Mostrar enemigos detectados (para debug)
function BH:ShowCurrentEnemies()
    print("|cff00ff00=== Debug de Detección de Enemigos ===|r")
    
    local inInstance, instanceType = IsInInstance()
    print("En instancia: " .. (inInstance and "Sí" or "No") .. " (" .. (instanceType or "ninguna") .. ")")
    print("Facción del jugador: " .. UnitFactionGroup("player"))
    
    -- Activar debug temporalmente
    local wasDebug = BloodHuntDB.settings.debugMode
    BloodHuntDB.settings.debugMode = true
    
    local enemies = self:GetVisibleEnemies()
    
    -- Restaurar debug
    BloodHuntDB.settings.debugMode = wasDebug
    
    if #enemies > 0 then
        print("|cff00ff00Enemigos REALES encontrados:|r")
        for i, enemy in ipairs(enemies) do
            print(i .. ". " .. enemy)
        end
        print("Total: " .. #enemies .. " enemigos reales")
    else
        print("|cffff0000No se detectaron enemigos reales.|r")
        print("Opciones:")
        print("1. |cffff0000/bh start|r - Intentar con enemigos reales")
        print("2. Asegúrate de estar en un campo de batalla activo")
    end
end

-- Mostrar historial
function BH:ShowHistory(targetName)
    if targetName then
        local history = BloodHuntDB.history[targetName]
        if history then
            print("|cff00ff00=== Historial de " .. targetName .. " ===|r")
            print("Eliminaciones: " .. history.kills)
            print("Puntos totales: " .. history.totalPoints)
            print("Primera muerte: " .. history.firstKill)
            print("Última muerte: " .. history.lastKill)
            print("Multiplicador máximo: x" .. history.maxMultiplier)
        else
            print("|cffff0000BloodHunt|r: No hay historial para " .. targetName)
        end
    else
        print("|cff00ff00=== Historial Completo ===|r")
        local count = 0
        for name, data in pairs(BloodHuntDB.history) do
            print(name .. ": " .. data.kills .. " kills, " .. data.totalPoints .. " pts")
            count = count + 1
            if count >= 10 then
                print("... y más. Usa /bh history [nombre] para detalles específicos.")
                break
            end
        end
        if count == 0 then
            print("No hay historial disponible.")
        end
    end
end

-- Mostrar lista de venganza
function BH:ShowVengeanceList()
    print("|cff00ff00=== Lista de Venganza ===|r")
    local count = 0
    for name, data in pairs(BloodHuntDB.vengeance) do
        print("|cffff0000" .. name .. "|r - x" .. data.multiplier .. " (" .. data.attempts .. " fallos)")
        count = count + 1
    end
    if count == 0 then
        print("No hay venganzas pendientes.")
    else
        print("Total: " .. count .. " enemigos por vengar.")
    end
end

-- Mostrar configuración
function BH:ShowSettings()
    print("|cff00ff00=== BloodHunt Configuración ===|r")
    local settings = BloodHuntDB.settings
    print("Notificaciones: " .. (settings.notificationsEnabled and "|cff00ff00Activado|r" or "|cffff0000Desactivado|r"))
    print("Interfaz automática: " .. (settings.uiEnabled and "|cff00ff00Activado|r" or "|cffff0000Desactivado|r"))
    print("Inicio automático: " .. (settings.autoStart and "|cff00ff00Activado|r" or "|cffff0000Desactivado|r"))
    print("Modo debug: " .. ((settings.debugMode or false) and "|cff00ff00Activado|r" or "|cffff0000Desactivado|r"))
end

-- Alternar configuración
function BH:ToggleSetting(setting)
    BloodHuntDB.settings[setting] = not BloodHuntDB.settings[setting]
    local status = BloodHuntDB.settings[setting] and "activado" or "desactivado"
    local settingName = setting == "notificationsEnabled" and "Notificaciones" or
                       setting == "uiEnabled" and "Interfaz automática" or 
                       setting == "autoStart" and "Inicio automático" or setting
    print("|cff00ff00BloodHunt|r: " .. settingName .. " " .. status .. ".")
    
end

-- Inicialización de configuración por defecto
function BH:InitializeSettings()
    if not BloodHuntDB.settings then
        BloodHuntDB.settings = {
            notificationsEnabled = true,
            uiEnabled = true,
            debugMode = false,
            autoStart = true
        }
    end
end
