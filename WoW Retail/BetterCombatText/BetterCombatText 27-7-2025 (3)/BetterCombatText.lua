-- Better Combat Text Addon for World of Warcraft
-- Enhanced UI with modern design and improved functionality
-- Version without minimap button

local addonName = "BetterCombatText"

-- Enhanced Configuration (removed minimap button option)
local config = {
    enabled = true,
    showDamage = true,
    showHealing = true,
    showPvP = true,
    animationSpeed = 1.2,
    fontSize = 16,
    critMultiplier = 1.5,
    killBlowMultiplier = 2.0,
    fadeTime = 1.5,
    maxNumbers = 20,
    groupingThreshold = 5,
    groupingTime = 2.0,
    showBackground = true,
    theme = "dark", -- dark, light, custom
    opacity = 0.85,
    soundEnabled = true,
    showIcons = true,
    compactMode = false,
    autoHide = false,
    autoHideDelay = 5.0
}

-- Enhanced Color schemes with themes
local themes = {
    dark = {
        background = {0, 0, 0, 0.85},
        border = {0.3, 0.3, 0.3, 1},
        title = {1, 1, 1, 1},
        text = {0.9, 0.9, 0.9, 1},
        accent = {0.2, 0.6, 1, 1}
    },
    light = {
        background = {0.95, 0.95, 0.95, 0.9},
        border = {0.6, 0.6, 0.6, 1},
        title = {0.1, 0.1, 0.1, 1},
        text = {0.2, 0.2, 0.2, 1},
        accent = {0.1, 0.4, 0.8, 1}
    },
    custom = {
        background = {0.1, 0.1, 0.2, 0.8},
        border = {0.4, 0.2, 0.6, 1},
        title = {0.8, 0.6, 1, 1},
        text = {0.9, 0.8, 1, 1},
        accent = {0.6, 0.3, 0.9, 1}
    }
}

local colors = {
    damage = {1, 1, 0, 1},
    critDamage = {1, 0.5, 0, 1},
    healing = {0, 1, 0, 1},
    critHealing = {0, 1, 0.5, 1},
    damageTaken = {1, 0, 0, 1},
    physical = {1, 0.8, 0.4, 1},
    magic = {0.4, 0.8, 1, 1},
    fire = {1, 0.2, 0.2, 1},
    frost = {0.5, 0.8, 1, 1},
    nature = {0.3, 1, 0.3, 1},
    shadow = {0.7, 0.3, 1, 1},
    holy = {1, 1, 0.8, 1},
    pvpDamage = {1, 0.3, 0.3, 1},
    overkill = {1, 0, 1, 1}
}

-- UI Frames
local activeTexts = {}
local textPool = {}
local damageGroups = {}
local combatLogFrame = nil
local configFrame = nil
local combatLogData = {}
local maxLogEntries = 200

-- Create the main addon frame
local BCT = CreateFrame("Frame", addonName)

-- Enhanced floating text with better animations and cleanup
function BCT:CreateFloatingText()
    local text = CreateFrame("Frame", nil, UIParent)
    text:SetSize(300, 80)
    text.fontString = text:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text.fontString:SetPoint("CENTER")
    text.fontString:SetFont("Fonts\\FRIZQT__.TTF", config.fontSize, "OUTLINE")
    text.fontString:SetShadowOffset(2, -2)
    text.fontString:SetShadowColor(0, 0, 0, 0.8)
    
    -- Enhanced animation groups
    text.animGroup = text:CreateAnimationGroup()
    text.moveAnim = text.animGroup:CreateAnimation("Translation")
    text.fadeAnim = text.animGroup:CreateAnimation("Alpha")
    text.scaleAnim = text.animGroup:CreateAnimation("Scale")
    
    -- Icon support
    text.icon = text:CreateTexture(nil, "OVERLAY")
    text.icon:SetSize(20, 20)
    text.icon:SetPoint("LEFT", text.fontString, "RIGHT", 5, 0)
    text.icon:Hide()
    
    -- Auto-cleanup timer to prevent stuck numbers
    text.cleanupTimer = 0
    text.maxLifetime = 10  -- Maximum 10 seconds before forced cleanup
    
    text:Hide()
    return text
end

