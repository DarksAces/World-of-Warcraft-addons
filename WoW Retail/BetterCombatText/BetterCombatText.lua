-- Better Combat Text Addon for World of Warcraft
-- Enhanced UI with modern design and improved functionality
-- Version without minimap button + Anti-Freeze Fix

local addonName = "BetterCombatText"

-- Added DPS/HPS tracking system variables
local dpsTracker = {
    enabled = true,
    window = 5.0, -- 5 second window
    damageEvents = {},
    healingEvents = {},
    currentDPS = 0,
    currentHPS = 0,
    maxDPS = 0,
    maxHPS = 0,
    lastUpdate = 0,
    displayFrame = nil,
    inCombat = false,
    combatStartTime = 0,
    lastCombatActivity = 0
}

-- Added critical streak tracking
local critStreakTracker = {
    enabled = true,
    currentStreak = 0,
    maxStreak = 0,
    lastCritTime = 0,
    streakTimeout = 3.0, -- Reset streak after 3 seconds
    minStreakForEffect = 3 -- Minimum crits for special effect
}

-- Added threat tracking
local threatTracker = {
    enabled = true,
    hasAggro = false,
    threatLevel = 0,
    lastThreatCheck = 0,
    checkInterval = 0.5
}

-- Added advanced statistics tracking
local advancedStats = {
    enabled = true,
    sessionStart = 0,
    totalDamage = 0,
    totalHealing = 0,
    totalCrits = 0,
    totalHits = 0,
    maxDamage = 0,
    maxHealing = 0,
    damageBySchool = {},
    healingBySpell = {},
    critRate = 0,
    avgDamage = 0,
    avgHealing = 0,
    displayFrame = nil,
    updateInterval = 1.0,
    lastUpdate = 0
}

-- Added character profiles system
local characterProfiles = {
    enabled = true,
    profiles = {},
    currentProfile = nil,
    autoSwitch = true
}

-- Added practice mode system
local practiceMode = {
    enabled = false,
    timer = nil,
    interval = 2.0,
    minDamage = 100,
    maxDamage = 5000,
    critChance = 0.25,
    healChance = 0.3,
    running = false
}

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
    autoHideDelay = 5.0,
    -- Added new config options
    showDPS = true,
    showHPS = true,
    showThreatIndicator = true,
    showCritStreaks = true,
    dpsUpdateInterval = 0.5,
    practiceMode = false,
    -- Added animation options
    animationType = "default", -- default, bounce, spiral, slide
    particleEffects = true,
    rotationEffects = false
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

-- Added character profile functions
function BCT:CreateCharacterProfile()
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local className = UnitClass("player")
    local specID = GetSpecialization()
    local specName = specID and select(2, GetSpecializationInfo(specID)) or "Unknown"
    
    local profileKey = playerName .. "-" .. realmName .. "-" .. specName
    
    if not characterProfiles.profiles[profileKey] then
        characterProfiles.profiles[profileKey] = {
            name = playerName,
            realm = realmName,
            class = className,
            spec = specName,
            config = {},
            created = GetTime(),
            lastUsed = GetTime()
        }
        
        -- Copy current config to profile
        for key, value in pairs(config) do
            characterProfiles.profiles[profileKey].config[key] = value
        end
        
        print("|cff00ff00BCT:|r Created profile for " .. profileKey)
    end
    
    characterProfiles.currentProfile = profileKey
    return characterProfiles.profiles[profileKey]
end

function BCT:LoadCharacterProfile(profileKey)
    if not characterProfiles.profiles[profileKey] then
        print("|cffFF0000BCT:|r Profile not found: " .. profileKey)
        return false
    end
    
    local profile = characterProfiles.profiles[profileKey]
    
    -- Load profile config
    for key, value in pairs(profile.config) do
        if config[key] ~= nil then
            config[key] = value
        end
    end
    
    profile.lastUsed = GetTime()
    characterProfiles.currentProfile = profileKey
    
    print("|cff00ff00BCT:|r Loaded profile: " .. profileKey)
    return true
end

function BCT:SaveCurrentProfile()
    if not characterProfiles.currentProfile then
        self:CreateCharacterProfile()
        return
    end
    
    local profile = characterProfiles.profiles[characterProfiles.currentProfile]
    if profile then
        -- Save current config to profile
        for key, value in pairs(config) do
            profile.config[key] = value
        end
        profile.lastUsed = GetTime()
        print("|cff00ff00BCT:|r Saved current settings to profile")
    end
end

function BCT:AutoSwitchProfile()
    if not characterProfiles.autoSwitch then return end
    
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local specID = GetSpecialization()
    local specName = specID and select(2, GetSpecializationInfo(specID)) or "Unknown"
    
    local profileKey = playerName .. "-" .. realmName .. "-" .. specName
    
    if characterProfiles.currentProfile ~= profileKey then
        if characterProfiles.profiles[profileKey] then
            self:LoadCharacterProfile(profileKey)
        else
            self:CreateCharacterProfile()
        end
    end
end

-- Added practice mode functions
function BCT:StartPracticeMode()
    if practiceMode.running then
        self:StopPracticeMode()
        return
    end
    
    practiceMode.running = true
    config.practiceMode = true
    
    practiceMode.timer = C_Timer.NewTicker(practiceMode.interval, function()
        self:GeneratePracticeNumbers()
    end)
    
    print("|cff00ff00BCT:|r Practice mode started - generating test numbers every " .. practiceMode.interval .. " seconds")
end

function BCT:StopPracticeMode()
    if not practiceMode.running then return end
    
    practiceMode.running = false
    config.practiceMode = false
    
    if practiceMode.timer then
        practiceMode.timer:Cancel()
        practiceMode.timer = nil
    end
    
    print("|cff00ff00BCT:|r Practice mode stopped")
end

