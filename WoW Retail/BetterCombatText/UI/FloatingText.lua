-- FloatingText.lua - Floating combat text display system
local addonName = "BetterCombatText"

-- Ensure global namespace exists
if not _G[addonName] then
    _G[addonName] = {}
end
local BCT = _G[addonName]

-- Local storage
BCT.textPool = BCT.textPool or {}
BCT.activeTexts = BCT.activeTexts or {}

-- Create floating text frame
function BCT:CreateFloatingText()
    local text = CreateFrame("Frame", nil, UIParent)
    text:SetSize(300, 80)
    text.fontString = text:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text.fontString:SetPoint("CENTER")
    text.fontString:SetFont("Fonts\\FRIZQT__.TTF", self.config.fontSize, "OUTLINE")
    text.fontString:SetShadowOffset(2, -2)
    text.fontString:SetShadowColor(0, 0, 0, 0.8)
    
    -- Animation groups
    text.animGroup = text:CreateAnimationGroup()
    text.moveAnim = text.animGroup:CreateAnimation("Translation")
    text.fadeAnim = text.animGroup:CreateAnimation("Alpha")
    text.scaleAnim = text.animGroup:CreateAnimation("Scale")
    
    -- Icon support
    text.icon = text:CreateTexture(nil, "OVERLAY")
    text.icon:SetSize(20, 20)
    text.icon:SetPoint("LEFT", text.fontString, "RIGHT", 5, 0)
    text.icon:Hide()
    
    -- Cleanup tracking
    text.cleanupTimer = 0
    text.maxLifetime = 10
    text.isActive = false
    
    text:Hide()
    return text
end

-- Initialize text pool
function BCT:InitializeTextPool()
    if not self.textPool then
        self.textPool = {}
    end
    if not self.activeTexts then
        self.activeTexts = {}
    end
    
    for i = 1, self.config.maxNumbers do
        local text = self:CreateFloatingText()
        table.insert(self.textPool, text)
    end
    print("|cff00ff00BCT:|r Text pool initialized with " .. self.config.maxNumbers .. " frames")
end

-- Get text from pool
function BCT:GetTextFromPool()
    -- Find inactive text
    for i, text in ipairs(self.textPool) do
        if not text.isActive and not text:IsShown() then
            return text
        end
    end
    
    -- Clean oldest if needed
    local oldestText = nil
    local oldestTime = GetTime()
    
    for i, text in ipairs(self.textPool) do
        if text.cleanupTimer and text.cleanupTimer < oldestTime then
            oldestText = text
            oldestTime = text.cleanupTimer
        end
    end
    
    if oldestText then
        self:CleanupFloatingText(oldestText)
        return oldestText
    end
    
    -- Force cleanup first text
    local firstText = self.textPool[1]
    self:CleanupFloatingText(firstText)
    return firstText
end