-- Enhanced Combat Log Panel with modern design
function BCT:CreateCombatLogPanel()
    if combatLogFrame then return end
    
    local currentTheme = themes[config.theme]
    
    -- Main frame with enhanced styling
    combatLogFrame = CreateFrame("Frame", "BCT_CombatLogFrame", UIParent, "BackdropTemplate")
    combatLogFrame:SetSize(500, 650)  -- Increased default size
    combatLogFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    combatLogFrame:SetMovable(true)
    combatLogFrame:EnableMouse(true)
    combatLogFrame:RegisterForDrag("LeftButton")
    combatLogFrame:SetScript("OnDragStart", combatLogFrame.StartMoving)
    combatLogFrame:SetScript("OnDragStop", combatLogFrame.StopMovingOrSizing)
    combatLogFrame:SetResizable(true)

    -- Enhanced backdrop with theme support
    combatLogFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Function to update theme
    local function updateTheme()
        local theme = themes[config.theme]
        if config.showBackground then
            combatLogFrame:SetBackdropColor(unpack(theme.background))
            combatLogFrame:SetBackdropBorderColor(unpack(theme.border))
        else
            combatLogFrame:SetBackdropColor(0, 0, 0, 0)
            combatLogFrame:SetBackdropBorderColor(0, 0, 0, 0)
        end
        combatLogFrame:SetAlpha(config.opacity)
    end
    
    combatLogFrame.updateTheme = updateTheme
    updateTheme()

    -- Enhanced title bar with gradient effect
    local titleBar = CreateFrame("Frame", nil, combatLogFrame, "BackdropTemplate")
    titleBar:SetSize(500, 40)  -- Increased title bar size
    titleBar:SetPoint("TOP", combatLogFrame, "TOP", 0, 0)
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

    -- Enhanced button styling
    local function CreateStyledButton(parent, text, width, height)
        local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
        button:SetSize(width or 70, height or 25)
        button:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        button:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
        button:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        
        local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        buttonText:SetPoint("CENTER")
        buttonText:SetText(text)
        buttonText:SetTextColor(1, 1, 1, 1)
        
        -- Hover effects
        button:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.3, 0.3, 0.3, 0.9)
            buttonText:SetTextColor(1, 1, 0, 1)
        end)
        
        button:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
            buttonText:SetTextColor(1, 1, 1, 1)
        end)
        
        return button
    end

    -- Enhanced close button
    local closeButton = CreateStyledButton(titleBar, "X", 30, 30)  -- Larger close button
    closeButton:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() 
        combatLogFrame:Hide()
        if config.autoHide then
            BCT:ScheduleAutoHide()
        end
    end)

    -- Enhanced control buttons
    local clearButton = CreateStyledButton(titleBar, "Clear", 70, 30)  -- Larger buttons
    clearButton:SetPoint("TOPRIGHT", closeButton, "TOPLEFT", -5, 0)
    clearButton:SetScript("OnClick", function() 
        combatLogData = {}
        BCT:UpdateCombatLogDisplay()
        print("|cff00ff00BCT:|r Combat log cleared")
    end)

    local configButton = CreateStyledButton(titleBar, "Config", 70, 30)
    configButton:SetPoint("TOPRIGHT", clearButton, "TOPLEFT", -5, 0)
    configButton:SetScript("OnClick", function() 
        BCT:ShowConfigFrame()
    end)

    -- Stats panel with more space
    local statsPanel = CreateFrame("Frame", nil, combatLogFrame, "BackdropTemplate")
    statsPanel:SetSize(480, 40)  -- Larger stats panel
    statsPanel:SetPoint("TOP", titleBar, "BOTTOM", 0, -5)
    statsPanel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    statsPanel:SetBackdropColor(0.1, 0.1, 0.1, 0.6)

    -- DPS Meter with larger font
    local dpsText = statsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dpsText:SetPoint("TOPLEFT", statsPanel, "TOPLEFT", 15, -15)
    dpsText:SetText("DPS: 0")
    dpsText:SetTextColor(1, 1, 0, 1)
    dpsText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    -- Total damage with larger font
    local totalText = statsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    totalText:SetPoint("TOP", statsPanel, "TOP", 0, -15)
    totalText:SetText("Total: 0")
    totalText:SetTextColor(0, 1, 0, 1)
    totalText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    -- Max hit with larger font
    local maxText = statsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    maxText:SetPoint("TOPRIGHT", statsPanel, "TOPRIGHT", -15, -15)
    maxText:SetText("Max: 0")
    maxText:SetTextColor(1, 0.5, 0, 1)
    maxText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    -- Combat time display
    local timeText = statsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    timeText:SetPoint("TOPLEFT", statsPanel, "TOPLEFT", 15, -35)
    timeText:SetText("Time: 00:00")
    timeText:SetTextColor(0.8, 0.8, 1, 1)
    timeText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")

    -- Entry count display
    local countText = statsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    countText:SetPoint("TOPRIGHT", statsPanel, "TOPRIGHT", -15, -35)
    countText:SetText("Entries: 0")
    countText:SetTextColor(0.8, 0.8, 1, 1)
    countText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")

    combatLogFrame.statsPanel = {
        dps = dpsText,
        total = totalText,
        max = maxText,
        time = timeText,
        count = countText
    }

    -- Enhanced scroll frame with custom scrollbar
    local scrollFrame = CreateFrame("ScrollFrame", "BCT_ScrollFrame", combatLogFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", statsPanel, "BOTTOMLEFT", 15, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", combatLogFrame, "BOTTOMRIGHT", -45, 20)  -- Bottom padding adjusted

    -- Content frame with enhanced styling
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(430, 1)  -- Wider content frame
    contentFrame.fontStrings = {}
    scrollFrame:SetScrollChild(contentFrame)

    combatLogFrame.scrollFrame = scrollFrame
    combatLogFrame.contentFrame = contentFrame

    -- Enhanced resize handle
    local resizeButton = CreateFrame("Button", nil, combatLogFrame)
    resizeButton:SetSize(25, 25)  -- Larger resize handle
    resizeButton:SetPoint("BOTTOMRIGHT", combatLogFrame, "BOTTOMRIGHT", 0, 0)
    resizeButton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")

    -- Enhanced minimum and maximum sizes for better text visibility
    local MIN_WIDTH, MIN_HEIGHT = 450, 400  -- Much larger minimum sizes
    local MAX_WIDTH, MAX_HEIGHT = 1000, 900  -- Larger maximum sizes

    resizeButton:SetScript("OnMouseDown", function(self)
        combatLogFrame:StartSizing("BOTTOMRIGHT")
    end)

    resizeButton:SetScript("OnMouseUp", function(self)
        combatLogFrame:StopMovingOrSizing()
        
        -- Enforce size constraints with better minimum sizes
        local width, height = combatLogFrame:GetSize()
        local newWidth = math.min(math.max(width, MIN_WIDTH), MAX_WIDTH)
        local newHeight = math.min(math.max(height, MIN_HEIGHT), MAX_HEIGHT)
        
        if width ~= newWidth or height ~= newHeight then
            combatLogFrame:SetSize(newWidth, newHeight)
        end
        
        -- Update component sizes based on new dimensions
        titleBar:SetWidth(newWidth)
        statsPanel:SetWidth(newWidth - 20)
        contentFrame:SetWidth(newWidth - 65)
        
        -- Update content layout
        BCT:UpdateCombatLogDisplay()
        
        -- Provide feedback about minimum size
        if width < MIN_WIDTH or height < MIN_HEIGHT then
            print("|cff00ff00BCT:|r Minimum panel size: " .. MIN_WIDTH .. "x" .. MIN_HEIGHT .. " (current: " .. math.floor(newWidth) .. "x" .. math.floor(newHeight) .. ")")
        end
    end)

    -- Add resize constraints during live resizing
    combatLogFrame:SetScript("OnSizeChanged", function(self, width, height)
        if width < MIN_WIDTH or height < MIN_HEIGHT then
            local newWidth = math.max(width, MIN_WIDTH)
            local newHeight = math.max(height, MIN_HEIGHT)
            self:SetSize(newWidth, newHeight)
        end
        
        -- Update component sizes dynamically
        if titleBar then titleBar:SetWidth(width) end
        if statsPanel then statsPanel:SetWidth(width - 20) end
        if contentFrame then contentFrame:SetWidth(width - 65) end
    end)

    combatLogFrame:Hide()
