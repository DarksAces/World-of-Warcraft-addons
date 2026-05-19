local addonName, private = ...

local TimeTracker = CreateFrame("Frame")
TimeTracker:RegisterEvent("ADDON_LOADED")
TimeTracker:RegisterEvent("PLAYER_LOGIN")
TimeTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
TimeTracker:RegisterEvent("PLAYER_LOGOUT")
TimeTracker:RegisterEvent("TIME_PLAYED_MSG")

-- Variables from private for convenience
local GetLocalizedText = private.GetLocalizedText

-- Global Variables (exposed to private for other modules)
private.playerKey = ""
private.playerName = ""
private.realmName = ""

-- Tracking State Variables
local sessionStartTime = 0
local lastUpdateTime = 0
private.isRequestingTime = false
local updateTimer = nil
local activityTimer = nil

-- Formatting Helpers
function private.GetCurrentDate()
    if C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime then
        local d = C_DateAndTime.GetCurrentCalendarTime()
        return string.format("%04d-%02d-%02d", d.year, d.month, d.monthDay)
    end
    return date("%Y-%m-%d")
end

function private.GetCurrentWeek()
    local t = date("*t")
    local dayOfWeek = t.wday == 1 and 7 or t.wday - 1
    local startOfWeek = time(t) - (dayOfWeek - 1) * 24 * 60 * 60
    return date("%Y-W%U", startOfWeek)
end

function private.GetCurrentMonth()
    if C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime then
        local d = C_DateAndTime.GetCurrentCalendarTime()
        return string.format("%04d-%02d", d.year, d.month)
    end
    return date("%Y-%m")
end

function private.GetCurrentYear()
    if C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime then
        local d = C_DateAndTime.GetCurrentCalendarTime()
        return string.format("%04d", d.year)
    end
    return date("%Y")
end

function private.FormatTime(seconds, format)
    if not seconds or seconds <= 0 then
        if format == "hours" then return "0h"
        elseif format == "minutes" then return "0m"
        elseif format == "seconds" then return "0s"
        else return "0m" end
    end
    
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    
    if format == "hours" then
        return math.floor(seconds / 3600) .. "h"
    elseif format == "minutes" then
        return math.floor(seconds / 60) .. "m"
    elseif format == "seconds" then
        return seconds .. "s"
    else
        local result = ""
        if days > 0 then result = result .. days .. "d " end
        if hours > 0 then result = result .. hours .. "h " end
        if minutes > 0 or result == "" then result = result .. minutes .. "m" end
        return result:match("^%s*(.-)%s*$") 
    end
end

-- Tracking State
local lastTickState = { time = GetTime() }

local function SafeCallBoolean(func, ...)
    local args = {...}
    local success, res = pcall(function()
        if func(unpack(args)) then
            return true
        end
        return false
    end)
    if success then
        return res
    end
    return false
end

local function SafeUnitIsAFK()
    return SafeCallBoolean(UnitIsAFK, "player")
end

local function SafeUnitIsDeadOrGhost()
    return SafeCallBoolean(UnitIsDeadOrGhost, "player")
end

local function SafeUnitOnTaxi()
    return SafeCallBoolean(UnitOnTaxi, "player")
end

local function SafeIsResting()
    return SafeCallBoolean(IsResting)
end

local function SafeIsInBattle()
    if not (C_PetBattles and C_PetBattles.IsInBattle) then return false end
    return SafeCallBoolean(C_PetBattles.IsInBattle)
end

local function SafeIsInInstance()
    local success, inInstance, instanceType = pcall(function()
        local inInst, instType = IsInInstance()
        if inInst then
            return true, instType
        end
        return false, nil
    end)
    if success then
        return inInstance, instanceType
    end
    return false, nil
end