function BCT:GeneratePracticeNumbers()
    if not practiceMode.running then return end
    
    -- Generate random damage
    local damage = math.random(practiceMode.minDamage, practiceMode.maxDamage)
    local isCrit = math.random() < practiceMode.critChance
    local isOverkill = math.random() < 0.1 -- 10% chance for overkill
    local isHealing = math.random() < practiceMode.healChance
    
    if isHealing then
        local healAmount = math.random(practiceMode.minDamage * 0.5, practiceMode.maxDamage * 0.8)
        self:UpdateCritStreak(isCrit)
        self:UpdateDPSTracker(healAmount, true)
        self:UpdateAdvancedStats(healAmount, isCrit, true, 2)
        
        local color = isCrit and colors.critHealing or colors.healing
        local size = config.fontSize
        if isCrit then size = size * config.critMultiplier end
        
        local text = "+" .. self:FormatNumber(healAmount)
        self:DisplayFloatingText(text, color, size, isCrit, false)
        self:AddToCombatLog(healAmount, "Practice Heal", isCrit, false, true, true)
    else
        self:UpdateCritStreak(isCrit)
        self:UpdateDPSTracker(damage, false)
        self:UpdateAdvancedStats(damage, isCrit, false, math.random(1, 6))
        
        local school = math.random(1, 6)
        local color = self:GetDamageColor(school, isCrit, isOverkill, true)
        local size = config.fontSize
        
        if isCrit then size = size * config.critMultiplier end
        if isOverkill then size = size * config.killBlowMultiplier end
        
        self:DisplayFloatingText(self:FormatNumber(damage), color, size, isCrit, isOverkill)
        self:AddToCombatLog(damage, "Practice " .. self:GetSchoolName(school), isCrit, isOverkill, false, true)
    end
end

-- Added DPS/HPS calculation functions
function BCT:UpdateDPSTracker(damage, isHealing)
    if not config.showDPS and not config.showHPS then return end
    
    local currentTime = GetTime()
    
    -- Update combat state and last activity time
    self:UpdateCombatState(currentTime)
    dpsTracker.lastCombatActivity = currentTime
    
    -- Only track DPS/HPS during combat
    if not dpsTracker.inCombat then return end
    
    local events = isHealing and dpsTracker.healingEvents or dpsTracker.damageEvents
    
    -- Add new event
    table.insert(events, {
        damage = damage,
        time = currentTime
    })
    
    -- Remove events outside the window
    local windowStart = currentTime - dpsTracker.window
    for i = #events, 1, -1 do
        if events[i].time < windowStart then
            table.remove(events, i)
        else
            break
        end
    end
    
    -- Calculate DPS/HPS only if we have events
    local totalDamage = 0
    local validEvents = 0
    for _, event in ipairs(events) do
        if event.time >= windowStart then
            totalDamage = totalDamage + event.damage
            validEvents = validEvents + 1
        end
    end
    
    -- Only calculate DPS if we have recent damage/healing
    local dps = 0
    if validEvents > 0 then
        local timeWindow = math.min(dpsTracker.window, currentTime - dpsTracker.combatStartTime)
        if timeWindow > 0 then
            dps = totalDamage / timeWindow
        end
    end
    
    if isHealing then
        dpsTracker.currentHPS = dps
        if dps > dpsTracker.maxHPS then
            dpsTracker.maxHPS = dps
        end
    else
        dpsTracker.currentDPS = dps
        if dps > dpsTracker.maxDPS then
            dpsTracker.maxDPS = dps
        end
    end
    
    -- Update display if enough time has passed
    if currentTime - dpsTracker.lastUpdate > config.dpsUpdateInterval then
        self:UpdateDPSDisplay()
        dpsTracker.lastUpdate = currentTime
    end
end

-- Added combat state management
function BCT:UpdateCombatState(currentTime)
    local wasInCombat = dpsTracker.inCombat
    
    -- Check if player is in combat or has recent combat activity
    local playerInCombat = UnitAffectingCombat("player")
    local timeSinceLastActivity = currentTime - dpsTracker.lastCombatActivity
    
    if playerInCombat or timeSinceLastActivity < 3.0 then
        if not dpsTracker.inCombat then
            dpsTracker.inCombat = true
            dpsTracker.combatStartTime = currentTime
            -- Clear old events when entering combat
            dpsTracker.damageEvents = {}
            dpsTracker.healingEvents = {}
        end
    else
        if dpsTracker.inCombat and timeSinceLastActivity > 5.0 then
            dpsTracker.inCombat = false
            dpsTracker.currentDPS = 0
            dpsTracker.currentHPS = 0
            self:UpdateDPSDisplay()
        end
    end
end

function BCT:UpdateDPSDisplay()
    if not config.showDPS and not config.showHPS then 
        if dpsTracker.displayFrame then
            dpsTracker.displayFrame:Hide()
        end
        return 
    end
    
    if not dpsTracker.displayFrame then
        self:CreateDPSDisplay()
    end
    
    -- Only show DPS during combat
    if not dpsTracker.inCombat then
        dpsTracker.displayFrame:Hide()
        return
    end
    
    local dpsText = ""
    if config.showDPS and dpsTracker.currentDPS > 0 then
        dpsText = string.format("DPS: %.0f", dpsTracker.currentDPS)
    end
    
    local hpsText = ""
    if config.showHPS and dpsTracker.currentHPS > 0 then
        hpsText = string.format("HPS: %.0f", dpsTracker.currentHPS)
    end
    
    local displayText = ""
    if dpsText ~= "" and hpsText ~= "" then
        displayText = dpsText .. " | " .. hpsText
    elseif dpsText ~= "" then
        displayText = dpsText
    elseif hpsText ~= "" then
        displayText = hpsText
    end
    
    if displayText ~= "" then
        dpsTracker.displayFrame.text:SetText(displayText)
        dpsTracker.displayFrame:Show()
    else
        dpsTracker.displayFrame:Hide()
    end
end

