-- BloodHunt User Interface
local BH = BloodHunt

-- Variables de UI
local mainFrame = nil
local targetFrames = {}
local isUIVisible = false

-- Crear interfaz principal
function BH:CreateUI()
    if mainFrame then return end
    
    -- Frame principal
    mainFrame = CreateFrame("Frame", "BloodHuntMainFrame", UIParent, "BackdropTemplate")
    mainFrame:SetSize(280, 200)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", 300, 100)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    
    -- Backdrop
    mainFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    mainFrame:SetBackdropColor(0, 0, 0, 0.8)
    
    -- Título
    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", mainFrame, "TOP", 0, -15)
    title:SetText("|cffff0000Blood|r|cff00ff00Hunt|r")
    
    -- Botón cerrar
    local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        BH:HideUI()
    end)
    
    -- Información de puntos
    local pointsText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    pointsText:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -40)
    pointsText:SetText("Puntos totales: 0")
    mainFrame.pointsText = pointsText
    
    -- Crear frames para objetivos
    for i = 1, 3 do
        local targetFrame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
        targetFrame:SetSize(250, 35)
        targetFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -60 - (i-1) * 40)
        
        targetFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        targetFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        targetFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        
        -- Texto del objetivo
        local targetText = targetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        targetText:SetPoint("LEFT", targetFrame, "LEFT", 8, 0)
        targetText:SetText("Objetivo " .. i .. ": Esperando...")
        targetFrame.text = targetText
        
        -- Icono de venganza
        local vengeanceIcon = targetFrame:CreateTexture(nil, "OVERLAY")
        vengeanceIcon:SetSize(16, 16)
        vengeanceIcon:SetPoint("RIGHT", targetFrame, "RIGHT", -8, 0)
        vengeanceIcon:SetTexture("Interface\\Icons\\Ability_Warrior_Revenge")
        vengeanceIcon:Hide()
        targetFrame.vengeanceIcon = vengeanceIcon
        
        targetFrames[i] = targetFrame
    end
    
    self.frame = mainFrame
end

-- Mostrar UI
function BH:ShowUI()
    if not BloodHuntDB.settings.uiEnabled then return end
    
    if not mainFrame then
        self:CreateUI()
    end
    
    mainFrame:Show()
    isUIVisible = true
    self:UpdateUI()
end

-- Ocultar UI
function BH:HideUI()
    if mainFrame then
        mainFrame:Hide()
    end
    isUIVisible = false
end

-- Actualizar UI
function BH:UpdateUI()
    if not mainFrame or not isUIVisible then return end
    
    -- Actualizar puntos
    mainFrame.pointsText:SetText("Puntos totales: " .. self.totalPoints)
    
    -- Actualizar objetivos
    for i = 1, 3 do
        local targetFrame = targetFrames[i]
        local target = self.activeTargets[i]
        
        if target then
            local color = target.isVengeance and "|cffff0000" or "|cffffffff"
            local multiplierText = target.multiplier > 1 and " (x" .. target.multiplier .. ")" or ""
            
            targetFrame.text:SetText(color .. target.name .. "|r - " .. target.totalPoints .. " pts" .. multiplierText)
            
            if target.isVengeance then
                targetFrame.vengeanceIcon:Show()
                targetFrame:SetBackdropColor(0.3, 0.1, 0.1, 0.8)
                targetFrame:SetBackdropBorderColor(1, 0.2, 0.2, 1)
            else
                targetFrame.vengeanceIcon:Hide()
                targetFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
                targetFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
            end
        else
            targetFrame.text:SetText("|cff888888Objetivo " .. i .. ": Esperando...|r")
            targetFrame.vengeanceIcon:Hide()
            targetFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            targetFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        end
    end
end

-- Toggle UI
function BH:ToggleUI()
    if isUIVisible then
        self:HideUI()
    else
        self:ShowUI()
    end
end
