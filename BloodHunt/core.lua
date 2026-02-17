-- BloodHunt Core System
BloodHunt = {}
local BH = BloodHunt

-- Variables principales
BH.activeTargets = {}
BH.totalPoints = 0
BH.isInBattleground = false
BH.frame = nil

-- Inicialización del addon
function BH:Initialize()
    -- Crear base de datos si no existe
    if not BloodHuntDB then
        BloodHuntDB = {
            vengeance = {},
            history = {},
            totalPoints = 0,
            settings = {
                notificationsEnabled = true,
                uiEnabled = true,
                debugMode = false,
                autoStart = true
            }
        }
    end
    
    -- Agregar autoStart si no existe
    if BloodHuntDB.settings.autoStart == nil then
        BloodHuntDB.settings.autoStart = true
    end
    
    self.totalPoints = BloodHuntDB.totalPoints or 0
    print("|cff00ff00BloodHunt|r cargado. Puntos totales: " .. self.totalPoints)
end

-- Detectar entrada a campo de batalla (método original)
function BH:OnBattlefieldEnter()
    if not BloodHuntDB.settings.autoStart then
        print("|cff00ff00BloodHunt|r: Campo de batalla detectado")
        return
    end
    
    if not self:IsInBattleground() then
        return
    end
    
    -- No hacer nada aquí, esperar a que la batalla comience realmente
end

-- Verificar si está en campo de batalla
function BH:IsInBattleground()
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == "pvp"
end

