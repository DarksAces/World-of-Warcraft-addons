local addonName = "DungeonAndRaidTimer"
local DART = CreateFrame("Frame")
local currentInstance, startTime
local timerFrame, statsFrame
local updateTimer, checkCompletionTicker
local bossesKilled = 0
local totalBosses = 0
local dungeonCompleted = false

DART_SavedTimes = DART_SavedTimes or {}

-- =============================================
-- CONFIGURACIÓN DE ESTILOS Y FUNCIONES BÁSICAS
-- =============================================

-- Estilos visuales
local COLORS = {
    background = {0.1, 0.1, 0.1, 0.9},
    border = {0.4, 0.4, 0.4},
    title = {1, 0.8, 0},
    highlight = {0, 1, 0},
    normal = {1, 1, 1},
    disabled = {0.7, 0.7, 0.7}
}

local FONTS = {
    title = "GameFontNormalLarge",
    header = "GameFontNormal",
    normal = "GameFontHighlight",
    small = "GameFontHighlightSmall"
}

-- Helper: convertir segundos a hh:mm:ss
local function SecondsToTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- Crear elemento de texto con estilos
local function CreateTextElement(parent, font, color, anchor, x, y, text)
    local element = parent:CreateFontString(nil, "OVERLAY", font)
    element:SetPoint(anchor, x, y)
    element:SetTextColor(unpack(color))
    element:SetText(text)
    return element
end

-- =============================================
-- VENTANA DE ESTADÍSTICAS (NUEVO DISEÑO)
-- =============================================

-- Crear ventana de estadísticas rediseñada
-- Crear ventana de estadísticas rediseñada
local function CreateStatsFrame()
    statsFrame = CreateFrame("Frame", "DARTStatsFrame", UIParent)
    statsFrame:SetSize(600, 500)
    statsFrame:SetPoint("CENTER")
    statsFrame:SetMovable(true)
    statsFrame:EnableMouse(true)
    statsFrame:RegisterForDrag("LeftButton")
    statsFrame:SetScript("OnDragStart", statsFrame.StartMoving)
    statsFrame:SetScript("OnDragStop", statsFrame.StopMovingOrSizing)
    
    -- Fondo
    statsFrame.background = statsFrame:CreateTexture(nil, "BACKGROUND")
    statsFrame.background:SetAllPoints()
    statsFrame.background:SetColorTexture(unpack(COLORS.background))
    
    -- Borde
    statsFrame.border = CreateFrame("Frame", nil, statsFrame, "BackdropTemplate")
    statsFrame.border:SetPoint("TOPLEFT", -5, 5)
    statsFrame.border:SetPoint("BOTTOMRIGHT", 5, -5)
    statsFrame.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16
    })
    statsFrame.border:SetBackdropBorderColor(unpack(COLORS.border))
    
    -- Título
    statsFrame.title = CreateTextElement(statsFrame, FONTS.title, COLORS.title, "TOP", 0, -15, "Estadísticas de Dungeons & Raids")
    
    -- Contenedor principal con scroll
    local scrollContainer = CreateFrame("Frame", nil, statsFrame)
    scrollContainer:SetPoint("TOPLEFT", 20, -50)
    scrollContainer:SetPoint("BOTTOMRIGHT", -40, 50)
    
    -- Create scroll frame with unique name to avoid nil concatenation
    local scrollFrameName = "DARTStatsScrollFrame"
    local scrollFrame = CreateFrame("ScrollFrame", scrollFrameName, scrollContainer, "UIPanelScrollFrameTemplate")
    scrollFrame:SetAllPoints()
    
    -- Fix the scrollbar reference issue
    local scrollBar = _G[scrollFrameName.."ScrollBar"]
    if scrollBar then
        scrollBar:ClearAllPoints()
        scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 5, -16)
        scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 5, 16)
    end
    
    -- Contenido
    local content = CreateFrame("Frame")
    content:SetWidth(scrollContainer:GetWidth() - 30)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)
    
    statsFrame.scrollFrame = scrollFrame
    statsFrame.content = content
    
    -- Botón de cerrar
    local closeButton = CreateFrame("Button", nil, statsFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() statsFrame:Hide() end)
    
    statsFrame:Hide()
