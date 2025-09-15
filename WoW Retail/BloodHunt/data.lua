-- BloodHunt Data Management
local BH = BloodHunt

-- Agregar enemigo a lista de venganza
function BH:AddVengeanceTarget(name, basePoints)
    if not BloodHuntDB.vengeance[name] then
        BloodHuntDB.vengeance[name] = {
            attempts = 0,
            multiplier = 1,
            basePoints = basePoints,
            firstFailed = date("%d/%m/%Y %H:%M"),
            lastFailed = date("%d/%m/%Y %H:%M")
        }
    end
    
    local vengeance = BloodHuntDB.vengeance[name]
    vengeance.attempts = vengeance.attempts + 1
    vengeance.multiplier = vengeance.multiplier * 2
    vengeance.lastFailed = date("%d/%m/%Y %H:%M")
    
    print("|cffff0000Venganza|r: " .. name .. " te mató. Multiplicador: x" .. vengeance.multiplier)
end

-- Limpiar venganza (cuando se mata al enemigo)
function BH:ClearVengeance(name)
    if BloodHuntDB.vengeance[name] then
        local vengeance = BloodHuntDB.vengeance[name]
        print("|cff00ff00¡VENGANZA COMPLETADA!|r " .. name .. " eliminado después de " .. vengeance.attempts .. " intentos.")
        BloodHuntDB.vengeance[name] = nil
    end
end

-- Registrar eliminación exitosa
function BH:RecordSuccess(name, points, wasVengeance)
    -- Sumar puntos
    self.totalPoints = self.totalPoints + points
    BloodHuntDB.totalPoints = self.totalPoints
    
    -- Registrar en historial
    if not BloodHuntDB.history[name] then
        BloodHuntDB.history[name] = {
            kills = 0,
            totalPoints = 0,
            firstKill = date("%d/%m/%Y %H:%M"),
            lastKill = date("%d/%m/%Y %H:%M"),
            maxMultiplier = 1
        }
    end
    
    local history = BloodHuntDB.history[name]
    history.kills = history.kills + 1
    history.totalPoints = history.totalPoints + points
    history.lastKill = date("%d/%m/%Y %H:%M")
    
    -- Actualizar multiplicador máximo si fue venganza
    if wasVengeance then
        local vengeanceData = BloodHuntDB.vengeance[name]
        if vengeanceData and vengeanceData.multiplier > history.maxMultiplier then
            history.maxMultiplier = vengeanceData.multiplier
        end
    end
    
    print("|cff00ff00+" .. points .. " puntos|r por eliminar a " .. name .. "! Total: " .. self.totalPoints)
end

-- Obtener estadísticas
function BH:GetStats()
    local totalKills = 0
    local totalVengeances = 0
    local activeVengeances = 0
    
    for name, data in pairs(BloodHuntDB.history) do
        totalKills = totalKills + data.kills
    end
    
    for name, data in pairs(BloodHuntDB.vengeance) do
        activeVengeances = activeVengeances + 1
    end
    
    return {
        totalPoints = self.totalPoints,
        totalKills = totalKills,
        activeVengeances = activeVengeances
    }
end

-- Resetear datos
function BH:ResetData(dataType)
    if dataType == "all" or dataType == "todo" then
        BloodHuntDB.vengeance = {}
        BloodHuntDB.history = {}
        BloodHuntDB.totalPoints = 0
        self.totalPoints = 0
        print("|cffff0000BloodHunt|r: Todos los datos han sido reseteados.")
    elseif dataType == "points" or dataType == "puntos" then
        BloodHuntDB.totalPoints = 0
        self.totalPoints = 0
        print("|cffff0000BloodHunt|r: Puntos reseteados.")
    elseif dataType == "vengeance" or dataType == "venganza" then
        BloodHuntDB.vengeance = {}
        print("|cffff0000BloodHunt|r: Lista de venganza limpiada.")
    elseif dataType == "history" or dataType == "historial" then
        BloodHuntDB.history = {}
        print("|cffff0000BloodHunt|r: Historial limpiado.")
    end
end

-- Exportar datos para backup
function BH:ExportData()
    local data = {
        totalPoints = BloodHuntDB.totalPoints,
        vengeanceCount = 0,
        historyCount = 0,
        exportDate = date("%d/%m/%Y %H:%M")
    }
    
    for _ in pairs(BloodHuntDB.vengeance) do
        data.vengeanceCount = data.vengeanceCount + 1
    end
    
    for _ in pairs(BloodHuntDB.history) do
        data.historyCount = data.historyCount + 1
    end
    
    return data
end