local function UpdateActivityTime()
    local currentTime = GetTime()
    local delta = currentTime - lastTickState.time
    lastTickState.time = currentTime
    if delta > 30 then delta = 1 end 
    
    local char = TimeTrackerDB.characters[private.playerKey]
    if not char then return end
    if not char.activityHistory then char.activityHistory = { daily = {}, weekly = {}, monthly = {}, yearly = {} } end
    if not char.activities then char.activities = { afk = 0, dungeons = 0, raids = 0 } end

    local dateStr = private.GetCurrentDate()
    local weekId = private.GetCurrentWeek()
    local monthId = private.GetCurrentMonth()
    local yearId = private.GetCurrentYear()
    
    local function AddToTable(tbl, key, field, amount)
        if not tbl[key] then tbl[key] = { afk = 0, dungeons = 0, raids = 0 } end
        tbl[key][field] = (tbl[key][field] or 0) + amount
    end

    local activity = nil
    if SafeIsInBattle() then
        activity = "petbattles"
    elseif SafeUnitOnTaxi() then
        activity = "taxi"
    elseif SafeUnitIsDeadOrGhost() then
        activity = "dead"
    elseif SafeUnitIsAFK() then
        activity = "afk"
    else
        local inInstance, instanceType = SafeIsInInstance()
        if inInstance then
            if instanceType == "party" then
                activity = "dungeons"
            elseif instanceType == "scenario" then
                activity = "scenarios"
            elseif instanceType == "raid" then
                activity = "raids"
            elseif instanceType == "pvp" then
                activity = "bgs"
            elseif instanceType == "arena" then
                activity = "arenas"
            end
        end
        if not activity then
            if (AuctionHouseFrame and AuctionHouseFrame:IsShown()) or (AuctionFrame and AuctionFrame:IsShown()) then
                activity = "auction"
            elseif (ProfessionsFrame and ProfessionsFrame:IsShown()) or (TradeSkillFrame and TradeSkillFrame:IsShown()) then
                activity = "professions"
            elseif SafeIsResting() then
                activity = "city"
            else
                activity = "world"
            end
        end
    end

    if activity then
        char.activities[activity] = (char.activities[activity] or 0) + delta
        AddToTable(char.activityHistory.daily, dateStr, activity, delta)
        AddToTable(char.activityHistory.weekly, weekId, activity, delta)
        AddToTable(char.activityHistory.monthly, monthId, activity, delta)
        AddToTable(char.activityHistory.yearly, yearId, activity, delta)
    end
    
    if sessionStartTime > 0 then
        local sessionDuration = time() - sessionStartTime
        if private.ldbObject then
            private.ldbObject.text = "Sesión: " .. private.FormatTime(sessionDuration, "complete")
        end
        if TimeTrackerDB.settings.breakReminder then
            if not private.lastBreakReminder then private.lastBreakReminder = 0 end
            if sessionDuration > (private.lastBreakReminder + 7200) then
                print("|cff00ccff[Time Tracker]|r: Llevas más de 2 horas jugando seguidas. ¡Aprovecha para levantarte, estirar y beber agua!")
                private.lastBreakReminder = sessionDuration
            end
        end
    end
    
    local inQueue = false
    for i = 1, 6 do
        local success, mode = pcall(GetLFGMode, i)
        if success and mode == "queued" then inQueue = true; break end
    end
    if not inQueue then
        local success, maxID = pcall(GetMaxBattlefieldID)
        if success and type(maxID) == "number" then
            for i = 1, maxID do
                local s, status = pcall(GetBattlefieldStatus, i)
                if s and status == "queued" then inQueue = true; break end
            end
        end
    end
    
    if inQueue then
        local qKey = "queues"
        char.activities[qKey] = (char.activities[qKey] or 0) + delta
        AddToTable(char.activityHistory.daily, dateStr, qKey, delta)
        AddToTable(char.activityHistory.weekly, weekId, qKey, delta)
        AddToTable(char.activityHistory.monthly, monthId, qKey, delta)
        AddToTable(char.activityHistory.yearly, yearId, qKey, delta)
    end
end
 
local function UpdatePlayTime(totalTime, levelTime)
    local char = TimeTrackerDB.characters[private.playerKey]
    if not char then return end
    
    local currentDate = private.GetCurrentDate()
    local currentWeek = private.GetCurrentWeek()
    local currentMonth = private.GetCurrentMonth()
    local currentYear = private.GetCurrentYear()
    
    if totalTime and totalTime > 0 then
        char.totalTime = totalTime
        char.levelTime = levelTime or 0
        
        if not char.baseTime then
            char.baseTime = totalTime
            char.lastKnownTime = totalTime
        end
        
        local timePlayed = 0
        if char.lastKnownTime and totalTime > char.lastKnownTime then
            timePlayed = totalTime - char.lastKnownTime
        end
        
        char.daily = char.daily or {}
        char.weekly = char.weekly or {}
        char.monthly = char.monthly or {}
        char.yearly = char.yearly or {}
        
        char.daily[currentDate] = (char.daily[currentDate] or 0)
        char.weekly[currentWeek] = (char.weekly[currentWeek] or 0)
        char.monthly[currentMonth] = (char.monthly[currentMonth] or 0)
        char.yearly[currentYear] = (char.yearly[currentYear] or 0)
        
        if timePlayed > 0 and timePlayed < 28800 then
            char.daily[currentDate] = char.daily[currentDate] + timePlayed
            char.weekly[currentWeek] = char.weekly[currentWeek] + timePlayed
            char.monthly[currentMonth] = char.monthly[currentMonth] + timePlayed
            char.yearly[currentYear] = char.yearly[currentYear] + timePlayed
        end
        
        char.lastKnownTime = totalTime
    end

    if private.SanitizeData then private.SanitizeData() end
    if private.CleanupOldData then private.CleanupOldData() end