end

-- Enhanced Configuration Frame
function BCT:CreateConfigFrame()
    if configFrame then 
        configFrame:Show()
        return 
    end
    
    local currentTheme = themes[config.theme]
    
    configFrame = CreateFrame("Frame", "BCT_ConfigFrame", UIParent, "BackdropTemplate")
    configFrame:SetSize(500, 600)
    configFrame:SetPoint("CENTER", UIParent, "CENTER", 100, 0)
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)

    configFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    configFrame:SetBackdropColor(unpack(currentTheme.background))
    configFrame:SetBackdropBorderColor(unpack(currentTheme.border))

    -- Title
    local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", configFrame, "TOP", 0, -20)
    title:SetText("Better Combat Text Configuration")
    title:SetTextColor(unpack(currentTheme.accent))

    -- Create tabs
    local tabs = {"General", "Display", "Themes"}
    local tabFrames = {}
    local tabButtons = {}

    for i, tabName in ipairs(tabs) do
        -- Tab button
        local tabButton = CreateFrame("Button", nil, configFrame, "BackdropTemplate")
        tabButton:SetSize(120, 30)
        tabButton:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20 + (i-1) * 125, -50)
        tabButton:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        
        local tabText = tabButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tabText:SetPoint("CENTER")
        tabText:SetText(tabName)
        
        -- Tab content frame
        local tabFrame = CreateFrame("Frame", nil, configFrame)
        tabFrame:SetSize(460, 480)
        tabFrame:SetPoint("TOP", configFrame, "TOP", 0, -90)
        tabFrame:Hide()
        
        tabButton:SetScript("OnClick", function()
            -- Hide all tabs
            for _, frame in pairs(tabFrames) do
                frame:Hide()
            end
            for _, btn in pairs(tabButtons) do
                btn:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
            end
            -- Show selected tab
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

    -- General Tab Content
    BCT:CreateGeneralTab(tabFrames[1])
    
    -- Display Tab Content
    BCT:CreateDisplayTab(tabFrames[2])
    
    -- Themes Tab Content
    BCT:CreateThemesTab(tabFrames[3])

    -- Close button
    local closeButton = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", configFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() configFrame:Hide() end)

    configFrame:Hide()
end

-- Create General Tab
function BCT:CreateGeneralTab(parent)
    local yOffset = -20
    
    -- Enable/Disable
    local enableCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    enableCheck:SetChecked(config.enabled)
    enableCheck.text = enableCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableCheck.text:SetPoint("LEFT", enableCheck, "RIGHT", 5, 0)
    enableCheck.text:SetText("Enable Better Combat Text")
    enableCheck:SetScript("OnClick", function(self)
        config.enabled = self:GetChecked()
    end)
    yOffset = yOffset - 40

    -- Show Damage
    local damageCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    damageCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    damageCheck:SetChecked(config.showDamage)
    damageCheck.text = damageCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    damageCheck.text:SetPoint("LEFT", damageCheck, "RIGHT", 5, 0)
    damageCheck.text:SetText("Show Damage Numbers")
    damageCheck:SetScript("OnClick", function(self)
        config.showDamage = self:GetChecked()
    end)
    yOffset = yOffset - 30

    -- Show Healing
    local healingCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    healingCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    healingCheck:SetChecked(config.showHealing)
    healingCheck.text = healingCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    healingCheck.text:SetPoint("LEFT", healingCheck, "RIGHT", 5, 0)
    healingCheck.text:SetText("Show Healing Numbers")
    healingCheck:SetScript("OnClick", function(self)
        config.showHealing = self:GetChecked()
    end)
    yOffset = yOffset - 40

    -- Font Size
    local fontLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fontLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    fontLabel:SetText("Font Size: " .. config.fontSize)
    
    local fontSlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    fontSlider:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -10)
    fontSlider:SetMinMaxValues(10, 30)
    fontSlider:SetValue(config.fontSize)
    fontSlider:SetValueStep(1)
    fontSlider:SetWidth(200)
    fontSlider:SetHeight(20)
    
    fontSlider:SetScript("OnValueChanged", function(self, value)
        config.fontSize = math.floor(value)
        fontLabel:SetText("Font Size: " .. config.fontSize)
    end)
