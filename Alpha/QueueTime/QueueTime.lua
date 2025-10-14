-- Crear un frame movible
local f = CreateFrame("Frame", "QueueTimeFrame", UIParent)
f:SetSize(300, 60)
f:SetPoint("TOP", UIParent, "TOP", 0, -50)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetClampedToScreen(true)
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)

-- Fondo y texto
f.bg = f:CreateTexture(nil, "BACKGROUND")
f.bg:SetAllPoints(f)
f.bg:SetColorTexture(0, 0, 0, 0.5)

f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
f.text:SetPoint("CENTER", f, "CENTER", 0, 0)
f.text:SetText("")

-- Ocultar al inicio
f:Hide()

-- Variables de tiempo
local startTime = nil

-- Función para actualizar el tiempo
local function UpdateQueueInfo()
    local inQueue = false
    local queueType = ""
    local avgWait = nil
    local myWait = nil
    
    -- Comprobar Mazmorras (LFD)
    local hasData, leaderNeeds, tank, healer, dps, totalTanks, totalHealers, totalDPS, instanceType, lfgAvgWait, lfgMyWait = GetLFGQueueStats(LE_LFG_CATEGORY_LFD)
    if hasData and lfgMyWait then
        inQueue = true
        queueType = "Dungeon"
        avgWait = lfgAvgWait
        myWait = lfgMyWait
    end
    
    -- Comprobar Bandas (LFR)
    if not inQueue then
        hasData, leaderNeeds, tank, healer, dps, totalTanks, totalHealers, totalDPS, instanceType, lfgAvgWait, lfgMyWait = GetLFGQueueStats(LE_LFG_CATEGORY_RF)
        if hasData and lfgMyWait then
            inQueue = true
            queueType = "Raid Finder"
            avgWait = lfgAvgWait
            myWait = lfgMyWait
        end
    end
    
    -- Comprobar Campos de Batalla (WoW soporta hasta 3 colas simultáneas)
    if not inQueue then
        for i = 1, 3 do
            local status, mapName, teamSize, registeredMatch, suspendedQueue = GetBattlefieldStatus(i)
            if status == "queued" or status == "confirm" then
                inQueue = true
                queueType = "Battleground"
                if mapName then
                    queueType = mapName
                end
                -- Obtener tiempo estimado de BG si está disponible
                local estimatedTime = GetBattlefieldEstimatedWaitTime(i)
                if estimatedTime and estimatedTime > 0 then
                    avgWait = math.floor(estimatedTime / 60000) -- Convertir ms a minutos
                end
                break
            end
        end
    end
    
    -- Comprobar LFG List (Mythic+, raids custom, etc)
    if not inQueue then
        local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
        if activeEntryInfo then
            inQueue = true
            queueType = "Group Finder"
        end
    end
    
    -- Mostrar u ocultar según estado
    if inQueue then
        if not startTime then
            startTime = GetTime()
        end
        
        local queueTime = GetTime() - startTime
        local mins = math.floor(queueTime / 60)
        local secs = math.floor(queueTime % 60)
        
        -- Construir el texto
        local displayText = string.format("%s\nTime: %dm %ds", queueType, mins, secs)
        
        if avgWait and avgWait > 0 then
            displayText = displayText .. string.format("\nAvg: %dm", avgWait)
        end
        
        if myWait and myWait > 0 then
            displayText = displayText .. string.format(" | Est: %dm", myWait)
        end
        
        f.text:SetText(displayText)
        f:Show()
    else
        startTime = nil
        f:Hide()
    end
end

-- Timer con throttle (actualiza cada 1 segundo)
local timeSinceLastUpdate = 0
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate >= 1 then
        UpdateQueueInfo()
        timeSinceLastUpdate = 0
    end
end)

-- Eventos para detectar cambios de cola
f:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
f:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
f:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
f:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
f:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW")
f:RegisterEvent("PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE")

f:SetScript("OnEvent", function(self, event, ...)
    UpdateQueueInfo()
end)

-- Actualización inicial
UpdateQueueInfo()