end

function private.RequestTimePlayed()
    RequestTimePlayed() 
end

function private.SafeRequestTime()
    private.isRequestingTime = true
    RequestTimePlayed()
end

local function BlockTimePlayedMessage(self, event, msg)
    if private.isRequestingTime then
        return true
    end
    return false
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", BlockTimePlayedMessage)

local function StartUpdateTimer()
    if updateTimer then updateTimer:Cancel() end
    local interval = TimeTrackerDB and TimeTrackerDB.settings.updateInterval or 300
    updateTimer = C_Timer.NewTicker(interval, function()
        if private.playerKey and TimeTrackerDB and TimeTrackerDB.characters[private.playerKey] then
            private.SafeRequestTime()
        end
    end)
    
    if activityTimer then activityTimer:Cancel() end
    activityTimer = C_Timer.NewTicker(10, function()
        UpdateActivityTime()
    end)
end

-- Events
TimeTracker:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...
    if event == "ADDON_LOADED" and arg1 == "TimeTracker" then
        if not TimeTrackerDB then TimeTrackerDB = CopyTable(private.defaultDB or {}) end
        if not TimeTrackerDB.settings.timeFormat then TimeTrackerDB.settings.timeFormat = "complete" end
        
        if private.SanitizeData then private.SanitizeData() end
        if private.CleanupOldData then private.CleanupOldData() end
        if private.BackfillYearlyStats then private.BackfillYearlyStats() end
        
        if TimeTrackerDB and TimeTrackerDB.characters then
            for _, char in pairs(TimeTrackerDB.characters) do
                if char.sessions then char.sessions = nil end
            end
        end
        
        private.TimeTrackerFrame = private.CreateMainFrame()
        print(GetLocalizedText("ADDON_LOADED"))
        
        if private.CreateOptionsPanel then private.CreateOptionsPanel() end
        if private.InitDataBroker then private.InitDataBroker() end
        
        C_Timer.After(2, function()
            private.CreateMinimapButton()
        end)
        
    elseif event == "PLAYER_LOGIN" then
        private.playerName = UnitName("player")
        private.realmName = GetRealmName()
        private.playerKey = private.playerName .. "-" .. private.realmName
        sessionStartTime = time()
        lastUpdateTime = time()
        
        if private.InitializeCharacter then private.InitializeCharacter() end
        
        C_Timer.After(5, function()
            private.SafeRequestTime()
            StartUpdateTimer()
        end)
        
        if TimeTrackerDB.settings.showOnLogin then
            print("Time Tracker: " .. string.format(GetLocalizedText("WELCOME"), private.playerName))
        end
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        if private.playerKey and TimeTrackerDB and TimeTrackerDB.characters[private.playerKey] then
            TimeTrackerDB.characters[private.playerKey].level = UnitLevel("player")
        end
        
    elseif event == "PLAYER_LOGOUT" then
        if sessionStartTime > 0 then
            UpdatePlayTime(nil, nil)
        end
        
    elseif event == "TIME_PLAYED_MSG" then
        local totalTime, levelTime = ...
        if private.isRequestingTime then
            UpdatePlayTime(totalTime, levelTime)
            private.isRequestingTime = false
            
            local f = private.TimeTrackerFrame
            if f and f:IsShown() then
                 if f.tabPersonal and f.tabPersonal.selected then private.UpdateCurrentCharacterStats(f)
                elseif f.tabCharacters and f.tabCharacters.selected then private.UpdateCharactersStats(f)
                elseif f.tabClasses and f.tabClasses.selected then private.UpdateClassesStats(f)
                elseif f.tabRaces and f.tabRaces.selected then private.UpdateRacesStats(f)
                elseif f.tabHistory and f.tabHistory.selected then private.UpdateHistoryStats(f)
                end
            end
        end
    end
end)