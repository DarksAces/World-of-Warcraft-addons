local addonName, private = ...

local TimeTracker = CreateFrame("Frame")
TimeTracker:RegisterEvent("ADDON_LOADED")
TimeTracker:RegisterEvent("PLAYER_LOGIN")
TimeTracker:RegisterEvent("PLAYER_LOGOUT")
TimeTracker:RegisterEvent("TIME_PLAYED_MSG")

-- Variables from private for convenience
local GetLocalizedText = private.GetLocalizedText

-- Global Variables
private.playerKey = ""
private.playerName = ""
private.realmName = ""

local sessionStartTime = 0
local lastUpdateTime = 0
local isRequestingTime = false
local updateTimer = nil
local TimeTrackerFrame = nil

-- Default Database
local defaultDB = {
    characters = {},
    settings = {
        showOnLogin = true,
        updateInterval = 300, 
        timeFormat = "complete",
        minimapPos = { angle = 45 }
    }
}

-- Data Sanitization
local function SanitizeData()
    if not TimeTrackerDB or not TimeTrackerDB.characters then return end
    for key, char in pairs(TimeTrackerDB.characters) do
        if char.daily then
            for dateStr, seconds in pairs(char.daily) do
                if seconds > 86400 then 
                    -- Reset to 0 if > 24h as it's definitely corrupted data
                    char.daily[dateStr] = 0 
                end
            end
        end
    end
end

-- Format Helpers (Exposed to private for UI)
function private.GetCurrentDate()
    return date("%Y-%m-%d")
end

function private.GetCurrentWeek()
    local t = date("*t")
    local dayOfWeek = t.wday == 1 and 7 or t.wday - 1
    local startOfWeek = time(t) - (dayOfWeek - 1) * 24 * 60 * 60
    return date("%Y-W%U", startOfWeek)
end

function private.GetCurrentMonth()
    return date("%Y-%m")
end

function private.GetCurrentYear()
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
    else -- complete
        local result = ""
        if days > 0 then result = result .. days .. "d " end
        if hours > 0 then result = result .. hours .. "h " end
        if minutes > 0 or result == "" then result = result .. minutes .. "m" end
        return result:match("^%s*(.-)%s*$") 
    end
end

-- Account Totals Helper
function private.GetAccountDailyTotals()
    local totals = {}
    if TimeTrackerDB and TimeTrackerDB.characters then
        for _, char in pairs(TimeTrackerDB.characters) do
            if char.daily then
                for dateStr, seconds in pairs(char.daily) do
                    totals[dateStr] = (totals[dateStr] or 0) + seconds
                end
            end
        end
    end
    return totals
end

-- Database Init
local function InitializeCharacter()
    local className, classFilename = UnitClass("player")
    local raceName, raceFile = UnitRace("player")
    
    if not TimeTrackerDB.characters[private.playerKey] then
        TimeTrackerDB.characters[private.playerKey] = {
            name = private.playerName,
            realm = private.realmName,
            class = className,
            classFile = classFilename,
            race = raceName,
            raceFile = raceFile,
            level = UnitLevel("player"),
            totalTime = 0,
            levelTime = 0,
            daily = {},
            weekly = {},
            monthly = {},
            yearly = {},
            sessions = {}, 
            activities = { afk = 0, dungeons = 0, raids = 0 },
            activitiesYearly = {},
            lastLogin = time(),
            firstLogin = time(),
            baseTime = nil,
            lastKnownTime = nil
        }
    else
        local char = TimeTrackerDB.characters[private.playerKey]
        char.class = className
        char.classFile = classFilename
        char.race = raceName
        char.raceFile = raceFile
        char.level = UnitLevel("player")
        char.lastLogin = time()
        if not char.firstLogin then char.firstLogin = time() end
        if not char.yearly then char.yearly = {} end
        -- detailed activity history
        if not char.activityHistory then 
             char.activityHistory = { daily = {}, weekly = {}, monthly = {}, yearly = {} }
        end
        -- keep simple totals for backward compat or quick access if needed, but primarily use history now
        if not char.activities then char.activities = { afk = 0, dungeons = 0, raids = 0 } end
    end
end