end

-- Create Display Tab
function BCT:CreateDisplayTab(parent)
    local yOffset = -20
    
    -- Compact Mode
    local compactCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    compactCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    compactCheck:SetChecked(config.compactMode)
    compactCheck.text = compactCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    compactCheck.text:SetPoint("LEFT", compactCheck, "RIGHT", 5, 0)
    compactCheck.text:SetText("Compact Mode")
    compactCheck:SetScript("OnClick", function(self)
        config.compactMode = self:GetChecked()
    end)
    yOffset = yOffset - 30

    -- Show Icons
    local iconsCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    iconsCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    iconsCheck:SetChecked(config.showIcons)
    iconsCheck.text = iconsCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    iconsCheck.text:SetPoint("LEFT", iconsCheck, "RIGHT", 5, 0)
    iconsCheck.text:SetText("Show Spell Icons")
    iconsCheck:SetScript("OnClick", function(self)
        config.showIcons = self:GetChecked()
    end)
    yOffset = yOffset - 40

    -- Opacity
    local opacityLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    opacityLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    opacityLabel:SetText("Opacity: " .. string.format("%.0f%%", config.opacity * 100))
    
    local opacitySlider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    opacitySlider:SetPoint("TOPLEFT", opacityLabel, "BOTTOMLEFT", 0, -10)
    opacitySlider:SetMinMaxValues(0.3, 1.0)
    opacitySlider:SetValue(config.opacity)
    opacitySlider:SetValueStep(0.05)
    opacitySlider:SetWidth(200)
    opacitySlider:SetHeight(20)
    
    opacitySlider:SetScript("OnValueChanged", function(self, value)
        config.opacity = value
        opacityLabel:SetText("Opacity: " .. string.format("%.0f%%", value * 100))
        if combatLogFrame then
            combatLogFrame:SetAlpha(value)
        end
    end)
end

-- Create Themes Tab
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
        
        local theme = themes[themeName]
        btn:SetBackdropColor(unpack(theme.background))
        btn:SetBackdropBorderColor(unpack(theme.border))
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        btnText:SetPoint("CENTER")
        btnText:SetText(string.upper(string.sub(themeName, 1, 1)) .. string.sub(themeName, 2))
        btnText:SetTextColor(unpack(theme.title))
        
        btn:SetScript("OnClick", function(self)
            config.theme = themeName
            for _, b in pairs(themeButtons) do
                b:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
            end
            self:SetBackdropBorderColor(1, 1, 0, 1)
            
            -- Update combat log theme
            if combatLogFrame and combatLogFrame.updateTheme then
                combatLogFrame.updateTheme()
            end
            
            print("|cff00ff00BCT:|r Theme changed to " .. themeName)
        end)
        
        -- Highlight current theme
        if config.theme == themeName then
            btn:SetBackdropBorderColor(1, 1, 0, 1)
        end
        
        themeButtons[i] = btn
    end
end