function BCT:CreateDPSDisplay()
    local currentTheme = themes[config.theme]
    
    dpsTracker.displayFrame = CreateFrame("Frame", "BCT_DPSDisplay", UIParent, "BackdropTemplate")
    dpsTracker.displayFrame:SetSize(200, 30)
    dpsTracker.displayFrame:SetPoint("TOP", UIParent, "TOP", 0, -100)
    
    dpsTracker.displayFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    dpsTracker.displayFrame:SetBackdropColor(unpack(currentTheme.background))
    dpsTracker.displayFrame:SetBackdropBorderColor(unpack(currentTheme.border))
    
    dpsTracker.displayFrame.text = dpsTracker.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dpsTracker.displayFrame.text:SetPoint("CENTER")
    dpsTracker.displayFrame.text:SetTextColor(unpack(currentTheme.accent))
    
    dpsTracker.displayFrame:SetMovable(true)
    dpsTracker.displayFrame:EnableMouse(true)
    dpsTracker.displayFrame:RegisterForDrag("LeftButton")
    dpsTracker.displayFrame:SetScript("OnDragStart", dpsTracker.displayFrame.StartMoving)
    dpsTracker.displayFrame:SetScript("OnDragStop", dpsTracker.displayFrame.StopMovingOrSizing)
    
    dpsTracker.displayFrame:Hide()
end

-- Added critical streak tracking functions
function BCT:UpdateCritStreak(isCrit)
    local currentTime = GetTime()
    
    if isCrit then
        if currentTime - critStreakTracker.lastCritTime <= critStreakTracker.streakTimeout then
            critStreakTracker.currentStreak = critStreakTracker.currentStreak + 1
        else
            critStreakTracker.currentStreak = 1
        end
        
        critStreakTracker.lastCritTime = currentTime
        
        if critStreakTracker.currentStreak > critStreakTracker.maxStreak then
            critStreakTracker.maxStreak = critStreakTracker.currentStreak
        end
        
        -- Special effect for streak
        if critStreakTracker.currentStreak >= critStreakTracker.minStreakForEffect then
            self:DisplayStreakEffect(critStreakTracker.currentStreak)
        end
    else
        -- Reset streak if too much time has passed
        if currentTime - critStreakTracker.lastCritTime > critStreakTracker.streakTimeout then
            critStreakTracker.currentStreak = 0
        end
    end
end

function BCT:DisplayStreakEffect(streakCount)
    if not config.showCritStreaks then return end
    
    local streakText = "STREAK x" .. streakCount .. "!"
    local color = {1, 0.8, 0, 1} -- Gold color for streaks
    local size = config.fontSize * 1.8
    
    -- Create special streak floating text
    self:DisplayFloatingText(streakText, color, size, true, false, true) -- true for special effect
end

-- Added threat indicator functions
function BCT:UpdateThreatIndicator()
    if not config.showThreatIndicator then return end
    
    local currentTime = GetTime()
    if currentTime - threatTracker.lastThreatCheck < threatTracker.checkInterval then
        return
    end
    
    threatTracker.lastThreatCheck = currentTime
    
    -- Check if player has aggro on current target
    local hasAggro = false
    local threatLevel = 0
    
    if UnitExists("target") and UnitCanAttack("player", "target") then
        local isTanking, status, threatpct = UnitDetailedThreatSituation("player", "target")
        hasAggro = isTanking or false
        threatLevel = threatpct or 0
    end
    
    -- Update threat status
    if hasAggro ~= threatTracker.hasAggro then
        threatTracker.hasAggro = hasAggro
        self:DisplayThreatChange(hasAggro)
    end
    
    threatTracker.threatLevel = threatLevel
end

function BCT:DisplayThreatChange(hasAggro)
    local text = hasAggro and "AGGRO!" or "AGGRO LOST"
    local color = hasAggro and {1, 0, 0, 1} or {0, 1, 0, 1} -- Red for aggro, green for lost
    local size = config.fontSize * 1.5
    
    self:DisplayFloatingText(text, color, size, false, false, true)
end

-- Added advanced statistics panel creation
function BCT:CreateAdvancedStatsPanel()
    if advancedStats.displayFrame then return end
    
    local currentTheme = themes[config.theme]
    
    advancedStats.displayFrame = CreateFrame("Frame", "BCT_AdvancedStatsPanel", UIParent, "BackdropTemplate")
    advancedStats.displayFrame:SetSize(300, 200)
    advancedStats.displayFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -150)
    
    advancedStats.displayFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    advancedStats.displayFrame:SetBackdropColor(unpack(currentTheme.background))
    advancedStats.displayFrame:SetBackdropBorderColor(unpack(currentTheme.border))
    
    -- Title
    local title = advancedStats.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", advancedStats.displayFrame, "TOP", 0, -10)
    title:SetText("Combat Statistics")
    title:SetTextColor(unpack(currentTheme.accent))
    
    -- Session time
    local sessionTime = advancedStats.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sessionTime:SetPoint("TOPLEFT", advancedStats.displayFrame, "TOPLEFT", 15, -35)
    sessionTime:SetText("Session: 00:00:00")
    sessionTime:SetTextColor(unpack(currentTheme.text))
    advancedStats.displayFrame.sessionTime = sessionTime
    
    -- Total damage
    local totalDmg = advancedStats.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    totalDmg:SetPoint("TOPLEFT", sessionTime, "BOTTOMLEFT", 0, -5)
    totalDmg:SetText("Total Damage: 0")
    totalDmg:SetTextColor(1, 0.8, 0, 1)
    advancedStats.displayFrame.totalDmg = totalDmg
    
    -- Total healing
    local totalHeal = advancedStats.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    totalHeal:SetPoint("TOPLEFT", totalDmg, "BOTTOMLEFT", 0, -5)
    totalHeal:SetText("Total Healing: 0")
    totalHeal:SetTextColor(0, 1, 0.5, 1)
    advancedStats.displayFrame.totalHeal = totalHeal
    
    -- Crit rate
    local critRate = advancedStats.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    critRate:SetPoint("TOPLEFT", totalHeal, "BOTTOMLEFT", 0, -5)
    critRate:SetText("Crit Rate: 0%")
    critRate:SetTextColor(1, 0.5, 0, 1)
    advancedStats.displayFrame.critRate = critRate
    
    -- Average damage
    local avgDmg = advancedStats.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    avgDmg:SetPoint("TOPLEFT", critRate, "BOTTOMLEFT", 0, -5)
    avgDmg:SetText("Avg Damage: 0")
    avgDmg:SetTextColor(0.8, 0.8, 1, 1)
    advancedStats.displayFrame.avgDmg = avgDmg
    
    -- Max damage
    local maxDmg = advancedStats.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    maxDmg:SetPoint("TOPLEFT", avgDmg, "BOTTOMLEFT", 0, -5)
    maxDmg:SetText("Max Hit: 0")
    maxDmg:SetTextColor(1, 0, 1, 1)
    advancedStats.displayFrame.maxDmg = maxDmg
    
    -- Current streak
    local currentStreak = advancedStats.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentStreak:SetPoint("TOPLEFT", maxDmg, "BOTTOMLEFT", 0, -5)
    currentStreak:SetText("Crit Streak: 0")
    currentStreak:SetTextColor(1, 0.8, 0, 1)
    advancedStats.displayFrame.currentStreak = currentStreak
    
    -- Make it movable
    advancedStats.displayFrame:SetMovable(true)
    advancedStats.displayFrame:EnableMouse(true)
    advancedStats.displayFrame:RegisterForDrag("LeftButton")
    advancedStats.displayFrame:SetScript("OnDragStart", advancedStats.displayFrame.StartMoving)
    advancedStats.displayFrame:SetScript("OnDragStop", advancedStats.displayFrame.StopMovingOrSizing)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, advancedStats.displayFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", advancedStats.displayFrame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() 
        advancedStats.displayFrame:Hide() 
    end)
    
    advancedStats.displayFrame:Hide()