-- Display floating text
function BCT:DisplayFloatingText(text, color, size, isCrit, isOverkill, isDot, isGrouped)
    if not self.config.enabled then return end
    
    local textFrame = self:GetTextFromPool()
    if not textFrame then return end

    -- Reset state
    self:CleanupFloatingText(textFrame)
    
    textFrame.cleanupTimer = GetTime()
    textFrame.isActive = true
    textFrame.lastAnimationTime = GetTime()

    textFrame.fontString:SetText(text)
    textFrame.fontString:SetTextColor(unpack(color))
    textFrame.fontString:SetFont("Fonts\\FRIZQT__.TTF", size, "OUTLINE")

    -- Position
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local offsetX = math.random(-math.min(300, screenWidth * 0.2), math.min(300, screenWidth * 0.2))
    local offsetY = math.random(-100, 200)
    
    textFrame:SetPoint("CENTER", UIParent, "CENTER", offsetX, offsetY)
    textFrame:Show()

    -- Setup animations
    textFrame.animGroup:Stop()
    textFrame.animGroup:SetScript("OnFinished", nil)

    local moveDistance = isDot and 80 or 120
    local animDuration = self.config.fadeTime / self.config.animationSpeed
    
    if isCrit then 
        moveDistance = moveDistance * 1.8
    elseif isOverkill then
        moveDistance = moveDistance * 2.2
    end
    
    textFrame.moveAnim:SetOffset(0, moveDistance)
    textFrame.moveAnim:SetDuration(animDuration)
    textFrame.moveAnim:SetSmoothing("OUT")

    textFrame.fadeAnim:SetFromAlpha(1)
    textFrame.fadeAnim:SetToAlpha(0)
    textFrame.fadeAnim:SetDuration(animDuration)
    textFrame.fadeAnim:SetStartDelay(animDuration * 0.4)

    if isCrit or isOverkill then
        local scaleAmount = isCrit and 1.4 or 1.6
        textFrame.scaleAnim:SetScale(scaleAmount, scaleAmount)
        textFrame.scaleAnim:SetDuration(0.4)
        textFrame.scaleAnim:SetSmoothing("BOUNCE")
    else
        textFrame.scaleAnim:SetScale(1, 1)
        textFrame.scaleAnim:SetDuration(0)
    end

    -- Sound effects
    if self.config.soundEnabled then
        if isOverkill then
            PlaySound(37666)
        elseif isCrit then
            PlaySound(35675)
        end
    end

    -- Cleanup handling
    textFrame.animGroup:SetScript("OnFinished", function()
        BCT:CleanupFloatingText(textFrame)
    end)

    textFrame:SetScript("OnUpdate", function(self, elapsed)
        if not self.isActive then return end
        
        local currentTime = GetTime()
        
        if (currentTime - self.cleanupTimer) >= 10 then
            BCT:CleanupFloatingText(self)
            return
        end
        
        if (currentTime - self.cleanupTimer) >= (animDuration * 2) and not self.animGroup:IsPlaying() then
            BCT:CleanupFloatingText(self)
            return
        end
    end)

    table.insert(self.activeTexts, textFrame)
    
    if #self.activeTexts > self.config.maxNumbers then
        local oldest = table.remove(self.activeTexts, 1)
        if oldest and oldest.isActive then
            self:CleanupFloatingText(oldest)
        end
    end

    textFrame.animGroup:Play()
end

-- Cleanup floating text
function BCT:CleanupFloatingText(textFrame)
    if not textFrame then return end
    
    textFrame.isActive = false
    textFrame.cleanupTimer = 0
    textFrame.lastAnimationTime = nil
    
    if textFrame.animGroup then
        textFrame.animGroup:Stop()
        textFrame.animGroup:SetScript("OnFinished", nil)
    end
    
    textFrame:SetScript("OnUpdate", nil)
    textFrame:Hide()
    textFrame:ClearAllPoints()
    textFrame:SetAlpha(1)
    textFrame:SetScale(1)
    
    if textFrame.icon then
        textFrame.icon:Hide()
    end
    
    if textFrame.fontString then
        textFrame.fontString:SetText("")
    end
    
    for i = #self.activeTexts, 1, -1 do
        if self.activeTexts[i] == textFrame then
            table.remove(self.activeTexts, i)
            break
        end
    end
end

-- Cleanup all floating text
function BCT:CleanupAllFloatingText()
    for i, text in ipairs(self.textPool) do
        if text and text.isActive then
            self:CleanupFloatingText(text)
        end
    end
end

-- Force cleanup stuck text
function BCT:ForceCleanupStuckText()
    local currentTime = GetTime()
    local cleaned = 0
    
    for i = #self.textPool, 1, -1 do
        local text = self.textPool[i]
        if text and text.isActive then
            if text.cleanupTimer and (currentTime - text.cleanupTimer) > 15 then
                self:CleanupFloatingText(text)
                cleaned = cleaned + 1
            elseif text:IsShown() and not text.animGroup:IsPlaying() then
                if not text.lastAnimationTime then
                    text.lastAnimationTime = currentTime
                elseif (currentTime - text.lastAnimationTime) > 3 then
                    self:CleanupFloatingText(text)
                    cleaned = cleaned + 1
                end
            end
        end
    end
end