local addonName, private = ...

-- Default Database
private.defaultDB = {
    characters = {},
    settings = {
        showOnLogin = true,
        updateInterval = 300, 
        timeFormat = "complete",
        minimapPos = { angle = 45 }
    }
}

-- Data Sanitization
function private.SanitizeData()
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

-- Cleanup old data (+1 year)
function private.CleanupOldData()
    if not TimeTrackerDB or not TimeTrackerDB.characters then return end
    
    local thresholdTime = time() - (365 * 24 * 60 * 60)
    local thresholdStr = date("%Y-%m-%d", thresholdTime)
    
    for _, char in pairs(TimeTrackerDB.characters) do
        if char.daily then
            for dateStr, _ in pairs(char.daily) do
                if dateStr < thresholdStr then
                    char.daily[dateStr] = nil
                end
            end
        end
        if char.activityHistory and char.activityHistory.daily then
            for dateStr, _ in pairs(char.activityHistory.daily) do
                if dateStr < thresholdStr then
                    char.activityHistory.daily[dateStr] = nil
                end
            end
        end
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
function private.InitializeCharacter()
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
        if not char.activityHistory then 
             char.activityHistory = { daily = {}, weekly = {}, monthly = {}, yearly = {} }
        end
        if not char.activities then char.activities = { afk = 0, dungeons = 0, raids = 0 } end
    end
end

-- --- BACKUP SYSTEM (Serialization) ---
function private.SerializeDatabase()
    if not TimeTrackerDB then return "" end
    
    local function serialize(t)
        local s = "{"
        for k, v in pairs(t) do
            local key = type(k) == "string" and string.format("[%q]", k) or string.format("[%d]", k)
            local val
            if type(v) == "table" then
                val = serialize(v)
            elseif type(v) == "string" then
                val = string.format("%q", v)
            elseif type(v) == "number" or type(v) == "boolean" then
                val = tostring(v)
            end
            if val then s = s .. key .. "=" .. val .. "," end
        end
        return s .. "}"
    end
    
    local data = {
        version = private.addonVersion or "2.1",
        timestamp = time(),
        characters = TimeTrackerDB.characters
    }
    
    return "TT_BACKUP:" .. serialize(data)
end

function private.DeserializeDatabase(str)
    if not str or str == "" then return false end
    if not str:find("^TT_BACKUP:{") then return false end
    
    local code = str:gsub("^TT_BACKUP:", "")
    
    local func, err = loadstring("return " .. code)
    if not func then return false end
    
    setfenv(func, {})
    
    local success, result = pcall(func)
    if not success or not result or type(result) ~= "table" then return false end
    
    if result.characters then
        TimeTrackerDB.characters = result.characters
        return true, #result.characters
    end
    
    return false
end

-- Backfill Yearly Stats from Daily
function private.BackfillYearlyStats()
    if not TimeTrackerDB or not TimeTrackerDB.characters then return end
    local currentYear = private.GetCurrentYear()
    
    for key, char in pairs(TimeTrackerDB.characters) do
        if char.daily then
            local yearSum = 0
            for dateStr, seconds in pairs(char.daily) do
                local y = string.match(dateStr, "^(%d+)-")
                if y == currentYear then
                    yearSum = yearSum + seconds
                end
            end
            
            char.yearly = char.yearly or {}
            if yearSum > (char.yearly[currentYear] or 0) then
                char.yearly[currentYear] = yearSum
            end
        end
    end
end