end

-- Added function to update advanced statistics
function BCT:UpdateAdvancedStats(amount, isCrit, isHealing, school)
    if not advancedStats.enabled then return end
    
    local currentTime = GetTime()
    
    -- Initialize session start time
    if advancedStats.sessionStart == 0 then
        advancedStats.sessionStart = currentTime
    end
    
    -- Update totals
    if isHealing then
        advancedStats.totalHealing = advancedStats.totalHealing + amount
        if amount > advancedStats.maxHealing then
            advancedStats.maxHealing = amount
        end
    else
        advancedStats.totalDamage = advancedStats.totalDamage + amount
        if amount > advancedStats.maxDamage then
            advancedStats.maxDamage = amount
        end
        
        -- Track damage by school
        local schoolName = self:GetSchoolName(school or 1)
        if not advancedStats.damageBySchool[schoolName] then
            advancedStats.damageBySchool[schoolName] = 0
        end
        advancedStats.damageBySchool[schoolName] = advancedStats.damageBySchool[schoolName] + amount
    end
    
    -- Update hit counters
    advancedStats.totalHits = advancedStats.totalHits + 1
    if isCrit then
        advancedStats.totalCrits = advancedStats.totalCrits + 1
    end
    
    -- Calculate rates and averages
    if advancedStats.totalHits > 0 then
        advancedStats.critRate = (advancedStats.totalCrits / advancedStats.totalHits) * 100
        advancedStats.avgDamage = advancedStats.totalDamage / advancedStats.totalHits
    end
    
    -- Update display if enough time has passed
    if currentTime - advancedStats.lastUpdate > advancedStats.updateInterval then
        self:UpdateAdvancedStatsDisplay()
        advancedStats.lastUpdate = currentTime
    end
end

-- Added function to update advanced statistics display
function BCT:UpdateAdvancedStatsDisplay()
    if not advancedStats.displayFrame or not advancedStats.displayFrame:IsShown() then return end
    
    local sessionTime = GetTime() - advancedStats.sessionStart
    local hours = math.floor(sessionTime / 3600)
    local minutes = math.floor((sessionTime % 3600) / 60)
    local seconds = math.floor(sessionTime % 60)
    local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    
    advancedStats.displayFrame.sessionTime:SetText("Session: " .. timeString)
    advancedStats.displayFrame.totalDmg:SetText("Total Damage: " .. self:FormatNumber(advancedStats.totalDamage))
    advancedStats.displayFrame.totalHeal:SetText("Total Healing: " .. self:FormatNumber(advancedStats.totalHealing))
    advancedStats.displayFrame.critRate:SetText("Crit Rate: " .. string.format("%.1f%%", advancedStats.critRate))
    advancedStats.displayFrame.avgDmg:SetText("Avg Damage: " .. self:FormatNumber(math.floor(advancedStats.avgDamage)))
    advancedStats.displayFrame.maxDmg:SetText("Max Hit: " .. self:FormatNumber(advancedStats.maxDamage))
    advancedStats.displayFrame.currentStreak:SetText("Crit Streak: " .. critStreakTracker.currentStreak .. " (Max: " .. critStreakTracker.maxStreak .. ")")
end

-- Added function to toggle advanced statistics panel
function BCT:ToggleAdvancedStatsPanel()
    if not advancedStats.displayFrame then
        self:CreateAdvancedStatsPanel()
    end
    
    if advancedStats.displayFrame:IsShown() then
        advancedStats.displayFrame:Hide()
    else
        advancedStats.displayFrame:Show()
        self:UpdateAdvancedStatsDisplay()
    end
end

-- Added function to reset advanced statistics
function BCT:ResetAdvancedStats()
    advancedStats.sessionStart = GetTime()
    advancedStats.totalDamage = 0
    advancedStats.totalHealing = 0
    advancedStats.totalCrits = 0
    advancedStats.totalHits = 0
    advancedStats.maxDamage = 0
    advancedStats.maxHealing = 0
    advancedStats.damageBySchool = {}
    advancedStats.healingBySpell = {}
    advancedStats.critRate = 0
    advancedStats.avgDamage = 0
    advancedStats.avgHealing = 0
    
    -- Reset crit streak tracker
    critStreakTracker.currentStreak = 0
    critStreakTracker.maxStreak = 0
    critStreakTracker.lastCritTime = 0
    
    -- Reset DPS tracker
    dpsTracker.damageEvents = {}
    dpsTracker.healingEvents = {}
    dpsTracker.currentDPS = 0
    dpsTracker.currentHPS = 0
    dpsTracker.maxDPS = 0
    dpsTracker.maxHPS = 0
    
    if advancedStats.displayFrame and advancedStats.displayFrame:IsShown() then
        self:UpdateAdvancedStatsDisplay()
    end
    
    print("|cff00ff00BCT:|r Advanced statistics reset")
