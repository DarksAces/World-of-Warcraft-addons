-- CombatLog.lua - Combat log display panel
local addonName = "BetterCombatText"

-- Ensure global namespace exists
if not _G[addonName] then
    _G[addonName] = {}
end
local BCT = _G[addonName]

BCT.combatLogFrame = BCT.combatLogFrame or nil
BCT.combatLogData = BCT.combatLogData or {}
BCT.maxLogEntries = 200

-- Función para actualizar el layout y el tamaño de los componentes
local function updateLayout(frame, titleBar, statsPanel, contentFrame, scrollFrame, width, height)
    titleBar:SetWidth(width)
    statsPanel:SetWidth(width - 20)
    contentFrame:SetWidth(width - 65)
    
    -- Ajuste del ScrollFrame: se ancla a la parte inferior del frame principal
    scrollFrame:SetPoint("TOPLEFT", statsPanel, "BOTTOMLEFT", 15, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -45, 20)
    
    BCT:UpdateCombatLogDisplay()
end

-- Create combat log panel
function BCT:CreateCombatLogPanel()
    if self.combatLogFrame then return end
    
    local currentTheme = self.Themes[self.config.theme]
    
    -- 1. CREACIÓN DEL FRAME PRINCIPAL
    local frame = CreateFrame("Frame", "BCT_CombatLogFrame", UIParent, "BackdropTemplate")
    
    local w, h = self.config.logPanelW, self.config.logPanelH
    local x, y = self.config.logPanelX, self.config.logPanelY
    
    frame:SetSize(w, h)
    frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self.StopMovingOrSizing(self)
        local _, _, _, px, py = self:GetPoint()
        BCT.config.logPanelX = px
        BCT.config.logPanelY = py
    end)

    frame:SetResizable(true)

    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Lógica de Temas
    local function updateTheme()
        local theme = BCT.Themes[BCT.config.theme]
        if BCT.config.showBackground then
            frame:SetBackdropColor(unpack(theme.background))
            frame:SetBackdropBorderColor(unpack(theme.border))
        else
            frame:SetBackdropColor(0, 0, 0, 0)
            frame:SetBackdropBorderColor(0, 0, 0, 0)
        end
        frame:SetAlpha(BCT.config.opacity)
    end
    
    frame.updateTheme = updateTheme
    updateTheme()

    -- 2. CREACIÓN DE COMPONENTES INTERNOS (EN ORDEN)
    
    -- Título
    local titleBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    titleBar:SetHeight(40)
    titleBar:SetPoint("TOP", frame, "TOP", 0, 0)
    
    titleBar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    titleBar:SetBackdropColor(unpack(currentTheme.accent))

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 15, 0)
    titleText:SetText("Combat Damage Log")
    titleText:SetTextColor(unpack(currentTheme.title))
    titleText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")

    -- Botones (Creación simplificada)
    local closeButton = BCT:CreateStyledButton(titleBar, "X", 30, 30)
    closeButton:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() 
        frame:Hide()
        if BCT.config.autoHide then
            BCT:ScheduleAutoHide()
        end
    end)

    local clearButton = BCT:CreateStyledButton(titleBar, "Clear", 70, 30)
    clearButton:SetPoint("TOPRIGHT", closeButton, "TOPLEFT", -5, 0)
    clearButton:SetScript("OnClick", function() 
        BCT.combatLogData = {}
        BCT:UpdateCombatLogDisplay()
        print("|cff00ff00BCT:|r Combat log cleared")
    end)

    local configButton = BCT:CreateStyledButton(titleBar, "Config", 70, 30)
    configButton:SetPoint("TOPRIGHT", clearButton, "TOPLEFT", -5, 0)
    configButton:SetScript("OnClick", function() 
        BCT:ShowConfigFrame()
    end)

    -- Panel de Estadísticas (Stats panel)
    local statsPanel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    statsPanel:SetHeight(40)
    statsPanel:SetPoint("TOP", titleBar, "BOTTOM", 0, -5)
    statsPanel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    statsPanel:SetBackdropColor(0.1, 0.1, 0.1, 0.6)

    -- Textos de Estadísticas (DPS, Total, Max)
    local dpsText = statsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dpsText:SetPoint("TOPLEFT", statsPanel, "TOPLEFT", 15, -15)
    dpsText:SetText("DPS: 0")
    dpsText:SetTextColor(1, 1, 0, 1)
    dpsText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    local totalText = statsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    totalText:SetPoint("TOP", statsPanel, "TOP", 0, -15)
    totalText:SetText("Total: 0")
    totalText:SetTextColor(0, 1, 0, 1)
    totalText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    local maxText = statsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    maxText:SetPoint("TOPRIGHT", statsPanel, "TOPRIGHT", -15, -15)
    maxText:SetText("Max: 0")
    maxText:SetTextColor(1, 0.5, 0, 1)
    maxText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    frame.statsPanel = {
        dps = dpsText,
        total = totalText, -- Asumiendo que estas variables existen
        max = maxText      -- Asumiendo que estas variables existen
    }

    -- Scroll frame y Content Frame
    local scrollFrame = CreateFrame("ScrollFrame", "BCT_ScrollFrame", frame, "UIPanelScrollFrameTemplate")
    
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(w - 65, 1)
    contentFrame.fontStrings = {}
    scrollFrame:SetScrollChild(contentFrame)

    frame.scrollFrame = scrollFrame
    frame.contentFrame = contentFrame

    -- *************** INSERCIÓN DE CÓDIGO FALTANTE ***************
    -- Resize handle (CREACIÓN CORRECTA)
    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetSize(25, 25)
    resizeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    resizeButton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")
    
    local MIN_WIDTH, MIN_HEIGHT = 450, 400
    local MAX_WIDTH, MAX_HEIGHT = 1000, 900

    -- Lógica de OnMouseDown (Donde fallaba la indexación)
    resizeButton:SetScript("OnMouseDown", function(self)
        frame:StartSizing("BOTTOMRIGHT")
    end)
    -- ************************************************************

    -- Lógica de Guardado y Layout en OnMouseUp
    resizeButton:SetScript("OnMouseUp", function(self)
        frame:StopMovingOrSizing()
        
        local width, height = frame:GetSize()
        local newWidth = math.min(math.max(width, MIN_WIDTH), MAX_WIDTH)
        local newHeight = math.min(math.max(height, MIN_HEIGHT), MAX_HEIGHT)
        
        if width ~= newWidth or height ~= newHeight then
            frame:SetSize(newWidth, newHeight)
        end
        
        -- Save new size
        BCT.config.logPanelW = newWidth
        BCT.config.logPanelH = newHeight
        
        -- Llamada a updateLayout con todos los frames
        updateLayout(frame, titleBar, statsPanel, contentFrame, scrollFrame, newWidth, newHeight)
    end)

    -- 3. LLAMADA INICIAL AL LAYOUT (AL FINAL)
    updateLayout(frame, titleBar, statsPanel, contentFrame, scrollFrame, w, h)

    frame:Hide()
    self.combatLogFrame = frame