end


-- Mostrar solo mejores tiempos ordenados
function ShowBestTimesOnly()

    if not statsFrame or not statsFrame.content then return end
    local content = statsFrame.content
    
    -- Limpiar contenido anterior
    for i = content:GetNumChildren(), 1, -1 do
        local child = select(i, content:GetChildren())
        child:Hide()
        child:SetParent(nil)
    end
    
    local yOffset = -10
    local lineHeight = 28
    
    if next(DART_SavedTimes) == nil then
        CreateTextElement(content, FONTS.normal, COLORS.disabled, "TOPLEFT", 10, yOffset, "No hay datos de dungeons/raids aún.")
        content:SetHeight(40)
        return
    end
    
    -- Título
    CreateTextElement(content, FONTS.header, COLORS.title, "TOPLEFT", 10, yOffset, "🏆 MEJORES TIEMPOS")
    yOffset = yOffset - lineHeight - 10
    
    -- Ordenar instancias por mejor tiempo
    local sortedInstances = {}
    for name, data in pairs(DART_SavedTimes) do
        if data.best then
            table.insert(sortedInstances, {name = name, bestTime = data.best, runs = #data.runs})
        end
    end
    
    table.sort(sortedInstances, function(a, b) return a.bestTime < b.bestTime end)
    
    -- Mostrar resultados
    for i, instance in ipairs(sortedInstances) do
        local medal = ""
        local color = COLORS.normal
        
        if i == 1 then 
            medal = "🥇 "
            color = {1, 0.8, 0}
        elseif i == 2 then 
            medal = "🥈 "
            color = {0.8, 0.8, 0.8}
        elseif i == 3 then 
            medal = "🥉 "
            color = {0.8, 0.5, 0.2}
        else 
            medal = i..". "
        end
        
        local text = string.format("%s%s: %s (%d runs)", medal, instance.name, SecondsToTime(instance.bestTime), instance.runs)
        CreateTextElement(content, FONTS.normal, color, "TOPLEFT", 15, yOffset, text)
        yOffset = yOffset - lineHeight
    end
    
    content:SetHeight(math.abs(yOffset) + 20)
    if statsFrame.scrollFrame and statsFrame.scrollFrame.UpdateScrollChildRect then
        statsFrame.scrollFrame:UpdateScrollChildRect()
    end
end

-- Actualizar visualización de estadísticas
function UpdateStatsDisplay()

    if not statsFrame or not statsFrame.content then return end
    local content = statsFrame.content
    
    -- Limpiar contenido anterior
for _, region in ipairs({content:GetRegions()}) do
    region:Hide()
    region:SetParent(nil)
end
for _, child in ipairs({content:GetChildren()}) do
    child:Hide()
    child:SetParent(nil)
end

    local yOffset = -10
    local lineHeight = 25
    local sectionSpacing = 20
    
    if next(DART_SavedTimes) == nil then
        CreateTextElement(content, FONTS.normal, COLORS.disabled, "TOPLEFT", 10, yOffset, "No hay datos de dungeons/raids aún.")
        content:SetHeight(40)
        return
    end
    
    -- Mostrar todas las instancias
    for instanceName, data in pairs(DART_SavedTimes) do
        -- Nombre de la instancia
        CreateTextElement(content, FONTS.header, COLORS.title, "TOPLEFT", 10, yOffset, instanceName)
        yOffset = yOffset - lineHeight
        
        -- Runs
        CreateTextElement(content, FONTS.normal, COLORS.normal, "TOPLEFT", 25, yOffset, "Runs: "..#data.runs)
        yOffset = yOffset - lineHeight
        
        -- Mejor tiempo
        if data.best then
            CreateTextElement(content, FONTS.normal, COLORS.highlight, "TOPLEFT", 25, yOffset, "Mejor tiempo: "..SecondsToTime(data.best))
            yOffset = yOffset - lineHeight
        end
        
        -- Promedio
        if data.avg then
            CreateTextElement(content, FONTS.normal, {0.5, 0.8, 1}, "TOPLEFT", 25, yOffset, "Promedio: "..SecondsToTime(data.avg))
            yOffset = yOffset - lineHeight
        end
        
        yOffset = yOffset - sectionSpacing
    end
    
    content:SetHeight(math.abs(yOffset) + 30)
    if statsFrame.scrollFrame and statsFrame.scrollFrame.UpdateScrollChildRect then
        statsFrame.scrollFrame:UpdateScrollChildRect()
    end
end

-- =============================================
-- FUNCIONALIDAD DEL CRONÓMETRO
-- =============================================

-- Obtener total bosses de la instancia actual
local function GetTotalBosses()
    local _, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
    if instanceType ~= "party" and instanceType ~= "raid" then return 0 end

    if type(IsAddOnLoaded) == "function" and type(LoadAddOn) == "function" then
        if not IsAddOnLoaded("Blizzard_EncounterJournal") then
            local loaded, reason = LoadAddOn("Blizzard_EncounterJournal")
            if not loaded then
                print("|cffff0000[DART]|r No se pudo cargar Blizzard_EncounterJournal: " .. tostring(reason))
                return 0
            end
        end
    end

    local success, _ = pcall(EJ_SelectInstance, instanceID)
    if not success then
        print("|cffffaa00[DART]|r EJ_SelectInstance falló para ID " .. tostring(instanceID) .. ". Usando fallback.")
        return 0
    end

    if type(EJ_GetNumEncountersForInstance) == "function" then
        local numBosses = EJ_GetNumEncountersForInstance() or 0
        return numBosses
    else
        print("|cffff4444[DART]|r EJ_GetNumEncountersForInstance no está disponible en este entorno.")
        return 0
    end
end

-- Comprobar si todos los bosses han sido derrotados
local function CheckDungeonCompletion()
    if not currentInstance or dungeonCompleted then return end
    if totalBosses == 0 then return end

    if bossesKilled >= totalBosses then
        dungeonCompleted = true
        print("|cff00ff00[DART]|r Instancia completada: " .. currentInstance)
        StopTimer()
        if checkCompletionTicker then
            checkCompletionTicker:Cancel()
            checkCompletionTicker = nil
        end
    end
end

-- Crear frame del cronómetro
local function CreateTimerFrame()
    timerFrame = CreateFrame("Frame", "DARTTimerFrame", UIParent)
    timerFrame:SetSize(250, 60)
    timerFrame:SetPoint("TOP", UIParent, "TOP", 0, -100)

    local bg = timerFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.8)

    timerFrame:Hide()

    timerFrame:SetMovable(true)
    timerFrame:EnableMouse(true)
    timerFrame:RegisterForDrag("LeftButton")
    timerFrame:SetScript("OnDragStart", timerFrame.StartMoving)
    timerFrame:SetScript("OnDragStop", timerFrame.StopMovingOrSizing)

    local title = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", timerFrame, "TOPLEFT", 10, -12)
    title:SetText("Dungeon Timer")
    title:SetTextColor(0, 1, 0)

    local timeText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    timeText:SetPoint("CENTER", timerFrame, "CENTER", 20, -5)
    timeText:SetText("00:00:00")
    timeText:SetTextColor(1, 1, 1)

    local instanceText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    instanceText:SetPoint("BOTTOMLEFT", timerFrame, "BOTTOMLEFT", 10, 8)
    instanceText:SetText("")
    instanceText:SetTextColor(1, 1, 0)

    local pauseButton = CreateFrame("Button", nil, timerFrame, "UIPanelButtonTemplate")
    pauseButton:SetSize(60, 25)
    pauseButton:SetPoint("RIGHT", timerFrame, "RIGHT", -10, 0)
    pauseButton:SetText("Pausar")

    local paused = false
    local pausedTimeOffset = 0
    local pauseStartTime = nil

    pauseButton:SetScript("OnClick", function()
        if not paused then
            pauseStartTime = GetTime()
            if updateTimer then updateTimer:Cancel() end
            if checkCompletionTicker then checkCompletionTicker:Cancel() end
            paused = true
            pauseButton:SetText("Reanudar")
            print("|cff00ff00[DART]|r Cronómetro pausado.")
        else
            local pausedDuration = GetTime() - pauseStartTime
            pausedTimeOffset = pausedTimeOffset + pausedDuration
            pauseStartTime = nil
            paused = false
            pauseButton:SetText("Pausar")
            print("|cff00ff00[DART]|r Cronómetro reanudado.")
            updateTimer = C_Timer.NewTicker(0.1, function()
                if startTime and timerFrame and timerFrame:IsShown() then
                    timerFrame.timeText:SetText(SecondsToTime(GetTime() - startTime - pausedTimeOffset))
                end
            end)
            checkCompletionTicker = C_Timer.NewTicker(5, CheckDungeonCompletion)
        end
    end)

    timerFrame.title = title
    timerFrame.timeText = timeText
    timerFrame.instanceText = instanceText
    timerFrame.pauseButton = pauseButton
    timerFrame.paused = function() return paused end
    timerFrame.pausedTimeOffset = function() return pausedTimeOffset end
end

-- Iniciar cronómetro
local function StartTimer(instanceName)
    currentInstance = instanceName
    startTime = GetTime()
    bossesKilled = 0
    dungeonCompleted = false

    totalBosses = GetTotalBosses()
    print("|cff00ff00[DART]|r Total de bosses en " .. instanceName .. ": " .. totalBosses)

    if timerFrame then
        timerFrame.instanceText:SetText(instanceName)
        timerFrame:Show()
        timerFrame.pauseButton:SetText("Pausar")
        -- Reset pause state variables
        local paused = false
        local pausedTimeOffset = 0
        timerFrame.paused = function() return paused end
        timerFrame.pausedTimeOffset = function() return pausedTimeOffset end
    end

    if updateTimer then updateTimer:Cancel() end
    updateTimer = C_Timer.NewTicker(0.1, function()
        if startTime and timerFrame and timerFrame:IsShown() and not timerFrame.paused() then
            timerFrame.timeText:SetText(SecondsToTime(GetTime() - startTime - timerFrame.pausedTimeOffset()))
        end
    end)

    if checkCompletionTicker then checkCompletionTicker:Cancel() end
    checkCompletionTicker = C_Timer.NewTicker(5, CheckDungeonCompletion)

    print("|cff00ff00[DART]|r Cronómetro iniciado en: " .. instanceName)
end

-- Detener cronómetro y guardar datos
function StopTimer()
    if not currentInstance or not startTime then return end

    if updateTimer then updateTimer:Cancel() end
    if checkCompletionTicker then checkCompletionTicker:Cancel() end
    if timerFrame then timerFrame:Hide() end

    if not dungeonCompleted then
        print("|cffff4444[DART]|r Cronómetro detenido - Dungeon no completado")
        currentInstance, startTime = nil, nil
        bossesKilled, dungeonCompleted = 0, false
        return
    end

    local elapsed = GetTime() - startTime

    DART_SavedTimes[currentInstance] = DART_SavedTimes[currentInstance] or { runs = {} }
    table.insert(DART_SavedTimes[currentInstance].runs, elapsed)

    local times = DART_SavedTimes[currentInstance].runs
    local sum, best = 0, times[1]
    for _, t in ipairs(times) do
        sum = sum + t
        if t < best then best = t end
    end
    local avg = sum / #times
    DART_SavedTimes[currentInstance].best = best
    DART_SavedTimes[currentInstance].avg = avg

    local isNewRecord = elapsed == best
    print(string.format("|cff00ff00[DART]|r Completaste %s en %s%s. Mejor: %s | Promedio: %s (%d runs)",
        currentInstance, SecondsToTime(elapsed),
        isNewRecord and " 🏆 ¡NUEVO RÉCORD!" or "",
        SecondsToTime(best), SecondsToTime(avg), #times))

    currentInstance, startTime = nil, nil
    bossesKilled, dungeonCompleted = 0, false
end

-- =============================================
-- POPUPS DE CONFIRMACIÓN
-- =============================================

-- Popup para confirmar guardar tiempo al salir sin completar
StaticPopupDialogs["DART_CONFIRM_SAVE_TIME"] = {
    text = "¿Quieres guardar el tiempo de esta run incompleta?",
    button1 = "Guardar",
    button2 = "Descartar",
    OnAccept = function()
        if currentInstance and startTime then
            dungeonCompleted = true
            StopTimer()
        end
    end,
    OnCancel = function()
        currentInstance, startTime = nil, nil
        bossesKilled, dungeonCompleted = 0, false
        print("|cffffaa00[DART]|r Tiempo descartado.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Popup de confirmación para limpiar
StaticPopupDialogs["DART_CONFIRM_CLEAR"] = {
    text = "¿Estás seguro que quieres borrar todas las estadísticas?",
    button1 = "Sí",
    button2 = "No",
    OnAccept = function()
        DART_SavedTimes = {}
        UpdateStatsDisplay()
        print("|cff00ff00[DART]|r Estadísticas limpiadas.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- =============================================
-- REGISTRO DE EVENTOS Y COMANDOS
-- =============================================

-- Eventos
DART:RegisterEvent("ADDON_LOADED")
DART:RegisterEvent("PLAYER_ENTERING_WORLD")
DART:RegisterEvent("PLAYER_LEAVING_WORLD")
DART:RegisterEvent("ENCOUNTER_END")
DART:RegisterEvent("CHALLENGE_MODE_COMPLETED")
DART:RegisterEvent("LFG_COMPLETION_REWARD")

DART:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4, arg5)
    if event == "ADDON_LOADED" and arg1 == addonName then
        CreateTimerFrame()
        CreateStatsFrame()
        print("|cff00ff00[DART]|r Addon cargado. Usa /dart help para ver comandos.")

        SLASH_DART1, SLASH_DART2 = "/dart", "/dungeonraid"
        SlashCmdList["DART"] = function(msg)
            local cmd = string.lower(msg or "")
            if cmd == "complete" and currentInstance then
                dungeonCompleted = true
                StopTimer()
            elseif cmd == "clear" then
                StaticPopup_Show("DART_CONFIRM_CLEAR")
            elseif cmd == "stats" then
                UpdateStatsDisplay()
                statsFrame:Show()
            elseif cmd == "best" then
                ShowBestTimesOnly()
                statsFrame:Show()
            elseif cmd == "toggle" then
                if timerFrame then
                    if timerFrame:IsShown() then
                        timerFrame:Hide()
                    else
                        timerFrame:Show()
                    end
                end
            elseif cmd == "help" or cmd == "" then
                print("|cff00ff00[DART]|r Comandos disponibles:")
                print("  /dart stats - Mostrar estadísticas completas")
                print("  /dart best - Mostrar solo mejores tiempos")
                print("  /dart toggle - Mostrar/ocultar cronómetro")
                print("  /dart complete - Marcar run como completada manualmente")
                print("  /dart clear - Limpiar todas las estadísticas")
                print("  /dart help - Mostrar esta ayuda")
            else
                print("|cff00ff00[DART]|r Comando desconocido. Usa /dart help para ver comandos.")
            end
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        local instanceName, instanceType = GetInstanceInfo()
        if instanceType == "party" or instanceType == "raid" then
            StartTimer(instanceName)
        end

    elseif event == "ENCOUNTER_END" then
        local encounterID, encounterName, _, _, success = arg1, arg2, arg3, arg4, arg5
        if success and currentInstance then
            bossesKilled = bossesKilled + 1
            print("|cff00ff00[DART]|r Jefe derrotado: " .. encounterName .. " (" .. bossesKilled .. " de " .. totalBosses .. " jefes)")
            CheckDungeonCompletion()
        end

    elseif event == "CHALLENGE_MODE_COMPLETED" or event == "LFG_COMPLETION_REWARD" then
        if currentInstance then
            dungeonCompleted = true
            print("|cff00ff00[DART]|r ¡Instancia completada automáticamente!")
            StopTimer()
        end

    elseif event == "PLAYER_LEAVING_WORLD" then
        if updateTimer then updateTimer:Cancel() end
        if checkCompletionTicker then checkCompletionTicker:Cancel() end
        if timerFrame then timerFrame:Hide() end

        if currentInstance and not dungeonCompleted and startTime then
            StaticPopup_Show("DART_CONFIRM_SAVE_TIME")
        else
            currentInstance, startTime = nil, nil
            bossesKilled, dungeonCompleted = 0, false
        end
    end
end)