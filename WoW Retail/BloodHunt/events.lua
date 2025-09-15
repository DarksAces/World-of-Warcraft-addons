-- BloodHunt Event Handler
local BH = BloodHunt

-- Frame para eventos
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
eventFrame:RegisterEvent("BATTLEGROUND_OBJECTIVES_UPDATE")
eventFrame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
eventFrame:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
eventFrame:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "BloodHunt" then
            BH:Initialize()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        local isLogin, isReload = ...
        C_Timer.After(3, function()
            if BH:IsInBattleground() then
                BH:OnBattlefieldEnter()
            end
        end)
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        C_Timer.After(2, function()
            if BH:IsInBattleground() then
                if not BH.isInBattleground then
                    BH:OnBattlefieldEnter()
                end
            else
                if BH.isInBattleground then
                    BH:OnBattlefieldExit()
                end
            end
        end)
    elseif event == "UPDATE_BATTLEFIELD_STATUS" then
        BH:CheckBattlefieldStatus()
    elseif event == "BATTLEGROUND_OBJECTIVES_UPDATE" then
        if BH:IsInBattleground() and not BH.isInBattleground then
            print("|cff00ff00BloodHunt|r: Batalla iniciada, activando...")
            BH:OnBattlefieldStart()
        end
    elseif event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" or event == "CHAT_MSG_BG_SYSTEM_ALLIANCE" or event == "CHAT_MSG_BG_SYSTEM_HORDE" then
        local message = ...
        BH:CheckBattleStartMessage(message)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        BH:HandleCombatLog()
    elseif event == "PLAYER_DEAD" then
        BH:OnPlayerDeath()
    end
end)

-- Verificar estado del campo de batalla
function BH:CheckBattlefieldStatus()
    if not self:IsInBattleground() then
        return
    end
    
    -- Verificar si la batalla ha comenzado
    local status, mapName, instanceID = GetBattlefieldStatus(1)
    
    if status == "active" and not self.isInBattleground then
        C_Timer.After(3, function()
            self:OnBattlefieldStart()
        end)
    end
end

-- Verificar mensajes del sistema de batalla
function BH:CheckBattleStartMessage(message)
    if not self:IsInBattleground() or self.isInBattleground then
        return
    end
    
    -- Mensajes que indican que la batalla ha comenzado
    local startMessages = {
        "¡Que comience la batalla!",
        "Let the battle begin!",
        "La batalla ha comenzado",
        "The battle has begun",
        "¡La batalla comienza!",
        "Battle begins!",
        "¡Preparaos para la batalla!",
        "Prepare for battle!",
        "30 seconds until the battle begins",
        "30 segundos para que comience la batalla"
    }
    
    for _, startMsg in ipairs(startMessages) do
        if message and message:find(startMsg) then
            C_Timer.After(5, function()
                self:OnBattlefieldStart()
            end)
            break
        end
    end
end

-- Cuando la batalla realmente comienza
function BH:OnBattlefieldStart()
    if self.isInBattleground then
        return -- Ya está iniciado
    end
    
    print("|cff00ff00BloodHunt|r: ¡Batalla iniciada!")
    self.isInBattleground = true
    
    -- Intentar infinitamente hasta encontrar enemigos
    local function tryDetectEnemies()
        -- Solo continuar si seguimos en batalla
        if not self.isInBattleground then
            return
        end
        
        local enemies = self:GetVisibleEnemies()
        
        if #enemies > 0 then
            self:PickTargets(enemies)
            self:ShowUI()
            print("|cff00ff00BloodHunt|r: ¡Activado con " .. #enemies .. " enemigos!")
        else
            -- Intentar de nuevo en 30 segundos (sin mensaje)
            C_Timer.After(30, tryDetectEnemies)
        end
    end
    
    -- Comenzar la detección
    tryDetectEnemies()
end

-- Manejar log de combate
function BH:HandleCombatLog()
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, 
          destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
    
    -- Verificar que los nombres no sean nuestros aliados
    local playerName = UnitName("player")
    
    if subevent == "PARTY_KILL" then
        -- El jugador mató a alguien
        if sourceGUID == UnitGUID("player") and destName and destName ~= playerName then
            -- Verificar que sea realmente un enemigo
            if self:IsRealEnemy(destName) then
                self:OnTargetKilled(destName)
            end
        end
        -- Alguien mató al jugador
        if destGUID == UnitGUID("player") and sourceName and sourceName ~= playerName then
            -- Verificar que sea realmente un enemigo
            if self:IsRealEnemy(sourceName) then
                self:OnPlayerKilledBy(sourceName)
            end
        end
    end
end

-- Verificar si un nombre es realmente un enemigo
function BH:IsRealEnemy(name)
    local playerName = UnitName("player")
    local playerFaction = UnitFactionGroup("player")
    
    -- No puede ser el propio jugador
    if name == playerName then
        return false
    end
    
    -- Verificar en la lista de battlefield scores
    if GetNumBattlefieldScores and GetNumBattlefieldScores() > 0 then
        for i = 1, GetNumBattlefieldScores() do
            local scoreName, _, _, _, _, faction = GetBattlefieldScore(i)
            if scoreName == name then
                -- Es enemigo si es de facción contraria
                return (playerFaction == "Alliance" and faction == 0) or 
                       (playerFaction == "Horde" and faction == 1)
            end
        end
    end
    
    -- Si no está en battlefield scores, asumir que es enemigo si está en nuestros objetivos
    for _, target in ipairs(self.activeTargets) do
        if target.name == name then
            return true
        end
    end
    
    return false
end

-- Cuando el jugador mata a un objetivo
function BH:OnTargetKilled(victimName)
    if not self.isInBattleground then return end
    
    for i, target in ipairs(self.activeTargets) do
        if target.name == victimName then
            -- Otorgar puntos
            self:RecordSuccess(victimName, target.totalPoints, target.isVengeance)
            
            -- Limpiar venganza si existía
            if target.isVengeance then
                self:ClearVengeance(victimName)
            end
            
            -- Reemplazar objetivo
            self:ReplaceTarget(i)
            
            -- Actualizar UI
            self:UpdateUI()
            
            break
        end
    end
end

-- Cuando matan al jugador
function BH:OnPlayerKilledBy(killerName)
    if not self.isInBattleground then return end
    
    for i, target in ipairs(self.activeTargets) do
        if target.name == killerName then
            -- Agregar a venganza
            self:AddVengeanceTarget(killerName, target.basePoints)
            
            -- Reemplazar objetivo
            self:ReplaceTarget(i)
            
            -- Actualizar UI
            self:UpdateUI()
            
            break
        end
    end
end

-- Cuando el jugador muere (método alternativo)
function BH:OnPlayerDeath()
    if not self.isInBattleground then return end
    
    -- Buscar quién nos mató en el log reciente
    C_Timer.After(1, function()
        -- Este método es un respaldo si el combat log no funciona perfectamente
        -- En una implementación real, podrías usar APIs adicionales aquí
    end)
end