end

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
    
    -- Added particle effect animation for special effects
    text.particleAnim = text.animGroup:CreateAnimation("Scale")
    text.rotateAnim = text.animGroup:CreateAnimation("Rotation")
    
    -- Icon support
    text.icon = text:CreateTexture(nil, "OVERLAY")
    text.icon:SetSize(20, 20)
    text.icon:SetPoint("LEFT", text.fontString, "RIGHT", 5, 0)
    text.icon:Hide()
    
    -- Auto-cleanup timer to prevent stuck numbers
    text.cleanupTimer = 0
    text.maxLifetime = 10  -- Maximum 10 seconds before forced cleanup
    text.isActive = false  -- Initialize as inactive
    
    text:Hide()
    return text
end

-- Enhanced Combat Log Panel with modern design
function BCT:CreateCombatLogPanel()
    if combatLogFrame then return end
    
    local currentTheme = themes[config.theme]
    
    -- Main frame with enhanced styling
    combatLogFrame = CreateFrame("Frame", "BCT_CombatLogFrame", UIParent, "BackdropTemplate")
    combatLogFrame:SetSize(500, 650)
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
    titleBar:SetSize(500, 40)
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
    local closeButton = CreateStyledButton(titleBar, "X", 30, 30)
    closeButton:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() 
        combatLogFrame:Hide()
        if config.autoHide then
            BCT:ScheduleAutoHide()
        end
    end)

    -- Enhanced control buttons
    local clearButton = CreateStyledButton(titleBar, "Clear", 70, 30)
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
    statsPanel:SetSize(480, 40)
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
    scrollFrame:SetPoint("BOTTOMRIGHT", combatLogFrame, "BOTTOMRIGHT", -45, 20)

    -- Content frame with enhanced styling
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(430, 1)
    contentFrame.fontStrings = {}
    scrollFrame:SetScrollChild(contentFrame)

    combatLogFrame.scrollFrame = scrollFrame
    combatLogFrame.contentFrame = contentFrame

    -- Enhanced resize handle
    local resizeButton = CreateFrame("Button", nil, combatLogFrame)
    resizeButton:SetSize(25, 25)
    resizeButton:SetPoint("BOTTOMRIGHT", combatLogFrame, "BOTTOMRIGHT", 0, 0)
    resizeButton:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")

    -- Enhanced minimum and maximum sizes for better text visibility
    local MIN_WIDTH, MIN_HEIGHT = 450, 400
    local MAX_WIDTH, MAX_HEIGHT = 1000, 900

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
    local tabs = {"General", "Display", "Themes", "Advanced"}
    local tabFrames = {}
    local tabButtons = {}

    for i, tabName in ipairs(tabs) do
        -- Tab button
        local tabButton = CreateFrame("Button", nil, configFrame, "BackdropTemplate")
        tabButton:SetSize(100, 30)
        tabButton:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20 + (i-1) * 105, -50)
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
    
    -- Advanced Tab Content
    BCT:CreateAdvancedTab(tabFrames[4])

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

    -- Added DPS/HPS toggle checkboxes
    local showDPSCheck = CreateFrame("CheckButton", "BCT_ShowDPSCheck", parent, "UICheckButtonTemplate")
    showDPSCheck:SetPoint("TOPLEFT", fontSlider, "BOTTOMLEFT", 0, -10)
    showDPSCheck.text = showDPSCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    showDPSCheck.text:SetPoint("LEFT", showDPSCheck, "RIGHT", 5, 0)
    showDPSCheck.text:SetText("Mostrar DPS")
    showDPSCheck:SetChecked(config.showDPS)
    showDPSCheck:SetScript("OnClick", function()
        config.showDPS = showDPSCheck:GetChecked()
        if not config.showDPS and not config.showHPS then
            if dpsTracker.displayFrame then
                dpsTracker.displayFrame:Hide()
            end
        end
    end)
    yOffset = yOffset - 30
    
    local showHPSCheck = CreateFrame("CheckButton", "BCT_ShowHPSCheck", parent, "UICheckButtonTemplate")
    showHPSCheck:SetPoint("TOPLEFT", showDPSCheck, "BOTTOMLEFT", 0, -10)
    showHPSCheck.text = showHPSCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    showHPSCheck.text:SetPoint("LEFT", showHPSCheck, "RIGHT", 5, 0)
    showHPSCheck.text:SetText("Mostrar HPS (Sanación por segundo)")
    showHPSCheck:SetChecked(config.showHPS)
    showHPSCheck:SetScript("OnClick", function()
        config.showHPS = showHPSCheck:GetChecked()
        if not config.showDPS and not config.showHPS then
            if dpsTracker.displayFrame then
                dpsTracker.displayFrame:Hide()
            end
        end
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

-- Added Advanced Tab for new features
function BCT:CreateAdvancedTab(parent)
    local yOffset = -20
    
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", parent, "TOP", 0, yOffset)
    title:SetText("Advanced Features")
    title:SetTextColor(1, 1, 0, 1)
    yOffset = yOffset - 40

    -- Animation Type Selection
    local animLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    animLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    animLabel:SetText("Animation Style:")
    yOffset = yOffset - 25

    local animTypes = {"default", "bounce", "spiral", "slide"}
    local animButtons = {}
    
    for i, animType in ipairs(animTypes) do
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(80, 25)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20 + (i-1) * 85, yOffset)
        btn:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btnText:SetPoint("CENTER")
        btnText:SetText(string.upper(string.sub(animType, 1, 1)) .. string.sub(animType, 2))
        
        btn:SetScript("OnClick", function(self)
            config.animationType = animType
            for _, b in pairs(animButtons) do
                b:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
            end
            self:SetBackdropColor(0.3, 0.6, 0.9, 0.8)
            print("|cff00ff00BCT:|r Animation style changed to " .. animType)
        end)
        
        if config.animationType == animType then
            btn:SetBackdropColor(0.3, 0.6, 0.9, 0.8)
        else
            btn:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
        end
        
        animButtons[i] = btn
    end
    yOffset = yOffset - 40

    -- Particle Effects
    local particleCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    particleCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    particleCheck:SetChecked(config.particleEffects)
    particleCheck.text = particleCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    particleCheck.text:SetPoint("LEFT", particleCheck, "RIGHT", 5, 0)
    particleCheck.text:SetText("Particle Effects for Crits")
    particleCheck:SetScript("OnClick", function(self)
        config.particleEffects = self:GetChecked()
    end)
    yOffset = yOffset - 30

    -- Rotation Effects
    local rotationCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    rotationCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    rotationCheck:SetChecked(config.rotationEffects)
    rotationCheck.text = rotationCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rotationCheck.text:SetPoint("LEFT", rotationCheck, "RIGHT", 5, 0)
    rotationCheck.text:SetText("Rotation Effects (Spiral Mode)")
    rotationCheck:SetScript("OnClick", function(self)
        config.rotationEffects = self:GetChecked()
    end)
    yOffset = yOffset - 40

    -- Practice Mode Section
    local practiceLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    practiceLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    practiceLabel:SetText("Practice Mode")
    practiceLabel:SetTextColor(0, 1, 0.5, 1)
    yOffset = yOffset - 30

    -- Practice Mode Toggle
    local practiceBtn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    practiceBtn:SetSize(120, 30)
    practiceBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    practiceBtn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    practiceBtn:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
    
    local practiceBtnText = practiceBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    practiceBtnText:SetPoint("CENTER")
    practiceBtnText:SetText("Start Practice")
    
    practiceBtn:SetScript("OnClick", function(self)
        if practiceMode.running then
            BCT:StopPracticeMode()
            practiceBtnText:SetText("Start Practice")
            self:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
        else
            BCT:StartPracticeMode()
            practiceBtnText:SetText("Stop Practice")
            self:SetBackdropColor(0.2, 0.6, 0.2, 0.8)
        end
    end)
    
    -- Profile Management Section
    yOffset = yOffset - 60
    local profileLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    profileLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    profileLabel:SetText("Character Profiles")
    profileLabel:SetTextColor(0.8, 0.6, 1, 1)
    yOffset = yOffset - 30

    -- Save Profile Button
    local saveProfileBtn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    saveProfileBtn:SetSize(100, 25)
    saveProfileBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    saveProfileBtn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    saveProfileBtn:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
    
    local saveProfileText = saveProfileBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    saveProfileText:SetPoint("CENTER")
    saveProfileText:SetText("Save Profile")
    
    saveProfileBtn:SetScript("OnClick", function()
        BCT:SaveCurrentProfile()
    end)

    -- Auto Switch Profiles
    local autoSwitchCheck = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    autoSwitchCheck:SetPoint("TOPLEFT", parent, "TOPLEFT", 130, yOffset)
    autoSwitchCheck:SetChecked(characterProfiles.autoSwitch)
    autoSwitchCheck.text = autoSwitchCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    autoSwitchCheck.text:SetPoint("LEFT", autoSwitchCheck, "RIGHT", 5, 0)
    autoSwitchCheck.text:SetText("Auto Switch")
    autoSwitchCheck:SetScript("OnClick", function(self)
        characterProfiles.autoSwitch = self:GetChecked()
    end)
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
    local maxVisibleEntries = config.compactMode and 120 or 90
    local entryHeight = config.compactMode and 14 or 20
    
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
        entryFrame:SetSize(400, entryHeight)
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
        amountText:SetPoint("LEFT", timeText, "RIGHT", 15, 0)
        
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
        directionText:SetPoint("LEFT", amountText, "RIGHT", 20, 0)
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