end

-- Update combat log display (omitiendo por brevedad, sin cambios)
function BCT:UpdateCombatLogDisplay()
    if not self.combatLogFrame or not self.combatLogFrame.contentFrame then return end
    
    local contentFrame = self.combatLogFrame.contentFrame
    local currentTheme = self.Themes[self.config.theme]
    
    -- Clear existing
    if contentFrame.fontStrings then
        for _, fs in ipairs(contentFrame.fontStrings) do
            if fs and fs.Hide then
                fs:Hide()
            end
        end
    end
    contentFrame.fontStrings = {}
    
    local yOffset = -5
    local maxEntries = self.config.compactMode and 120 or 90
    local entryHeight = self.config.compactMode and 14 or 20
    
    -- Calculate stats
    local totalDamage = 0
    local maxHit = 0
    local combatStart = nil
    
    for i, entry in ipairs(self.combatLogData) do
        if i > maxEntries then break end
        
        if not combatStart then combatStart = entry.timestamp end
        
        if not entry.isHealing then
            totalDamage = totalDamage + entry.amount
        end
        
        if entry.amount > maxHit then
            maxHit = entry.amount
        end
        
        -- Create entry
        local entryFrame = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
        entryFrame:SetSize(400, entryHeight)
        entryFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, yOffset)
        
        if i % 2 == 0 then
            entryFrame:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                tile = true, tileSize = 16,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            entryFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.3)
        end
        
        -- Time
        local timeText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        timeText:SetPoint("LEFT", entryFrame, "LEFT", 8, 0)
        timeText:SetText(entry.time or "00:00:00")
        timeText:SetTextColor(0.7, 0.7, 0.7, 1)
        timeText:SetFont("Fonts\\FRIZQT__.TTF", self.config.compactMode and 11 or 12, "OUTLINE")
        
        -- Amount
        local amountText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        amountText:SetPoint("LEFT", timeText, "RIGHT", 15, 0)
        
        local prefix = entry.isHealing and "+" or ""
        local suffix = ""
        if entry.isCrit then suffix = suffix .. " *" end
        if entry.isOverkill then suffix = suffix .. " !" end
        
        amountText:SetText(prefix .. self:FormatNumber(entry.amount) .. suffix)
        
        if entry.isHealing then
            amountText:SetTextColor(0, 1, 0.3, 1)
        elseif entry.isOutgoing then
            if entry.isCrit then
                amountText:SetTextColor(1, 0.6, 0, 1)
            elseif entry.isOverkill then
                amountText:SetTextColor(1, 0, 1, 1)
            else
                amountText:SetTextColor(1, 1, 0.2, 1)
            end
        else
            amountText:SetTextColor(1, 0.2, 0.2, 1)
        end
        amountText:SetFont("Fonts\\FRIZQT__.TTF", self.config.compactMode and 12 or 13, "OUTLINE")
        
        -- Type
        local directionText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        directionText:SetPoint("LEFT", amountText, "RIGHT", 20, 0)
        local direction = entry.isOutgoing and ">" or "<"
        directionText:SetText(direction .. " " .. (entry.damageType or "Unknown"))
        directionText:SetTextColor(unpack(currentTheme.text))
        directionText:SetFont("Fonts\\FRIZQT__.TTF", self.config.compactMode and 10 or 11, "OUTLINE")
        
        table.insert(contentFrame.fontStrings, entryFrame)
        table.insert(contentFrame.fontStrings, timeText)
        table.insert(contentFrame.fontStrings, amountText)
        table.insert(contentFrame.fontStrings, directionText)
        
        yOffset = yOffset - entryHeight
    end
    
    -- Update stats
    if self.combatLogFrame.statsPanel then
        local combatTime = combatStart and (GetTime() - combatStart) or 0
        local dps = 0
        
        if combatTime > 0 and totalDamage > 0 then
            dps = totalDamage / combatTime
        end
        
        local dpsString = "DPS: " .. (dps > 0 and self:FormatNumber(math.floor(dps)) or "0")
        
        self.combatLogFrame.statsPanel.dps:SetText(dpsString)
        self.combatLogFrame.statsPanel.total:SetText("Total: " .. self:FormatNumber(totalDamage))
        self.combatLogFrame.statsPanel.max:SetText("Max: " .. self:FormatNumber(maxHit))
    end
    
    contentFrame:SetHeight(math.max(150, math.abs(yOffset) + 30))
