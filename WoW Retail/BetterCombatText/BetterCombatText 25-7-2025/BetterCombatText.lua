-- Better Combat Text Addon for World of Warcraft
-- Provides enhanced floating combat text with animations, colors, and smart grouping

local addonName = "BetterCombatText"

-- Configuration
local config = {
    enabled = true,
    showDamage = true,
    showHealing = true,
    showPvP = true,
    animationSpeed = 1.0,
    fontSize = 16,
    critMultiplier = 1.5,
    killBlowMultiplier = 2.0,
    fadeTime = 3.0,
    maxNumbers = 20,
    groupingThreshold = 5, -- Group if more than 5 hits in 2 seconds
    groupingTime = 2.0,
    showBackground = true -- New option for background visibility
}

-- Color schemes
local colors = {
    damage = {1, 1, 0, 1}, -- Yellow
    critDamage = {1, 0.5, 0, 1}, -- Orange
    healing = {0, 1, 0, 1}, -- Green
    critHealing = {0, 1, 0.5, 1}, -- Bright green
    damageTaken = {1, 0, 0, 1}, -- Red
    physical = {1, 0.8, 0.4, 1}, -- Light orange
    magic = {0.4, 0.8, 1, 1}, -- Light blue
    fire = {1, 0.2, 0.2, 1}, -- Red
    frost = {0.5, 0.8, 1, 1}, -- Light blue
    nature = {0.3, 1, 0.3, 1}, -- Green
    shadow = {0.7, 0.3, 1, 1}, -- Purple
    holy = {1, 1, 0.8, 1}, -- Light yellow
    pvpDamage = {1, 0.3, 0.3, 1}, -- Bright red for PvP
    overkill = {1, 0, 1, 1} -- Magenta
}

-- Active combat text frames
local activeTexts = {}
local textPool = {}
local damageGroups = {}

-- Combat Log Panel
local combatLogFrame = nil
local combatLogData = {}
local maxLogEntries = 100

-- Create the main addon frame
local BCT = CreateFrame("Frame", addonName)

-- Create floating text frame
function BCT:CreateFloatingText()
    local text = CreateFrame("Frame", nil, UIParent)
    text:SetSize(200, 50)
    text.fontString = text:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text.fontString:SetPoint("CENTER")
    text.fontString:SetFont("Fonts\\FRIZQT__.TTF", config.fontSize, "OUTLINE")
    
    -- Animation groups
    text.animGroup = text:CreateAnimationGroup()
    text.moveAnim = text.animGroup:CreateAnimation("Translation")
    text.fadeAnim = text.animGroup:CreateAnimation("Alpha")
    text.scaleAnim = text.animGroup:CreateAnimation("Scale")
    
    text:Hide()
    return text
end

-- Get text from pool
function BCT:GetTextFromPool()
    for i, text in ipairs(textPool) do
        if not text:IsShown() then
            return text
        end
    end
    -- If no free text, reuse oldest
    return textPool[1]
end

-- Parse combat log events
function BCT:ParseCombatEvent(...)
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags = ...
    
    local playerGUID = UnitGUID("player")
    
    -- Only show events involving the player
    if not (sourceGUID == playerGUID or destGUID == playerGUID) then
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
    if not config.showDamage then return end
    
    local color = self:GetDamageColor(school, isCrit, isOverkill, isOutgoing)
    local size = config.fontSize
    
    if isCrit then
        size = size * config.critMultiplier
    end
    
    if isOverkill then
        size = size * config.killBlowMultiplier
    end
    
    -- Add to combat log
    local damageType = self:GetSchoolName(school)
    self:AddToCombatLog(amount, damageType, isCrit, isOverkill, false, isOutgoing)
    
    -- Check for grouping
    if self:ShouldGroup(amount, isOutgoing) then
        self:AddToGroup(amount, color, size, isOutgoing)
    else
        self:DisplayFloatingText(self:FormatNumber(amount), color, size, isCrit, isOverkill)
    end
end

-- Show healing text
function BCT:ShowHealingText(amount, isCrit, isOverheal)
    if not config.showHealing then return end
    
    local color = isCrit and colors.critHealing or colors.healing
    local size = config.fontSize
    
    if isCrit then
        size = size * config.critMultiplier
    end
    
    -- Add to combat log
    self:AddToCombatLog(amount, "Healing", isCrit, false, true, true)
    
    local text = "+" .. self:FormatNumber(amount)
    if isOverheal then
        text = text .. "*"
    end
    
    self:DisplayFloatingText(text, color, size, isCrit, false)