-- ENHANCED FLOATING TEXT SYSTEM WITH ANTI-FREEZE FIX
function BCT:DisplayFloatingText(text, color, size, isCrit, isOverkill, isDot, isGrouped)
    if not config.enabled then return end
    
    local textFrame = self:GetTextFromPool()
    if not textFrame then return end

    -- Limpiar estado previo completamente
    self:CleanupFloatingText(textFrame)
    
    -- Configurar nuevo estado
    textFrame.cleanupTimer = GetTime()
    textFrame.isActive = true
    textFrame.lastAnimationTime = GetTime()

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

    -- Detener animaciones previas completamente
    textFrame.animGroup:Stop()
    textFrame.animGroup:SetScript("OnFinished", nil)

    -- Enhanced animations based on type and animation style
    local moveDistance = isDot and 80 or 120
    local animDuration = config.fadeTime / config.animationSpeed
    
    if isCrit then 
        moveDistance = moveDistance * 1.8
    elseif isOverkill then
        moveDistance = moveDistance * 2.2
    end
    
    -- Enhanced animation system with multiple animation types
    if config.animationType == "bounce" then
        textFrame.moveAnim:SetOffset(0, moveDistance * 0.7)
        textFrame.moveAnim:SetDuration(animDuration * 0.6)
        textFrame.moveAnim:SetSmoothing("BOUNCE")
    elseif config.animationType == "spiral" then
        textFrame.moveAnim:SetOffset(math.random(-50, 50), moveDistance)
        textFrame.moveAnim:SetDuration(animDuration)
        textFrame.moveAnim:SetSmoothing("IN_OUT")
        
        -- Add rotation for spiral effect
        if config.rotationEffects then
            textFrame.rotateAnim:SetDegrees(math.random(-180, 180))
            textFrame.rotateAnim:SetDuration(animDuration)
            textFrame.rotateAnim:SetSmoothing("IN_OUT")
        end
    elseif config.animationType == "slide" then
        local slideDirection = math.random(1, 4)
        if slideDirection == 1 then -- Up
            textFrame.moveAnim:SetOffset(0, moveDistance)
        elseif slideDirection == 2 then -- Right
            textFrame.moveAnim:SetOffset(moveDistance * 0.8, moveDistance * 0.5)
        elseif slideDirection == 3 then -- Left
            textFrame.moveAnim:SetOffset(-moveDistance * 0.8, moveDistance * 0.5)
        else -- Up-diagonal
            textFrame.moveAnim:SetOffset(math.random(-30, 30), moveDistance)
        end
        textFrame.moveAnim:SetDuration(animDuration)
        textFrame.moveAnim:SetSmoothing("OUT")
    else -- default
        textFrame.moveAnim:SetOffset(0, moveDistance)
        textFrame.moveAnim:SetDuration(animDuration)
        textFrame.moveAnim:SetSmoothing("OUT")
    end

    textFrame.fadeAnim:SetFromAlpha(1)
    textFrame.fadeAnim:SetToAlpha(0)
    textFrame.fadeAnim:SetDuration(animDuration)
    textFrame.fadeAnim:SetStartDelay(animDuration * 0.4)

    -- Enhanced scale animation with particle effects
    if isCrit or isOverkill then
        local scaleAmount = isCrit and 1.4 or 1.6
        textFrame.scaleAnim:SetScale(scaleAmount, scaleAmount)
        textFrame.scaleAnim:SetDuration(0.4)
        textFrame.scaleAnim:SetSmoothing("BOUNCE")
        
        -- Added particle effects for critical hits
        if config.particleEffects and (isCrit or isOverkill) then
            textFrame.particleAnim:SetScale(1.8, 1.8)
            textFrame.particleAnim:SetDuration(0.2)
            textFrame.particleAnim:SetStartDelay(0.1)
            textFrame.particleAnim:SetSmoothing("OUT")
        end
    else
        textFrame.scaleAnim:SetScale(1, 1)
        textFrame.scaleAnim:SetDuration(0)
    end

    -- Play sound effects
    if config.soundEnabled then
        if isOverkill then
            PlaySound(37666) -- UI_RAID_BOSS_WHISPER_WARNING
        elseif isCrit then
            PlaySound(35675) -- UI_BNET_TOAST
        end
    end

    -- Configurar limpieza automática con múltiples failsafes
    textFrame.animGroup:SetScript("OnFinished", function()
        BCT:CleanupFloatingText(textFrame)
    end)

    -- Timer de seguridad para limpieza forzada
    textFrame:SetScript("OnUpdate", function(self, elapsed)
        if not self.isActive then return end
        
        local currentTime = GetTime()
        
        -- Limpieza por tiempo máximo
        if (currentTime - self.cleanupTimer) >= 10 then
            BCT:CleanupFloatingText(self)
            return
        end
        
        -- Limpieza si la animación debería haber terminado
        if (currentTime - self.cleanupTimer) >= (animDuration * 2) and not self.animGroup:IsPlaying() then
            BCT:CleanupFloatingText(self)
            return
        end
    end)

    -- Añadir a lista de activos
    table.insert(activeTexts, textFrame)
    
    -- Limitar número de textos activos
    if #activeTexts > config.maxNumbers then
        local oldest = table.remove(activeTexts, 1)
        if oldest and oldest.isActive then
            self:CleanupFloatingText(oldest)
        end
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