-- Tracking State
local lastTickState = { time = GetTime() }

local function SafeUnitIsAFK()
    local success, result = pcall(function()
        if UnitIsAFK("player") then return true end
        return false
    end)
    return success and result
end
local function UpdateActivityTime()
    local currentTime = GetTime()
    local delta = currentTime - lastTickState.time
    lastTickState.time = currentTime
    if delta > 30 then delta = 1 end -- Prevent huge leaps
    
    local char = TimeTrackerDB.characters[private.playerKey]
    if not char then return end
    if not char.activityHistory then char.activityHistory = { daily = {}, weekly = {}, monthly = {}, yearly = {} } end
    if not char.activities then char.activities = { afk = 0, dungeons = 0, raids = 0 } end

    local dateStr = private.GetCurrentDate()
    local weekId = private.GetCurrentWeek()
    local monthId = private.GetCurrentMonth()
    local yearId = private.GetCurrentYear()
    
    -- Helper to update table
    local function AddToTable(tbl, key, field, amount)
        if not tbl[key] then tbl[key] = { afk = 0, dungeons = 0, raids = 0 } end
        tbl[key][field] = (tbl[key][field] or 0) + amount
    end

    local activity = nil
    
    -- Check Pet Battles
    if C_PetBattles and C_PetBattles.IsInBattle() then
        activity = "petbattles"
    -- Check Taxi (Flight Path)
    elseif UnitOnTaxi("player") then
        activity = "taxi"
    -- Check Dead / Ghost
    elseif UnitIsDeadOrGhost("player") then
        activity = "dead"
    -- AFK Check
    elseif SafeUnitIsAFK() then
        activity = "afk"
    else
        local inInstance, instanceType = IsInInstance()
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
        
        -- If not in an instance activity, check world activities
        if not activity then
            -- Check Auction House
            if (AuctionHouseFrame and AuctionHouseFrame:IsShown()) or (AuctionFrame and AuctionFrame:IsShown()) then
                activity = "auction"
            -- Check Professions
            elseif (ProfessionsFrame and ProfessionsFrame:IsShown()) or (TradeSkillFrame and TradeSkillFrame:IsShown()) then
                activity = "professions"
            -- Check Resting (City / Inn)
            elseif IsResting() then
                activity = "city"
            -- Default to World Content
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
    
    -- Queue Tracking (Can exist alongside other activities)
    local inQueue = false
    -- Check LFG Queues
    for i = 1, 6 do -- Iterate LFG categories
        local mode = GetLFGMode(i)
        if mode == "queued" then inQueue = true; break end
    end
    -- Check PvP Queues
    if not inQueue then
        for i = 1, GetMaxBattlefieldID() do
            local status = GetBattlefieldStatus(i)
            if status == "queued" then inQueue = true; break end
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
 
-- Helper for updating play time (Local to this file scope, but needs access to DB)
local function UpdatePlayTime(totalTime, levelTime)
    local char = TimeTrackerDB.characters[private.playerKey]
    if not char then return end
    
    local currentDate = private.GetCurrentDate()
    local currentWeek = private.GetCurrentWeek()
    local currentMonth = private.GetCurrentMonth()
    local currentYear = private.GetCurrentYear()
    local currentTime = time()
    
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
        
        -- Sanity check: Only ignore if negative or absurdly high 
        -- Limit to 8 hours (28800s). If jump is larger, we skip adding to daily stats to avoid corruption from bugs/long offline.
        if timePlayed > 0 and timePlayed < 28800 then
            char.daily[currentDate] = char.daily[currentDate] + timePlayed
            char.weekly[currentWeek] = char.weekly[currentWeek] + timePlayed
            char.monthly[currentMonth] = char.monthly[currentMonth] + timePlayed
            char.yearly[currentYear] = char.yearly[currentYear] + timePlayed
        end
        
        -- ALWAYS update lastKnownTime to avoid getting stuck in a loop where difference keeps growing
        char.lastKnownTime = totalTime
        lastUpdateTime = currentTime
    end
end

-- Request Time
function private.RequestTimePlayed()
    RequestTimePlayed() 
end
local function SafeRequestTime()
    RequestTimePlayed()
    isRequestingTime = true