-- Enhanced combat log display with better formatting
function BCT:UpdateCombatLogDisplay()
    if not combatLogFrame or not combatLogFrame.contentFrame then return end
    
    local contentFrame = combatLogFrame.contentFrame
    local currentTheme = themes[config.theme]
    
    -- Clear existing content
    if contentFrame.fontStrings then
        for _, fs in ipairs(contentFrame.fontStrings) do
            if fs and fs.Hide then
                fs:Hide()
            end
        end
    end
    contentFrame.fontStrings = {}
    
    local yOffset = -5
    local maxVisibleEntries = config.compactMode and 120 or 90  -- More entries for larger window
    local entryHeight = config.compactMode and 14 or 20  -- Larger entry height
    
    -- Calculate stats
    local totalDamage = 0
    local totalHealing = 0
    local maxHit = 0
    local combatStart = nil
    local entryCount = #combatLogData
    
    for i, entry in ipairs(combatLogData) do
        if i > maxVisibleEntries then break end
        
        if not combatStart then combatStart = entry.timestamp end
        
        if not entry.isHealing then
            totalDamage = totalDamage + entry.amount
        else
            totalHealing = totalHealing + entry.amount
        end
        
        if entry.amount > maxHit then
            maxHit = entry.amount
        end
        
        -- Create enhanced entry display with better spacing
        local entryFrame = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
        entryFrame:SetSize(400, entryHeight)  -- Wider entries
        entryFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, yOffset)
        
        -- Alternating row colors
        if i % 2 == 0 then
            entryFrame:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                tile = true, tileSize = 16,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            entryFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.3)
        end
        
        -- Time stamp with better formatting
        local timeText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        timeText:SetPoint("LEFT", entryFrame, "LEFT", 8, 0)
        timeText:SetText(entry.time or "00:00:00")
        timeText:SetTextColor(0.7, 0.7, 0.7, 1)
        timeText:SetFont("Fonts\\FRIZQT__.TTF", config.compactMode and 11 or 12, "OUTLINE")
        
        -- Amount with enhanced formatting and better spacing
        local amountText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        amountText:SetPoint("LEFT", timeText, "RIGHT", 15, 0)  -- More spacing
        
        local prefix = entry.isHealing and "+" or ""
        local suffix = ""
        if entry.isCrit then suffix = suffix .. " *" end
        if entry.isOverkill then suffix = suffix .. " !" end
        
        local formattedAmount = BCT:FormatNumber(entry.amount)
        amountText:SetText(prefix .. formattedAmount .. suffix)
        
        -- Enhanced coloring
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
        amountText:SetFont("Fonts\\FRIZQT__.TTF", config.compactMode and 12 or 13, "OUTLINE")
        
        -- Direction and type with better spacing
        local directionText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        directionText:SetPoint("LEFT", amountText, "RIGHT", 20, 0)  -- More spacing
        local direction = entry.isOutgoing and ">" or "<"
        directionText:SetText(direction .. " " .. (entry.damageType or "Unknown"))
        directionText:SetTextColor(unpack(currentTheme.text))
        directionText:SetFont("Fonts\\FRIZQT__.TTF", config.compactMode and 10 or 11, "OUTLINE")
        
        -- Add to cleanup list
        table.insert(contentFrame.fontStrings, entryFrame)
        table.insert(contentFrame.fontStrings, timeText)
        table.insert(contentFrame.fontStrings, amountText)
        table.insert(contentFrame.fontStrings, directionText)
        
        yOffset = yOffset - entryHeight
    end
    
    -- Update stats display with enhanced information and fixed DPS calculation
    if combatLogFrame.statsPanel then
        local combatTime = combatStart and (GetTime() - combatStart) or 0
        local dps = 0
        
        -- Only calculate DPS if we have combat time and damage
        if combatTime > 0 and totalDamage > 0 then
            dps = totalDamage / combatTime
        end
        
        local minutes = math.floor(combatTime / 60)
        local seconds = math.floor(combatTime % 60)
        local timeString = string.format("%02d:%02d", minutes, seconds)
        
        -- Format DPS properly, avoiding NaN display
        local dpsString = "DPS: "
        if dps > 0 then
            dpsString = dpsString .. BCT:FormatNumber(math.floor(dps))
        else
            dpsString = dpsString .. "0"
        end
        
        combatLogFrame.statsPanel.dps:SetText(dpsString)
        combatLogFrame.statsPanel.total:SetText("Total: " .. BCT:FormatNumber(totalDamage))
        combatLogFrame.statsPanel.max:SetText("Max: " .. BCT:FormatNumber(maxHit))
        combatLogFrame.statsPanel.time:SetText("Time: " .. timeString)
        combatLogFrame.statsPanel.count:SetText("Entries: " .. entryCount)
    end
    
    -- Update content height with better padding
    contentFrame:SetHeight(math.max(150, math.abs(yOffset) + 30))
end