end

-- Show periodic damage (DoTs)
function BCT:ShowPeriodicDamageText(amount, isCrit, school, isOutgoing)
    if not config.showDamage then return end
    
    local color = self:GetDamageColor(school, isCrit, false, isOutgoing)
    local size = config.fontSize * 0.8 -- Smaller for DoTs
    
    self:DisplayFloatingText(self:FormatNumber(amount), color, size, false, false, true)
end

-- Get damage color based on school and context
function BCT:GetDamageColor(school, isCrit, isOverkill, isOutgoing)
    if isOverkill then
        return colors.overkill
    end
    
    -- PvP context detection
    local inPvP = UnitIsPVP("player") or GetZonePVPInfo() == "combat"
    if inPvP and config.showPvP then
        return colors.pvpDamage
    end
    
    -- School-based colors
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

-- Get school name for display
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

-- Format numbers for display
function BCT:FormatNumber(number)
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return tostring(number)
    end
end

-- Check if damage should be grouped
function BCT:ShouldGroup(amount, isOutgoing)
    local now = GetTime()
    local key = isOutgoing and "out" or "in"
    
    if not damageGroups[key] then
        damageGroups[key] = {total = 0, count = 0, lastTime = now}
        return false
    end
    
    local group = damageGroups[key]
    if (now - group.lastTime) > config.groupingTime then
        -- Reset group
        group.total = amount
        group.count = 1
        group.lastTime = now
        return false
    else
        group.count = group.count + 1
        return group.count >= config.groupingThreshold
    end
end

-- Add damage to group
function BCT:AddToGroup(amount, color, size, isOutgoing)
    local key = isOutgoing and "out" or "in"
    local group = damageGroups[key]
    group.total = group.total + amount
    group.lastTime = GetTime()
    
    -- Show grouped number
    local text = self:FormatNumber(group.total) .. " (" .. group.count .. ")"
    self:DisplayFloatingText(text, color, size, false, false, false, true)
end

-- Display floating text with animations
function BCT:DisplayFloatingText(text, color, size, isCrit, isOverkill, isDot, isGrouped)
    local textFrame = self:GetTextFromPool()
    if not textFrame then return end

    textFrame.fontString:SetText(text)
    textFrame.fontString:SetTextColor(unpack(color))
    textFrame.fontString:SetFont("Fonts\\FRIZQT__.TTF", size, "OUTLINE")

    local offsetX = math.random(-200, 200)
    local offsetY = math.random(-100, 100)
    textFrame:SetPoint("CENTER", UIParent, "CENTER", offsetX, offsetY)
    textFrame:Show()

    -- Stop any previous animations to avoid overlaps
    textFrame.animGroup:Stop()

    -- Configure movement animation
    local moveDistance = isDot and 50 or 100
    if isCrit then moveDistance = moveDistance * 1.5 end
    textFrame.moveAnim:SetOffset(0, moveDistance)
    textFrame.moveAnim:SetDuration(config.fadeTime)
    textFrame.moveAnim:SetSmoothing("OUT")

    -- Configure fade out animation
    textFrame.fadeAnim:SetFromAlpha(1)
    textFrame.fadeAnim:SetToAlpha(0)
    textFrame.fadeAnim:SetDuration(config.fadeTime)
    textFrame.fadeAnim:SetStartDelay(config.fadeTime * 0.3)

    -- Configure scale animation
    if isCrit or isOverkill then
        textFrame.scaleAnim:SetScale(1.2, 1.2)
        textFrame.scaleAnim:SetDuration(0.3)
        textFrame.scaleAnim:SetSmoothing("OUT")
        textFrame.scaleAnim:SetStartDelay(0)
    else
        -- Reset scale for normal animations
        textFrame.scaleAnim:SetScale(1, 1)
        textFrame.scaleAnim:SetDuration(0)
    end

    textFrame.animGroup:SetScript("OnFinished", function()
        textFrame:Hide()
        textFrame:ClearAllPoints()
    end)

    -- Start animation
    textFrame.animGroup:Play()
end