end

-- Timer
local function StartUpdateTimer()
    if updateTimer then updateTimer:Cancel() end
    local interval = TimeTrackerDB and TimeTrackerDB.settings.updateInterval or 300
    updateTimer = C_Timer.NewTicker(interval, function()
        if private.playerKey and TimeTrackerDB and TimeTrackerDB.characters[private.playerKey] then
            SafeRequestTime()
        end
    end)
    
    -- New Activity Ticker (1 sec)
    if activityTimer then activityTimer:Cancel() end
    activityTimer = C_Timer.NewTicker(1, function()
        UpdateActivityTime()
    end)
end

-- Slash Commands
SLASH_TIMETRACKER1 = "/timetrack"
SLASH_TIMETRACKER2 = "/timetracker"
function SlashCmdList.TIMETRACKER(msg)
    local command = string.lower(msg or "")
    if command == "show" or command == "" then
        if TimeTrackerFrame then
            if TimeTrackerFrame:IsShown() then
                TimeTrackerFrame:Hide()
            else
                TimeTrackerFrame:Show()
                -- Refresh active tab
                if TimeTrackerFrame.tabPersonal.selected then
                    private.UpdateCurrentCharacterStats(TimeTrackerFrame)
                elseif TimeTrackerFrame.tabCharacters.selected then
                    private.UpdateCharactersStats(TimeTrackerFrame)
                elseif TimeTrackerFrame.tabClasses.selected then
                    private.UpdateClassesStats(TimeTrackerFrame)
                elseif TimeTrackerFrame.tabRaces.selected then
                    private.UpdateRacesStats(TimeTrackerFrame)
                elseif TimeTrackerFrame.tabHistory and TimeTrackerFrame.tabHistory.selected then
                    private.UpdateHistoryStats(TimeTrackerFrame)
                end
                
                -- Update Buttons text if needed
                local fmt = TimeTrackerDB.settings.timeFormat or "complete"
                local textMap = {
                    hours = GetLocalizedText("ONLY_HOURS"), 
                    minutes = GetLocalizedText("ONLY_MINUTES"), 
                    seconds = GetLocalizedText("ONLY_SECONDS"), 
                    complete = GetLocalizedText("COMPLETE_FORMAT")
                }
                UIDropDownMenu_SetText(TimeTrackerFrame.personalFormatDropdown, textMap[fmt])
                UIDropDownMenu_SetText(TimeTrackerFrame.charFormatDropdown, textMap[fmt])
                UIDropDownMenu_SetText(TimeTrackerFrame.classFormatDropdown, textMap[fmt])
                UIDropDownMenu_SetText(TimeTrackerFrame.raceFormatDropdown, textMap[fmt])
            end
        end
    elseif command == "time" then
        SafeRequestTime()
        print("Time Tracker: " .. GetLocalizedText("GETTING_TIME"))
    elseif command == "stats" then
        local char = TimeTrackerDB.characters[private.playerKey]
        if char then
            local fmt = TimeTrackerDB.settings.timeFormat
            print("Time Tracker - " .. GetLocalizedText("QUICK_STATS_TITLE"))
            print(GetLocalizedText("TOTAL") .. ": " .. private.FormatTime(char.totalTime, fmt))
            print(GetLocalizedText("TODAY") .. ": " .. private.FormatTime(char.daily[private.GetCurrentDate()] or 0, fmt))
            print(GetLocalizedText("THIS_WEEK") .. ": " .. private.FormatTime(char.weekly[private.GetCurrentWeek()] or 0, fmt))
        else
            print("Time Tracker: " .. GetLocalizedText("NO_DATA"))
        end
    elseif command == "format" then
        print("Time Tracker - " .. GetLocalizedText("FORMATS_AVAILABLE"))
        -- ... simplified text output
        print(GetLocalizedText("CURRENT_FORMAT") .. " " .. (TimeTrackerDB.settings.timeFormat or "complete"))
        print(GetLocalizedText("CHANGE_FORMAT"))
    else
        print("Time Tracker - " .. GetLocalizedText("COMMANDS_AVAILABLE"))
        print("/timetrack show - " .. GetLocalizedText("SHOW_HIDE_WINDOW"))
        print("/timetrack time - " .. GetLocalizedText("GET_TIME_PLAYED"))
        print("/timetrack stats - " .. GetLocalizedText("QUICK_STATS"))
        print("/timetrack format - " .. GetLocalizedText("FORMAT_INFO"))
    end