-- Enhanced display floating text with theme support and better cleanup
function BCT:DisplayFloatingText(text, color, size, isCrit, isOverkill, isDot, isGrouped)
    if not config.enabled then return end
    
    local textFrame = self:GetTextFromPool()
    if not textFrame then return end

    -- Reset cleanup timer
    textFrame.cleanupTimer = 0
    textFrame.isActive = true

    textFrame.fontString:SetText(text)
    textFrame.fontString:SetTextColor(unpack(color))
    textFrame.fontString:SetFont("Fonts\\FRIZQT__.TTF", size, "OUTLINE")

    -- Enhanced positioning with screen awareness
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local offsetX = math.random(-math.min(300, screenWidth * 0.2), math.min(300, screenWidth * 0.2))
    local offsetY = math.random(-100, 200)
    
    textFrame:SetPoint("CENTER", UIParent, "CENTER", offsetX, offsetY)
    textFrame:Show()

    -- Stop previous animations
    textFrame.animGroup:Stop()

    -- Enhanced animations based on type
    local moveDistance = isDot and 80 or 120
    local animDuration = config.fadeTime / config.animationSpeed
    
    if isCrit then 
        moveDistance = moveDistance * 1.8
        textFrame.moveAnim:SetOffset(0, moveDistance)
    elseif isOverkill then
        moveDistance = moveDistance * 2.2
        textFrame.moveAnim:SetOffset(0, moveDistance)
    else
        textFrame.moveAnim:SetOffset(0, moveDistance)
    end
    
    textFrame.moveAnim:SetDuration(animDuration)
    textFrame.moveAnim:SetSmoothing("OUT")

    -- Enhanced fade animation
    textFrame.fadeAnim:SetFromAlpha(1)
    textFrame.fadeAnim:SetToAlpha(0)
    textFrame.fadeAnim:SetDuration(animDuration)
    textFrame.fadeAnim:SetStartDelay(animDuration * 0.4)


    -- Enhanced scale animation
    if isCrit or isOverkill then
        local scaleAmount = isCrit and 1.4 or 1.6
        textFrame.scaleAnim:SetScale(scaleAmount, scaleAmount)
        textFrame.scaleAnim:SetDuration(0.4)
        textFrame.scaleAnim:SetSmoothing("BOUNCE")
    else
        textFrame.scaleAnim:SetScale(1, 1)
        textFrame.scaleAnim:SetDuration(0)
    end

    -- Play sound effects
    if config.soundEnabled then
        if isOverkill then
            PlaySound(SOUNDKIT and SOUNDKIT.UI_RAID_BOSS_WHISPER_WARNING or 37666)
        elseif isCrit then
            PlaySound(SOUNDKIT and SOUNDKIT.UI_BNET_TOAST or 35675)
        end
    end

    -- Enhanced cleanup on animation finish
    textFrame.animGroup:SetScript("OnFinished", function()
        self:CleanupFloatingText(textFrame)
    end)

    -- Start cleanup timer
    if not textFrame:GetScript("OnUpdate") then
        textFrame:SetScript("OnUpdate", function(self, elapsed)
            if not self.isActive then return end
            
            self.cleanupTimer = self.cleanupTimer + elapsed
            if self.cleanupTimer >= self.maxLifetime then
                -- Force cleanup after maximum lifetime
                BCT:CleanupFloatingText(self)
            end
        end)
    end

    textFrame.animGroup:Play()
end

-- Show configuration frame
function BCT:ShowConfigFrame()
    if not configFrame then
        self:CreateConfigFrame()
    end
    if configFrame then
        configFrame:Show()
    end
end