-- Obtener enemigos visibles (SIN enemigos ficticios por defecto)
function BH:GetVisibleEnemies()
    local enemies = {}
    local playerName = UnitName("player")
    local playerFaction = UnitFactionGroup("player")
    
    if BloodHuntDB.settings.debugMode then
        print("|cff888888Debug: Jugador = " .. playerName .. ", Facción = " .. playerFaction .. "|r")
    end
    
    -- Método 1: GetBattlefieldScore (MÁS CONFIABLE)
    local numScores = GetNumBattlefieldScores and GetNumBattlefieldScores() or 0
    
    if BloodHuntDB.settings.debugMode then
        print("|cff888888Debug: Battlefield scores disponibles: " .. numScores .. "|r")
    end
    
    if numScores > 0 then
        for i = 1, numScores do
            local name, _, _, _, _, faction = GetBattlefieldScore(i)
            if name and name ~= playerName and faction ~= nil then
                
                if BloodHuntDB.settings.debugMode then
                    print("|cff888888Debug: " .. name .. " - facción " .. faction .. " (player: " .. playerFaction .. ")|r")
                end
                
                -- Lógica de facción CORREGIDA:
                -- faction 1 = Alliance, faction 0 = Horde
                local isEnemy = false
                if playerFaction == "Alliance" and faction == 0 then
                    isEnemy = true -- Horde es enemigo de Alliance
                elseif playerFaction == "Horde" and faction == 1 then
                    isEnemy = true -- Alliance es enemigo de Horde
                end
                
                if isEnemy and not self:TableContains(enemies, name) then
                    table.insert(enemies, name)
                    if BloodHuntDB.settings.debugMode then
                        print("|cff00ff00Debug: Enemigo REAL agregado: " .. name .. "|r")
                    end
                end
            end
        end
    end
    
    -- Método 2: Nameplates (solo si battlefield scores no funciona)
    if #enemies == 0 and BloodHuntDB.settings.debugMode then
        print("|cff888888Debug: Battlefield scores vacío, probando nameplates...|r")
        
        for i = 1, 40 do
            local unit = "nameplate" .. i
            if UnitExists(unit) and UnitIsPlayer(unit) then
                local name = UnitName(unit)
                local isEnemy = UnitIsEnemy("player", unit)
                
                if name and name ~= playerName and isEnemy and not self:TableContains(enemies, name) then
                    table.insert(enemies, name)
                    print("|cff00ff00Debug: Enemigo de nameplate agregado: " .. name .. "|r")
                end
            end
        end
    end
    
    -- Método 3: Target/Focus (solo si no hay otros)
    if #enemies == 0 then
        for _, unit in pairs({"target", "focus", "targettarget"}) do
            if UnitExists(unit) and UnitIsPlayer(unit) and UnitIsEnemy("player", unit) then
                local name = UnitName(unit)
                if name and name ~= playerName and not self:TableContains(enemies, name) then
                    table.insert(enemies, name)
                    if BloodHuntDB.settings.debugMode then
                        print("|cff00ff00Debug: Enemigo de " .. unit .. " agregado: " .. name .. "|r")
                    end
                end
            end
        end
    end
    
    if BloodHuntDB.settings.debugMode then
        print("|cff00ff00Debug: Total enemigos REALES encontrados: " .. #enemies .. "|r")
    end
    
    return enemies
end

-- Generar enemigos ficticios SOLO cuando se solicite explícitamente
function BH:GetFakeEnemies()
    local fakeEnemies = {}
    local fakeNames = {"EnemyTest1", "EnemyTest2", "EnemyTest3", "EnemyTest4", "EnemyTest5"}
    
    for _, fakeName in ipairs(fakeNames) do
        table.insert(fakeEnemies, fakeName)
    end
    
    print("|cff888888BloodHunt|r: Generados " .. #fakeEnemies .. " enemigos ficticios para testing")
    return fakeEnemies
end

-- Seleccionar objetivos (permite menos de 3 si es necesario)
function BH:PickTargets(enemyList)
    self.activeTargets = {}
    local availableEnemies = {}
    
    -- Copiar lista para no modificar la original
    for _, enemy in ipairs(enemyList) do
        table.insert(availableEnemies, enemy)
    end
    
    -- Seleccionar hasta 3 enemigos únicos (o los que haya disponibles)
    local maxTargets = math.min(3, #availableEnemies)
    
    while #self.activeTargets < maxTargets and #availableEnemies > 0 do
        local index = math.random(#availableEnemies)
        local name = availableEnemies[index]
        table.remove(availableEnemies, index)
        
        -- Verificar venganza previa
        local vengeanceData = BloodHuntDB.vengeance[name]
        local basePoints = math.random(1, 5)
        local multiplier = vengeanceData and vengeanceData.multiplier or 1
        local finalPoints = basePoints * multiplier
        
        table.insert(self.activeTargets, {
            name = name,
            basePoints = basePoints,
            multiplier = multiplier,
            totalPoints = finalPoints,
            isVengeance = vengeanceData ~= nil,
            attempts = vengeanceData and vengeanceData.attempts or 0
        })
        
        -- Notificar si es venganza
        if vengeanceData then
            self:ShowVengeanceNotification(name, multiplier)
        end
    end
    
    print("|cff00ff00BloodHunt|r: " .. #self.activeTargets .. " objetivos seleccionados de " .. #enemyList .. " enemigos disponibles.")
end

-- Reemplazar objetivo eliminado
function BH:ReplaceTarget(index)
    if not self.isInBattleground then return end
    
    local enemies = self:GetVisibleEnemies()
    local currentNames = {}
    
    -- Obtener nombres actuales para evitar duplicados
    for _, target in ipairs(self.activeTargets) do
        currentNames[target.name] = true
    end
    
    -- Filtrar enemigos ya seleccionados
    local availableEnemies = {}
    for _, enemy in ipairs(enemies) do
        if not currentNames[enemy] then
            table.insert(availableEnemies, enemy)
        end
    end
    
    if #availableEnemies > 0 then
        local randomIndex = math.random(#availableEnemies)
        local name = availableEnemies[randomIndex]
        
        local vengeanceData = BloodHuntDB.vengeance[name]
        local basePoints = math.random(1, 5)
        local multiplier = vengeanceData and vengeanceData.multiplier or 1
        local finalPoints = basePoints * multiplier
        
        self.activeTargets[index] = {
            name = name,
            basePoints = basePoints,
            multiplier = multiplier,
            totalPoints = finalPoints,
            isVengeance = vengeanceData ~= nil,
            attempts = vengeanceData and vengeanceData.attempts or 0
        }
        
        if vengeanceData then
            self:ShowVengeanceNotification(name, multiplier)
        end
        
        self:UpdateUI()
    else
        print("|cffff8800BloodHunt|r: No hay enemigos disponibles para reemplazar objetivo " .. index)
    end
end

-- Utilidades
function BH:TableContains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function BH:ShowVengeanceNotification(name, multiplier)
    if BloodHuntDB.settings.notificationsEnabled then
        print("|cffff0000¡VENGANZA!|r " .. name .. " (x" .. multiplier .. ") está en tu lista de objetivos!")
    end
end

-- Salir del campo de batalla
function BH:OnBattlefieldExit()
    self.isInBattleground = false
    self.activeTargets = {}
    self:HideUI()
    print("|cff00ff00BloodHunt|r: Datos guardados. Puntos totales: " .. self.totalPoints)
end