-- Create Combat Log Panel
function BCT:CreateCombatLogPanel()
    -- Main frame
    combatLogFrame = CreateFrame("Frame", "BCT_CombatLogFrame", UIParent, "BackdropTemplate")
    combatLogFrame:SetSize(300, 400)
    combatLogFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50)
    combatLogFrame:SetMovable(true)
    combatLogFrame:EnableMouse(true)
    combatLogFrame:RegisterForDrag("LeftButton")
    combatLogFrame:SetScript("OnDragStart", combatLogFrame.StartMoving)
    combatLogFrame:SetScript("OnDragStop", combatLogFrame.StopMovingOrSizing)

    -- Enable resizing
    combatLogFrame:SetResizable(true)

    -- Resize button
    local resizeButton = CreateFrame("Button", nil, combatLogFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", combatLogFrame, "BOTTOMRIGHT", -25, 4)
    resizeButton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")

    resizeButton:SetScript("OnMouseDown", function(self)
        combatLogFrame:StartSizing("BOTTOMRIGHT")
    end)

    resizeButton:SetScript("OnMouseUp", function(self)
        combatLogFrame:StopMovingOrSizing()
        -- Enforce minimum size
        local width, height = combatLogFrame:GetSize()
        if width < 200 then
            combatLogFrame:SetWidth(200)
        end
        if height < 150 then
            combatLogFrame:SetHeight(150)
        end
    end)

    -- Backdrop
    combatLogFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Function to update background visibility
    local function updateBackground()
        if config.showBackground then
            combatLogFrame:SetBackdropColor(0, 0, 0, 0.8)
            combatLogFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        else
            combatLogFrame:SetBackdropColor(0, 0, 0, 0)
            combatLogFrame:SetBackdropBorderColor(0, 0, 0, 0)
        end
    end
    
    combatLogFrame.updateBackground = updateBackground
    updateBackground() -- Initialize background

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, combatLogFrame)
    titleBar:SetSize(300, 25)
    titleBar:SetPoint("TOP", combatLogFrame, "TOP", 0, 0)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
    titleText:SetText("Combat Damage Log")
    titleText:SetTextColor(1, 1, 1, 1)

    -- Close button
    local closeButton = CreateFrame("Button", nil, combatLogFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", combatLogFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() combatLogFrame:Hide() end)

    -- Clear button
    local clearButton = CreateFrame("Button", nil, combatLogFrame, "UIPanelButtonTemplate")
    clearButton:SetSize(60, 20)
    clearButton:SetPoint("TOPRIGHT", combatLogFrame, "TOPRIGHT", -35, -5)
    clearButton:SetText("Clear")
    clearButton:SetScript("OnClick", function() 
        combatLogData = {}
        BCT:UpdateCombatLogDisplay()
    end)

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "BCT_ScrollFrame", combatLogFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", combatLogFrame, "TOPLEFT", 10, -35)
    scrollFrame:SetPoint("BOTTOMRIGHT", combatLogFrame, "BOTTOMRIGHT", -35, 20)

    -- Content frame inside the scroll
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(260, 1)
    contentFrame.fontStrings = {}
    scrollFrame:SetScrollChild(contentFrame)

    combatLogFrame.scrollFrame = scrollFrame
    combatLogFrame.contentFrame = contentFrame

    -- Initialize display
    self:UpdateCombatLogDisplay()

    combatLogFrame:Hide()
end

-- Add entry to combat log
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
    
    table.insert(combatLogData, 1, entry) -- Insert at beginning
    
    -- Keep only last X entries
    if #combatLogData > maxLogEntries then
        table.remove(combatLogData, maxLogEntries + 1)
    end
    
    -- Update display if panel is visible
    if combatLogFrame and combatLogFrame:IsShown() then
        self:UpdateCombatLogDisplay()
    end
end

-- Update combat log display
function BCT:UpdateCombatLogDisplay()
    if not combatLogFrame then return end
    
    local contentFrame = combatLogFrame.contentFrame
    
    -- Clear existing font strings properly
    for _, fs in ipairs(contentFrame.fontStrings or {}) do
        fs:Hide()
        fs:SetParent(nil)
        fs:SetText("") -- Clear text content
    end
    contentFrame.fontStrings = {}
    
    -- Clear any existing children that might be causing visual artifacts
    local children = {contentFrame:GetChildren()}
    for _, child in ipairs(children) do
        if child ~= contentFrame then
            child:Hide()
            child:SetParent(nil)
        end
    end
    
    -- Create font strings for entries
    local yOffset = -10 -- Start a bit lower from the top
    local maxVisibleEntries = 50
    for i, entry in ipairs(combatLogData) do
        if i > maxVisibleEntries then break end -- Limit display to 50 entries for performance
        
        local fs = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 5, yOffset)
        fs:SetWidth(240) -- Reduced width to avoid overlap
        fs:SetJustifyH("LEFT")
        fs:SetWordWrap(false) -- Prevent text wrapping
        
        -- Format entry text
        local prefix = entry.isHealing and "+" or ""
        local suffix = ""
        if entry.isCrit then suffix = suffix .. " CRIT" end
        if entry.isOverkill then suffix = suffix .. " KILL" end
        
        local direction = entry.isOutgoing and "→" or "←"
        local text = string.format("[%s] %s%s %s%s", 
            entry.time, 
            prefix, 
            BCT:FormatNumber(entry.amount),
            direction,
            suffix
        )
        
        fs:SetText(text)
        
        -- Color based on type
        if entry.isHealing then
            fs:SetTextColor(0, 1, 0, 1) -- Green for healing
        elseif entry.isOutgoing then
            if entry.isCrit then
                fs:SetTextColor(1, 0.5, 0, 1) -- Orange for crit damage out
            else
                fs:SetTextColor(1, 1, 0, 1) -- Yellow for damage out
            end
        else
            fs:SetTextColor(1, 0, 0, 1) -- Red for damage taken
        end
        
        table.insert(contentFrame.fontStrings, fs)
        yOffset = yOffset - 15
    end
    
    -- Update content frame height (adding extra space at top)
    contentFrame:SetHeight(math.max(50, math.abs(yOffset) + 10))