-- Schedule auto-hide for combat log
function BCT:ScheduleAutoHide()
    if not combatLogFrame or not config.autoHide then return end
    
    combatLogFrame.hideTimer = config.autoHideDelay
    if not combatLogFrame:GetScript("OnUpdate") then
        combatLogFrame:SetScript("OnUpdate", function(self, elapsed)
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

-- Enhanced cleanup function for floating text
function BCT:CleanupFloatingText(textFrame)
    if not textFrame then return end
    
    textFrame.isActive = false
    textFrame.cleanupTimer = 0
    textFrame:SetScript("OnUpdate", nil)
    textFrame.animGroup:Stop()
    textFrame:Hide()
    textFrame:ClearAllPoints()
    textFrame:SetAlpha(1)  -- Reset alpha
    textFrame:SetScale(1)  -- Reset scale
    
    if textFrame.icon then
        textFrame.icon:Hide()
    end
    
    -- Clear any lingering text
    if textFrame.fontString then
        textFrame.fontString:SetText("")
    end
end

-- Enhanced text pool management with better cleanup
function BCT:GetTextFromPool()
    -- First try to find an inactive text
    for i, text in ipairs(textPool) do
        if not text:IsShown() and not text.isActive then
            return text
        end
    end
    
    -- If no inactive text found, force cleanup old ones
    local now = GetTime()
    for i, text in ipairs(textPool) do
        if text.isActive and text.cleanupTimer and text.cleanupTimer >= text.maxLifetime then
            self:CleanupFloatingText(text)
            return text
        end
    end
    
    -- Create new text if pool is not full
    if #textPool < config.maxNumbers then
        local newText = self:CreateFloatingText()
        table.insert(textPool, newText)
        return newText
    end
    
    -- Force cleanup oldest text
    local oldestText = textPool[1]
    local oldestTime = oldestText.cleanupTimer or 0
    for i, text in ipairs(textPool) do
        local textTime = text.cleanupTimer or 0
        if textTime > oldestTime then
            oldestText = text
            oldestTime = textTime
        end
    end
    
    self:CleanupFloatingText(oldestText)
    return oldestText
end

-- Add cleanup all function for when combat ends
function BCT:CleanupAllFloatingText()
    for i, text in ipairs(textPool) do
        if text and text.isActive then
            self:CleanupFloatingText(text)
        end
    end
end

-- Enhanced combat event parsing
function BCT:ParseCombatEvent(...)
    if not config.enabled then return end
    
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags = ...
    
    local playerGUID = UnitGUID("player")
    
    if not playerGUID or not (sourceGUID == playerGUID or destGUID == playerGUID) then
        return
    end
    
    if subevent == "SWING_DAMAGE" then
        local amount, overkill, school, resisted, blocked, absorbed, critical = select(12, ...)
        self:ShowDamageText(amount, critical, school, overkill > 0, sourceGUID == playerGUID)
        
    elseif subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical = select(12, ...)
        self:ShowDamageText(amount, critical, spellSchool, overkill > 0, sourceGUID == playerGUID)
        
    elseif subevent == "SPELL_HEAL" then
        local spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = select(12, ...)
        if destGUID == playerGUID or sourceGUID == playerGUID then
            self:ShowHealingText(amount, critical, overhealing > 0)
        end
        
    elseif subevent == "SPELL_PERIODIC_DAMAGE" then
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical = select(12, ...)
        self:ShowPeriodicDamageText(amount, critical, spellSchool, sourceGUID == playerGUID)
    end
end

-- Show damage text
function BCT:ShowDamageText(amount, isCrit, school, isOverkill, isOutgoing)
    if not config.showDamage or not amount then return end
    
    local color = self:GetDamageColor(school, isCrit, isOverkill, isOutgoing)
    local size = config.fontSize
    
    if isCrit then size = size * config.critMultiplier end
    if isOverkill then size = size * config.killBlowMultiplier end
    
    local damageType = self:GetSchoolName(school)
    self:AddToCombatLog(amount, damageType, isCrit, isOverkill, false, isOutgoing)
    
    if self:ShouldGroup(amount, isOutgoing) then
        self:AddToGroup(amount, color, size, isOutgoing)
    else
        self:DisplayFloatingText(self:FormatNumber(amount), color, size, isCrit, isOverkill)
    end
end

-- Show healing text
function BCT:ShowHealingText(amount, isCrit, isOverheal)
    if not config.showHealing or not amount then return end
    
    local color = isCrit and colors.critHealing or colors.healing
    local size = config.fontSize
    
    if isCrit then size = size * config.critMultiplier end
    
    self:AddToCombatLog(amount, "Healing", isCrit, false, true, true)
    
    local text = "+" .. self:FormatNumber(amount)
    if isOverheal then text = text .. "*" end
    
    self:DisplayFloatingText(text, color, size, isCrit, false)
end

-- Show periodic damage text
function BCT:ShowPeriodicDamageText(amount, isCrit, school, isOutgoing)
    if not config.showDamage or not amount then return end
    
    local color = self:GetDamageColor(school, isCrit, false, isOutgoing)
    local size = config.fontSize * 0.8
    
    self:DisplayFloatingText(self:FormatNumber(amount), color, size, false, false, true)
end

-- Get damage color
function BCT:GetDamageColor(school, isCrit, isOverkill, isOutgoing)
    if isOverkill then return colors.overkill end
    
    local inPvP = UnitIsPVP and UnitIsPVP("player") or false
    if inPvP and config.showPvP then return colors.pvpDamage end
    
    if school == 1 then return colors.physical
    elseif school == 2 then return colors.holy
    elseif school == 4 then return colors.fire
    elseif school == 8 then return colors.nature
    elseif school == 16 then return colors.frost
    elseif school == 32 then return colors.shadow
    else
        return isCrit and colors.critDamage or colors.damage
    end
end

-- Get school name
function BCT:GetSchoolName(school)
    if school == 1 then return "Physical"
    elseif school == 2 then return "Holy"
    elseif school == 4 then return "Fire"
    elseif school == 8 then return "Nature"
    elseif school == 16 then return "Frost"
    elseif school == 32 then return "Shadow"
    elseif school == 64 then return "Arcane"
    else return "Magic"
    end
end

-- Format number
function BCT:FormatNumber(number)
    if not number then return "0" end
    
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return tostring(math.floor(number))
    end
end

-- Should group
function BCT:ShouldGroup(amount, isOutgoing)
    local now = GetTime()
    local key = isOutgoing and "out" or "in"
    
    if not damageGroups[key] then
        damageGroups[key] = {total = 0, count = 0, lastTime = now}
        return false
    end
    
    local group = damageGroups[key]
    if (now - group.lastTime) > config.groupingTime then
        group.total = amount
        group.count = 1
        group.lastTime = now
        return false
    else
        group.count = group.count + 1
        return group.count >= config.groupingThreshold
    end
end

-- Add to group
function BCT:AddToGroup(amount, color, size, isOutgoing)
    local key = isOutgoing and "out" or "in"
    local group = damageGroups[key]
    group.total = group.total + amount
    group.lastTime = GetTime()
    
    local text = self:FormatNumber(group.total) .. " (" .. group.count .. ")"
    self:DisplayFloatingText(text, color, size, false, false, false, true)
end

-- Add to combat log
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
    
    table.insert(combatLogData, 1, entry)
    
    if #combatLogData > maxLogEntries then
        table.remove(combatLogData, maxLogEntries + 1)
    end
    
    if combatLogFrame and combatLogFrame:IsShown() then
        self:UpdateCombatLogDisplay()
    end
end

-- Toggle combat log panel
function BCT:ToggleCombatLogPanel()
    if not combatLogFrame then 
        self:CreateCombatLogPanel()
    end
    
    if combatLogFrame:IsShown() then
        combatLogFrame:Hide()
    else
        combatLogFrame:Show()
        self:UpdateCombatLogDisplay()
        if config.autoHide then
            self:ScheduleAutoHide()
        end
    end
end

-- Enhanced initialization (removed minimap button creation)
function BCT:OnLoad()
    -- Initialize text pool
    for i = 1, config.maxNumbers do
        local text = self:CreateFloatingText()
        table.insert(textPool, text)
    end
    
    -- Create UI components (removed minimap button)
    self:CreateCombatLogPanel()
    
    print("|cff00ff00Better Combat Text Enhanced|r loaded successfully!")
    print("Type |cffff0000/bct|r or |cffff0000/bct help|r for commands")
    print("|cff00ff00Minimum panel size:|r 450x400 pixels for optimal text display")
    
    -- Load saved settings
    if BCT_SavedSettings then
        for key, value in pairs(BCT_SavedSettings) do
            if config[key] ~= nil then
                config[key] = value
            end
        end
    end
end

-- Event handler with enhanced cleanup
BCT:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        self:OnLoad()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local success, err = pcall(function()
            self:ParseCombatEvent(CombatLogGetCurrentEventInfo())
        end)
        if not success then
            -- Silently handle errors in combat parsing
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Combat ended, cleanup floating text after a short delay
        C_Timer.After(2, function()
            self:CleanupAllFloatingText()
        end)
    elseif event == "PLAYER_LOGOUT" then
        -- Save settings and cleanup
        BCT_SavedSettings = {}
        for key, value in pairs(config) do
            BCT_SavedSettings[key] = value
        end
        self:CleanupAllFloatingText()
    end
end)