-- ENHANCED CLEANUP SYSTEM - ANTI-FREEZE FIX
function BCT:CleanupFloatingText(textFrame)
    if not textFrame then return end
    
    -- Marcar como inactivo inmediatamente
    textFrame.isActive = false
    textFrame.cleanupTimer = 0
    textFrame.lastAnimationTime = nil
    
    -- Detener todas las animaciones
    if textFrame.animGroup then
        textFrame.animGroup:Stop()
        textFrame.animGroup:SetScript("OnFinished", nil)
    end
    
    -- Limpiar scripts de actualización
    textFrame:SetScript("OnUpdate", nil)
    
    -- Ocultar y limpiar
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
    
    -- Remover de la lista de activos si existe
    for i = #activeTexts, 1, -1 do
        if activeTexts[i] == textFrame then
            table.remove(activeTexts, i)
            break
        end
    end
end

-- Enhanced text pool management with better cleanup
function BCT:GetTextFromPool()
    -- Buscar texto inactivo
    for i, text in ipairs(textPool) do
        if not text.isActive and not text:IsShown() then
            return text
        end
    end
    
    -- Si no hay textos disponibles, limpiar el más antiguo
    local oldestText = nil
    local oldestTime = GetTime()
    
    for i, text in ipairs(textPool) do
        if text.cleanupTimer and text.cleanupTimer < oldestTime then
            oldestText = text
            oldestTime = text.cleanupTimer
        end
    end
    
    if oldestText then
        self:CleanupFloatingText(oldestText)
        return oldestText
    end
    
    -- Create new text if pool is not full
    if #textPool < config.maxNumbers then
        local newText = self:CreateFloatingText()
        table.insert(textPool, newText)
        return newText
    end
    
    -- Forzar limpieza del primer texto
    local firstText = textPool[1]
    self:CleanupFloatingText(firstText)
    return firstText
end

-- Add cleanup all function for when combat ends
function BCT:CleanupAllFloatingText()
    for i, text in ipairs(textPool) do
        if text and text.isActive then
            self:CleanupFloatingText(text)
        end
    end
end

-- SISTEMA DE LIMPIEZA AUTOMÁTICA ANTI-CONGELAMIENTO
local cleanupTimer = nil

function BCT:ForceCleanupStuckText()
    local currentTime = GetTime()
    local cleaned = 0
    
    for i = #textPool, 1, -1 do
        local text = textPool[i]
        if text and text.isActive then
            -- Si el texto lleva más de 15 segundos activo, forzar limpieza
            if text.cleanupTimer and (currentTime - text.cleanupTimer) > 15 then
                self:CleanupFloatingText(text)
                cleaned = cleaned + 1
            -- Si el texto está visible pero no tiene animaciones corriendo
            elseif text:IsShown() and not text.animGroup:IsPlaying() then
                -- Verificar si lleva mucho tiempo sin animación
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
    
    -- Added critical streak tracking
    self:UpdateCritStreak(isCrit)
    
    -- Added DPS tracking for damage
    if isOutgoing then
        self:UpdateDPSTracker(amount, false)
    end
    
    -- Added advanced statistics tracking
    self:UpdateAdvancedStats(amount, isCrit, false, school)
    
    -- Update threat indicator
    self:UpdateThreatIndicator()
    
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
    
    -- Added critical streak tracking for healing
    self:UpdateCritStreak(isCrit)
    
    -- Added HPS tracking
    self:UpdateDPSTracker(amount, true)
    
    -- Added advanced statistics tracking for healing
    self:UpdateAdvancedStats(amount, isCrit, true, 2) -- Holy school for healing
    
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
    elseif school == 64 then return colors.arcane
    else return isCrit and colors.critDamage or colors.damage
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