end

-- Backfill Yearly Stats from Daily
local function BackfillYearlyStats()
    if not TimeTrackerDB or not TimeTrackerDB.characters then return end
    local currentYear = private.GetCurrentYear()
    
    for key, char in pairs(TimeTrackerDB.characters) do
        if char.daily then
            local yearSum = 0
            for dateStr, seconds in pairs(char.daily) do
                -- Extracts YYYY from YYYY-MM-DD
                local y = string.match(dateStr, "^(%d+)-")
                if y == currentYear then
                    yearSum = yearSum + seconds
                end
            end
            
            char.yearly = char.yearly or {}
            -- Only update if calculated sum is greater (to avoid overwriting if we already tracked some, though sum should be accurate source of truth)
            if yearSum > (char.yearly[currentYear] or 0) then
                char.yearly[currentYear] = yearSum
            end
        end
    end
end

-- Events
TimeTracker:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...
    if event == "ADDON_LOADED" and arg1 == "TimeTracker" then
        if not TimeTrackerDB then TimeTrackerDB = CopyTable(defaultDB) end
        if not TimeTrackerDB.settings.timeFormat then TimeTrackerDB.settings.timeFormat = "complete" end
        
        -- Run sanitization
        SanitizeData()

        -- Run backfill to populate yearly stats from existing daily data
        BackfillYearlyStats()
        
        -- Cleanup legacy sessions data
        if TimeTrackerDB and TimeTrackerDB.characters then
            for _, char in pairs(TimeTrackerDB.characters) do
                if char.sessions then char.sessions = nil end
            end
        end
        
        -- Build UI
        TimeTrackerFrame = private.CreateMainFrame()
        print(GetLocalizedText("ADDON_LOADED"))
        
        -- Init Minimap Button
        C_Timer.After(2, function()
            private.CreateMinimapButton()
        end)
        
    elseif event == "PLAYER_LOGIN" then
        private.playerName = UnitName("player")
        private.realmName = GetRealmName()
        private.playerKey = private.playerName .. "-" .. private.realmName
        sessionStartTime = time()
        lastUpdateTime = time()
        
        InitializeCharacter()
        
        C_Timer.After(5, function()
            SafeRequestTime()
            StartUpdateTimer()
        end)
        
        if TimeTrackerDB.settings.showOnLogin then
            print("Time Tracker: " .. string.format(GetLocalizedText("WELCOME"), private.playerName))
        end
        
    elseif event == "PLAYER_LOGOUT" then
        local sessionEnd = time()
        if sessionStartTime > 0 then
            local sessionDuration = sessionEnd - sessionStartTime
            
            -- Session History Logic removed (Legacy)
            
            UpdatePlayTime(nil, nil)
        end
        
    elseif event == "TIME_PLAYED_MSG" then
        local totalTime, levelTime = ...
        if isRequestingTime then
            UpdatePlayTime(totalTime, levelTime)
            isRequestingTime = false
            
            if TimeTrackerFrame and TimeTrackerFrame:IsShown() then
                 if TimeTrackerFrame.tabPersonal.selected then
                    private.UpdateCurrentCharacterStats(TimeTrackerFrame)
                elseif TimeTrackerFrame.tabCharacters and TimeTrackerFrame.tabCharacters.selected then
                    private.UpdateCharactersStats(TimeTrackerFrame)
                elseif TimeTrackerFrame.tabClasses and TimeTrackerFrame.tabClasses.selected then
                    private.UpdateClassesStats(TimeTrackerFrame)
                elseif TimeTrackerFrame.tabRaces and TimeTrackerFrame.tabRaces.selected then
                    private.UpdateRacesStats(TimeTrackerFrame)
                elseif TimeTrackerFrame.tabHistory and TimeTrackerFrame.tabHistory.selected then
                    private.UpdateHistoryStats(TimeTrackerFrame)
                end
            end
        end
    end
end)