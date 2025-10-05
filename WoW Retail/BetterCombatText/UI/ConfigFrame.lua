-- ConfigFrame.lua - Configuration interface
local addonName = "BetterCombatText"

-- Ensure global namespace exists
if not _G[addonName] then
    _G[addonName] = {}
end
local BCT = _G[addonName]

BCT.configFrame = nil

-- Create configuration frame
function BCT:CreateConfigFrame()
    if self.configFrame then 
        self.configFrame:Show()
        return 
    end
    
    local currentTheme = self.Themes[self.config.theme]
    
    local frame = CreateFrame("Frame", "BCT_ConfigFrame", UIParent, "BackdropTemplate")
    frame:SetSize(500, 600)
    frame:SetPoint("CENTER", UIParent, "CENTER", 100, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(unpack(currentTheme.background))
    frame:SetBackdropBorderColor(unpack(currentTheme.border))

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -20)
    title:SetText("Better Combat Text Configuration")
    title:SetTextColor(unpack(currentTheme.accent))

    -- Create tabs
    local tabs = {"General", "Display", "Themes"}
    local tabFrames = {}
    local tabButtons = {}

    for i, tabName in ipairs(tabs) do
        local tabButton = CreateFrame("Button", nil, frame, "BackdropTemplate")
        tabButton:SetSize(120, 30)
        tabButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 20 + (i-1) * 125, -50)
        tabButton:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        
        local tabText = tabButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tabText:SetPoint("CENTER")
        tabText:SetText(tabName)
        
        local tabFrame = CreateFrame("Frame", nil, frame)
        tabFrame:SetSize(460, 480)
        tabFrame:SetPoint("TOP", frame, "TOP", 0, -90)
        tabFrame:Hide()
        
        tabButton:SetScript("OnClick", function()
            for _, f in pairs(tabFrames) do
                f:Hide()
            end
            for _, btn in pairs(tabButtons) do
                btn:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
            end
            tabFrame:Show()
            tabButton:SetBackdropColor(0.3, 0.6, 0.9, 0.8)
        end)
        
        tabButtons[i] = tabButton
        tabFrames[i] = tabFrame
        
        if i == 1 then
            tabButton:SetBackdropColor(0.3, 0.6, 0.9, 0.8)
            tabFrame:Show()
        else
            tabButton:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
        end
    end

    -- Create tab contents
    self:CreateGeneralTab(tabFrames[1])
    self:CreateDisplayTab(tabFrames[2])
    self:CreateThemesTab(tabFrames[3])

    -- Close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() frame:Hide() end)

    frame:Hide()
    self.configFrame = frame
end

-- General tab
function BCT:CreateGeneralTab(parent)
    local yOffset = -20
    
    -- Enable
    local enableCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    enableCheck:SetChecked(self.config.enabled)
    enableCheck.text = enableCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableCheck.text:SetPoint("LEFT", enableCheck, "RIGHT", 5, 0)
    enableCheck.text:SetText("Enable Better Combat Text")
    enableCheck:SetScript("OnClick", function(self)
        BCT.config.enabled = self:GetChecked()
    end)
    yOffset = yOffset - 40

    -- Show Damage
    local damageCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    damageCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    damageCheck:SetChecked(self.config.showDamage)
    damageCheck.text = damageCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    damageCheck.text:SetPoint("LEFT", damageCheck, "RIGHT", 5, 0)
    damageCheck.text:SetText("Show Damage Numbers")
    damageCheck:SetScript("OnClick", function(self)
        BCT.config.showDamage = self:GetChecked()
    end)
    yOffset = yOffset - 30

    -- Show Healing
    local healingCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    healingCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    healingCheck:SetChecked(self.config.showHealing)
    healingCheck.text = healingCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    healingCheck.text:SetPoint("LEFT", healingCheck, "RIGHT", 5, 0)
    healingCheck.text:SetText("Show Healing Numbers")
    healingCheck:SetScript("OnClick", function(self)
        BCT.config.showHealing = self:GetChecked()
    end)
    yOffset = yOffset - 40

    -- Font Size
    local fontLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fontLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    fontLabel:SetText("Font Size: " .. self.config.fontSize)
    
    local fontSlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    fontSlider:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -10)
    fontSlider:SetMinMaxValues(10, 30)
    fontSlider:SetValue(self.config.fontSize)
    fontSlider:SetValueStep(1)
    fontSlider:SetWidth(200)
    fontSlider:SetHeight(20)
    
    fontSlider:SetScript("OnValueChanged", function(self, value)
        BCT.config.fontSize = math.floor(value)
        fontLabel:SetText("Font Size: " .. BCT.config.fontSize)
    end)
    yOffset = yOffset - 80

    -- Animation Speed
    local speedLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    speedLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    speedLabel:SetText("Animation Speed: " .. string.format("%.1f", self.config.animationSpeed))
    
    local speedSlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    speedSlider:SetPoint("TOPLEFT", speedLabel, "BOTTOMLEFT", 0, -10)
    speedSlider:SetMinMaxValues(0.5, 2.0)
    speedSlider:SetValue(self.config.animationSpeed)
    speedSlider:SetValueStep(0.1)
    speedSlider:SetWidth(200)
    speedSlider:SetHeight(20)
    
    speedSlider:SetScript("OnValueChanged", function(self, value)
        BCT.config.animationSpeed = value
        speedLabel:SetText("Animation Speed: " .. string.format("%.1f", value))
    end)
    yOffset = yOffset - 80

    -- Sound Effects
    local soundCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    soundCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    soundCheck:SetChecked(self.config.soundEnabled)
    soundCheck.text = soundCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    soundCheck.text:SetPoint("LEFT", soundCheck, "RIGHT", 5, 0)
    soundCheck.text:SetText("Enable Sound Effects")
    soundCheck:SetScript("OnClick", function(self)
        BCT.config.soundEnabled = self:GetChecked()
    end)