-- Enhanced initialization
function BCT:OnLoad()
    -- Initialize text pool
    for i = 1, config.maxNumbers do
        local text = self:CreateFloatingText()
        table.insert(textPool, text)
    end
    
    -- Inicializar sistema de limpieza automática
    if cleanupTimer then
        cleanupTimer:Cancel()
    end
    cleanupTimer = C_Timer.NewTicker(5, function()
        BCT:ForceCleanupStuckText()
    end)
    
    -- Initialize character profiles
    self:AutoSwitchProfile()
    
    -- Create UI components
    self:CreateCombatLogPanel()
    
    print("|cff00ff00Better Combat Text Enhanced|r loaded successfully!")
    print("|cff00ff00BCT Fix:|r Sistema anti-congelamiento activado")
    print("|cff00ff00Minimum panel size:|r 450x400 pixels for optimal text display")
    
    -- Load saved settings
    if BCT_SavedSettings then
        for key, value in pairs(BCT_SavedSettings) do
            if config[key] ~= nil then
                config[key] = value
            end
        end
    end
    
    -- Load character profiles
    if BCT_CharacterProfiles then
        characterProfiles = BCT_CharacterProfiles
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
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Limpiar números antiguos al entrar en combate
        self:ForceCleanupStuckText()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        -- Auto switch profile when spec changes
        self:AutoSwitchProfile()
    elseif event == "PLAYER_LOGOUT" then
        -- Save settings and cleanup
        BCT_SavedSettings = {}
        for key, value in pairs(config) do
            BCT_SavedSettings[key] = value
        end
        
        -- Save character profiles
        BCT_CharacterProfiles = characterProfiles
        
        self:CleanupAllFloatingText()
        if cleanupTimer then
            cleanupTimer:Cancel()
        end
        
        -- Stop practice mode
        if practiceMode.running then
            self:StopPracticeMode()
        end
    end
end)

-- Register events including combat state changes
BCT:RegisterEvent("ADDON_LOADED")
BCT:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
BCT:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Combat ended
BCT:RegisterEvent("PLAYER_REGEN_DISABLED") -- Combat started
BCT:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED") -- Spec change for profile switching
BCT:RegisterEvent("PLAYER_LOGOUT")

-- Enhanced slash commands with cleanup
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
        
    -- Added stats command for advanced statistics panel
    elseif cmd == "stats" or cmd == "statistics" then
        BCT:ToggleAdvancedStatsPanel()
        
    -- Added resetstats command
    elseif cmd == "resetstats" then
        BCT:ResetAdvancedStats()
        
    -- Added practice mode commands
    elseif cmd == "practice" then
        if practiceMode.running then
            BCT:StopPracticeMode()
        else
            BCT:StartPracticeMode()
        end
        
    elseif cmd == "stoppractice" then
        BCT:StopPracticeMode()
        
    -- Added profile commands
    elseif cmd == "saveprofile" then
        BCT:SaveCurrentProfile()
        
    elseif cmd == "profiles" then
        print("|cff00ff00BCT:|r Available Profiles:")
        for key, profile in pairs(characterProfiles.profiles) do
            local current = (key == characterProfiles.currentProfile) and " (Current)" or ""
            print("  |cff00ffff" .. key .. "|r" .. current)
        end
        
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
        BCT:CleanupAllFloatingText()
        if combatLogFrame then BCT:UpdateCombatLogDisplay() end
        print("|cff00ff00BCT:|r Combat log cleared and floating text cleaned up")
        
    elseif cmd == "cleanup" or cmd == "clean" then
        BCT:CleanupAllFloatingText()
        BCT:ForceCleanupStuckText()
        print("|cff00ff00BCT:|r Limpieza forzada completada")
        
    elseif cmd == "reset" then
        -- Reset all settings to defaults
        config = {
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
            theme = "dark",
            opacity = 0.85,
            soundEnabled = true,
            showIcons = true,
            compactMode = false,
            autoHide = false,
            autoHideDelay = 5.0,
            showDPS = true,
            showHPS = true,
            showThreatIndicator = true,
            showCritStreaks = true,
            dpsUpdateInterval = 0.5,
            practiceMode = false,
            animationType = "default",
            particleEffects = true,
            rotationEffects = false
        }
        print("|cff00ff00BCT:|r Settings reset to defaults")
        
    elseif cmd == "help" or cmd == "" then
        print("|cff00ff00Better Combat Text Enhanced|r - Command List:")
        print("|cffFFFF00Main Commands:|r")
        print("  |cff00ffff/bct toggle|r - Enable/disable addon")
        print("  |cff00ffff/bct panel|r - Toggle combat log panel")
        print("  |cff00ffff/bct config|r - Open configuration window")
        print("  |cff00ffff/bct stats|r - Toggle advanced statistics panel")
        print("  |cff00ffff/bct test|r - Show test combat numbers")
        print("|cffFFFF00Utility Commands:|r")
        print("  |cff00ffff/bct clear|r - Clear combat log and cleanup floating text")
        print("  |cff00ffff/bct cleanup|r - Force cleanup stuck numbers")
        print("  |cff00ffff/bct reset|r - Reset all settings")
        print("  |cff00ffff/bct resetstats|r - Reset advanced statistics")
        print("|cffFFFF00Panel Info:|r")
        print("  |cff00ffff Minimum size:|r 450x400 pixels for optimal display")
        print("  |cff00ffff Auto-cleanup:|r Floating text clears after combat ends")
        print("  |cff00ffff Anti-freeze:|r Automatic cleanup every 5 seconds")
        
    else
        print("|cffFF0000BCT:|r Unknown command '" .. cmd .. "'. Type |cff00ffff/bct help|r for available commands.")
    end
end

print("|cff00ff00Better Combat Text Enhanced|r code loaded. Ready for initialization!")