end

-- Add to combat log (omitiendo por brevedad, sin cambios)
function BCT:AddToCombatLog(amount, damageType, isCrit, isOverkill, isHealing, isOutgoing)
    local timestamp = GetTime()
    local entry = {
        amount = amount,
        damageType = damageType or "Unknown",
        isCrit = isCrit,
        isOverkill = isOverkill,
        isHealing = isHealing,
        isOutgoing = isOutgoing,
        timestamp = timestamp,
        time = date("%H:%M:%S", timestamp)
    }
    
    table.insert(self.combatLogData, 1, entry)
    
    if #self.combatLogData > self.maxLogEntries then
        table.remove(self.combatLogData, self.maxLogEntries + 1)
    end
    
    if self.combatLogFrame and self.combatLogFrame:IsShown() then
        self:UpdateCombatLogDisplay()
    end
end

-- Toggle combat log (omitiendo por brevedad, sin cambios)
function BCT:ToggleCombatLogPanel()
    if not self.combatLogFrame then 
        self:CreateCombatLogPanel()
    end
    
    if self.combatLogFrame:IsShown() then
        self.combatLogFrame:Hide()
    else
        self.combatLogFrame:Show()
        self:UpdateCombatLogDisplay()
        if self.config.autoHide then
            self:ScheduleAutoHide()
        end
    end
end

-- Schedule auto-hide (omitiendo por brevedad, sin cambios)
function BCT:ScheduleAutoHide()
    if not self.combatLogFrame or not self.config.autoHide then return end
    
    self.combatLogFrame.hideTimer = self.config.autoHideDelay
    if not self.combatLogFrame:GetScript("OnUpdate") then
        self.combatLogFrame:SetScript("OnUpdate", function(self, elapsed)
            if not self.hideTimer then return end
            self.hideTimer = self.hideTimer - elapsed
            if self.hideTimer <= 0 then
                self:Hide()
                self.hideTimer = nil
                self:SetScript("OnUpdate", nil)
            end
        end)
    end
end