end

-- Display tab
function BCT:CreateDisplayTab(parent)
    local yOffset = -20
    
    -- Escala de números (NUEVO)
    -- Inicializar si no existe
    if not self.config.textScale then
        self.config.textScale = 1.0
    end
    
    local scaleLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    scaleLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    scaleLabel:SetText("Escala de Números:")
    scaleLabel:SetTextColor(1, 0.82, 0, 1)
    
    local scaleValue = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scaleValue:SetPoint("LEFT", scaleLabel, "RIGHT", 10, 0)
    scaleValue:SetText(string.format("%.1fx", self.config.textScale))
    yOffset = yOffset - 30
    
    local scaleSlider = CreateFrame("Slider", "BCT_ScaleSlider", parent, "OptionsSliderTemplate")
    scaleSlider:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    scaleSlider:SetMinMaxValues(0.5, 3.0)
    scaleSlider:SetValue(self.config.textScale)
    scaleSlider:SetValueStep(0.1)
    scaleSlider:SetWidth(300)
    scaleSlider:SetHeight(20)
    
    local sliderName = scaleSlider:GetName()
    if sliderName then
        _G[sliderName.."Low"]:SetText("0.5x")
        _G[sliderName.."High"]:SetText("3.0x")
        _G[sliderName.."Text"]:SetText("")
    end
    
    scaleSlider:SetScript("OnValueChanged", function(s, value)
        value = math.floor(value * 10 + 0.5) / 10
        BCT.config.textScale = value
        scaleValue:SetText(string.format("%.1fx", value))
    end)
    yOffset = yOffset - 30
    
    -- Botón de prueba de escala
    local testScaleButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    testScaleButton:SetSize(150, 30)
    testScaleButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    testScaleButton:SetText("Probar Escala")
    testScaleButton:SetScript("OnClick", function()
        local scale = BCT.config.textScale or 1.0
        local testAmount = math.random(1000, 5000)
        BCT:DisplayFloatingText(
            tostring(testAmount),
            BCT.Colors.critDamage or {1, 0.5, 0},
            BCT.config.fontSize * scale,
            true,
            false,
            false,
            false
        )
        print("|cff00ff00BCT:|r Probando escala " .. string.format("%.1fx", scale) .. " con número " .. testAmount)
    end)
    yOffset = yOffset - 50
    
    -- Separador
    local separator = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    separator:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    separator:SetText("─────────────────────────────")
    separator:SetTextColor(0.5, 0.5, 0.5, 1)
    yOffset = yOffset - 30
    
    -- Compact Mode
    local compactCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    compactCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    compactCheck:SetChecked(self.config.compactMode)
    compactCheck.text = compactCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    compactCheck.text:SetPoint("LEFT", compactCheck, "RIGHT", 5, 0)
    compactCheck.text:SetText("Compact Mode")
    compactCheck:SetScript("OnClick", function(self)
        BCT.config.compactMode = self:GetChecked()
    end)
    yOffset = yOffset - 30

    -- Show Icons
    local iconsCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    iconsCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    iconsCheck:SetChecked(self.config.showIcons)
    iconsCheck.text = iconsCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    iconsCheck.text:SetPoint("LEFT", iconsCheck, "RIGHT", 5, 0)
    iconsCheck.text:SetText("Show Spell Icons")
    iconsCheck:SetScript("OnClick", function(self)
        BCT.config.showIcons = self:GetChecked()
    end)
    yOffset = yOffset - 30

    -- Show Background
    local bgCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    bgCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    bgCheck:SetChecked(self.config.showBackground)
    bgCheck.text = bgCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bgCheck.text:SetPoint("LEFT", bgCheck, "RIGHT", 5, 0)
    bgCheck.text:SetText("Show Panel Background")
    bgCheck:SetScript("OnClick", function(self)
        BCT.config.showBackground = self:GetChecked()
        if BCT.combatLogFrame and BCT.combatLogFrame.updateTheme then
            BCT.combatLogFrame.updateTheme()
        end
    end)
    yOffset = yOffset - 40

    -- Opacity
    local opacityLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    opacityLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    opacityLabel:SetText("Opacity: " .. string.format("%.0f%%", self.config.opacity * 100))
    
    local opacitySlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    opacitySlider:SetPoint("TOPLEFT", opacityLabel, "BOTTOMLEFT", 0, -10)
    opacitySlider:SetMinMaxValues(0.3, 1.0)
    opacitySlider:SetValue(self.config.opacity)
    opacitySlider:SetValueStep(0.05)
    opacitySlider:SetWidth(200)
    opacitySlider:SetHeight(20)
    
    opacitySlider:SetScript("OnValueChanged", function(self, value)
        BCT.config.opacity = value
        opacityLabel:SetText("Opacity: " .. string.format("%.0f%%", value * 100))
        if BCT.combatLogFrame then
            BCT.combatLogFrame:SetAlpha(value)
        end
    end)
    yOffset = yOffset - 80

    -- Max Numbers
    local maxLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    maxLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    maxLabel:SetText("Max Floating Numbers: " .. self.config.maxNumbers)
    
    local maxSlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    maxSlider:SetPoint("TOPLEFT", maxLabel, "BOTTOMLEFT", 0, -10)
    maxSlider:SetMinMaxValues(10, 50)
    maxSlider:SetValue(self.config.maxNumbers)
    maxSlider:SetValueStep(5)
    maxSlider:SetWidth(200)
    maxSlider:SetHeight(20)
    
    maxSlider:SetScript("OnValueChanged", function(self, value)
        BCT.config.maxNumbers = math.floor(value)
        maxLabel:SetText("Max Floating Numbers: " .. BCT.config.maxNumbers)
    end)
    yOffset = yOffset - 80

    -- Auto Hide
    local autoHideCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    autoHideCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    autoHideCheck:SetChecked(self.config.autoHide)
    autoHideCheck.text = autoHideCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    autoHideCheck.text:SetPoint("LEFT", autoHideCheck, "RIGHT", 5, 0)
    autoHideCheck.text:SetText("Auto-Hide Combat Log")
    autoHideCheck:SetScript("OnClick", function(self)
        BCT.config.autoHide = self:GetChecked()
    end)