-- Register events including combat state changes
BCT:RegisterEvent("ADDON_LOADED")
BCT:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
BCT:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Combat ended
BCT:RegisterEvent("PLAYER_LOGOUT")

-- Enhanced slash commands (removed minimap button command)
SLASH_BCT1 = "/bct"
SLASH_BCT2 = "/bettercombattext"
SlashCmdList["BCT"] = function(msg)
    local cmd = string.lower(msg or "")
    
    if cmd == "toggle" then
        config.enabled = not config.enabled
        print("|cff00ff00BCT:|r " .. (config.enabled and "Enabled" or "Disabled"))
        
    elseif cmd == "panel" or cmd == "log" then
        BCT:ToggleCombatLogPanel()
        
    elseif cmd == "config" or cmd == "options" then
        BCT:ShowConfigFrame()
        
    elseif cmd == "test" then
        BCT:DisplayFloatingText("1337", colors.critDamage, config.fontSize * config.critMultiplier, true, false)
        BCT:DisplayFloatingText("+420", colors.critHealing, config.fontSize * config.critMultiplier, true, false)
        BCT:DisplayFloatingText("2500", colors.overkill, config.fontSize * config.killBlowMultiplier, false, true)
        BCT:AddToCombatLog(1337, "Fire", true, false, false, true)
        BCT:AddToCombatLog(420, "Healing", true, false, true, true)
        BCT:AddToCombatLog(2500, "Physical", false, true, false, true)
        print("|cff00ff00BCT:|r Test numbers displayed")
        
    elseif cmd == "clear" then
        combatLogData = {}
        BCT:CleanupAllFloatingText()  -- Also cleanup floating text
        if combatLogFrame then BCT:UpdateCombatLogDisplay() end
        print("|cff00ff00BCT:|r Combat log cleared and floating text cleaned up")
        
    elseif cmd == "reset" then
        -- Reset all settings to defaults (removed minimap button option)
        config = {
            enabled = true,
            showDamage = true,
            showHealing = true,
            showPvP = true,
            animationSpeed = 2.0,
            fontSize = 16,
            critMultiplier = 1.5,
            killBlowMultiplier = 2.0,
            fadeTime = 1.5,
            maxNumbers = 20,
            groupingThreshold = 5,
            groupingTime = 2.0,
            showBackground = true,
            theme = "dark",
            opacity = 0.85,
            soundEnabled = true,
            showIcons = true,
            compactMode = false,
            autoHide = false,
            autoHideDelay = 5.0
        }
        print("|cff00ff00BCT:|r Settings reset to defaults")
        
    elseif cmd == "help" or cmd == "" then
        print("|cff00ff00Better Combat Text Enhanced|r - Command List:")
        print("|cffFFFF00Main Commands:|r")
        print("  |cff00ffff/bct toggle|r - Enable/disable addon")
        print("  |cff00ffff/bct panel|r - Toggle combat log panel")
        print("  |cff00ffff/bct config|r - Open configuration window")
        print("  |cff00ffff/bct test|r - Show test combat numbers")
        print("|cffFFFF00Utility Commands:|r")
        print("  |cff00ffff/bct clear|r - Clear combat log and cleanup floating text")
        print("  |cff00ffff/bct reset|r - Reset all settings")
        print("|cffFFFF00Panel Info:|r")
        print("  |cff00ffff Minimum size:|r 450x400 pixels for optimal display")
        print("  |cff00ffff Auto-cleanup:|r Floating text clears after combat ends")
        
    else
        print("|cffFF0000BCT:|r Unknown command '" .. cmd .. "'. Type |cff00ffff/bct help|r for available commands.")
    end
end

print("|cff00ff00Better Combat Text Enhanced|r code loaded. Ready for initialization!")