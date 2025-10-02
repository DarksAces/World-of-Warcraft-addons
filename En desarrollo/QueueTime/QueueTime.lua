-- Crear un frame movible
local f = CreateFrame("Frame", "QueueTimeFrame", UIParent)
f:SetSize(200, 50)
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
    -- Para LFG (Dungeon Finder, LFR, etc)
    local hasData, _, tank, healer, dps, _, _, _, _, avgWait, myWait = GetLFGQueueStats(LE_LFG_CATEGORY_LFD)
    
    if hasData and myWait then
        if not startTime then
            startTime = GetTime()
        end
        
        local queueTime = GetTime() - startTime
        
        f.text:SetText(
            string.format("Queue Time: %dm %ds\nAvg Wait: %d min", 
                math.floor(queueTime / 60), 
                math.floor(queueTime % 60),
                avgWait or 0
            )
        )
        f:Show()
    else
        -- Comprobar si estamos en cola de LFG List (Mythic+, raids custom, etc)
        local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
        
        if activeEntryInfo then
            if not startTime then
                startTime = GetTime()
            end
            
            local queueTime = GetTime() - startTime
            
            f.text:SetText(
                string.format("Queue Time: %dm %ds\nWaiting for group...", 
                    math.floor(queueTime / 60), 
                    math.floor(queueTime % 60)
                )
            )
            f:Show()
        else
            -- No estamos en ninguna cola - OCULTAR
            startTime = nil
            f:Hide()
        end
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

f:SetScript("OnEvent", function(self, event, ...)
    UpdateQueueInfo()
end)

-- Actualización inicial
UpdateQueueInfo()