end

-- Themes tab
function BCT:CreateThemesTab(parent)
    local yOffset = -20
    
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", parent, "TOP", 0, yOffset)
    title:SetText("Theme Selection")
    title:SetTextColor(1, 1, 0, 1)
    yOffset = yOffset - 40

    -- Theme buttons
    local themeNames = {"dark", "light", "custom"}
    local themeButtons = {}
    
    for i, themeName in ipairs(themeNames) do
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(120, 40)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20 + (i-1) * 130, yOffset)
        btn:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        
        local theme = BCT.Themes[themeName]
        btn:SetBackdropColor(unpack(theme.background))
        btn:SetBackdropBorderColor(unpack(theme.border))
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        btnText:SetPoint("CENTER")
        btnText:SetText(string.upper(string.sub(themeName, 1, 1)) .. string.sub(themeName, 2))
        btnText:SetTextColor(unpack(theme.title))
        
        btn:SetScript("OnClick", function(self)
            BCT.config.theme = themeName
            for _, b in pairs(themeButtons) do
                b:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
            end
            self:SetBackdropBorderColor(1, 1, 0, 1)
            
            -- Update combat log theme
            if BCT.combatLogFrame and BCT.combatLogFrame.updateTheme then
                BCT.combatLogFrame.updateTheme()
            end
            
            print("|cff00ff00BCT:|r Theme changed to " .. themeName)
        end)
        
        -- Highlight current theme
        if self.config.theme == themeName then
            btn:SetBackdropBorderColor(1, 1, 0, 1)
        end
        
        themeButtons[i] = btn
    end
    
    yOffset = yOffset - 80
    
    -- Theme preview
    local previewLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    previewLabel:SetText("Preview:")
    yOffset = yOffset - 30
    
    local previewFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    previewFrame:SetSize(400, 200)
    previewFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, yOffset)
    previewFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    local currentTheme = self.Themes[self.config.theme]
    previewFrame:SetBackdropColor(unpack(currentTheme.background))
    previewFrame:SetBackdropBorderColor(unpack(currentTheme.border))
    
    local previewText = previewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewText:SetPoint("CENTER")
    previewText:SetText("Theme Preview\n\nThis is how panels will look")
    previewText:SetTextColor(unpack(currentTheme.text))
end

-- Show config frame
function BCT:ShowConfigFrame()
    if not self.configFrame then
        self:CreateConfigFrame()
    end
    if self.configFrame then
        self.configFrame:Show()
    end
end