end

-- Toggle combat log panel
function BCT:ToggleCombatLogPanel()
    if not combatLogFrame then return end
    
    if combatLogFrame:IsShown() then
        combatLogFrame:Hide()
    else
        combatLogFrame:Show()
        self:UpdateCombatLogDisplay()
    end
end

-- Initialize addon
function BCT:OnLoad()
    -- Create text pool
    for i = 1, config.maxNumbers do
        local text = self:CreateFloatingText()
        table.insert(textPool, text)
    end
    
    -- Create combat log panel
    self:CreateCombatLogPanel()
    
    print("|cff00ff00Better Combat Text|r loaded! Enhanced floating combat text active.")
    print("Use |cffff0000/bct panel|r to show/hide damage log panel")
end

-- Event handler
BCT:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        self:OnLoad()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:ParseCombatEvent(CombatLogGetCurrentEventInfo())
    end
end)

-- Register events
BCT:RegisterEvent("ADDON_LOADED")
BCT:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Slash commands
SLASH_BCT1 = "/bct"
SLASH_BCT2 = "/bettercombattext"
SlashCmdList["BCT"] = function(msg)
    local cmd = string.lower(msg or "")
    
    if cmd == "toggle" then
        config.enabled = not config.enabled
        print("|cff00ff00Better Combat Text|r " .. (config.enabled and "enabled" or "disabled"))
    elseif cmd == "test" then
        BCT:DisplayFloatingText("1337", colors.critDamage, config.fontSize * config.critMultiplier, true, false)
        BCT:DisplayFloatingText("+420", colors.critHealing, config.fontSize * config.critMultiplier, true, false)
        -- Add test entries to log
        BCT:AddToCombatLog(1337, "Fire", true, false, false, true)
        BCT:AddToCombatLog(420, "Healing", true, false, true, true)
    elseif cmd == "panel" then
        BCT:ToggleCombatLogPanel()
    elseif cmd == "clear" then
        combatLogData = {}
        if combatLogFrame then BCT:UpdateCombatLogDisplay() end
        print("|cff00ff00Better Combat Text|r Combat log cleared")
    elseif cmd == "background" then
        config.showBackground = not config.showBackground
        if combatLogFrame and combatLogFrame.updateBackground then
            combatLogFrame.updateBackground()
        end
        print("|cff00ff00Better Combat Text|r Background " .. (config.showBackground and "enabled" or "disabled"))
    else
        print("|cff00ff00Better Combat Text|r commands:")
        print("/bct toggle - Enable/disable addon")
        print("/bct test - Show test numbers")
        print("/bct panel - Show/hide damage log panel")
        print("/bct clear - Clear combat log")
        print("/bct background - Toggle panel background")
    end
end