-- VoidWhispers: A thematic reminder addon for WoW
-- Author: Daniel

local ADDON_NAME = "VoidWhispers"
local ADDON_COLOR = "|cff9482c9" -- Void Purple
local WHISPER_COLOR = "|cffb19cd9" -- Lighter Purple for whispers

-- Database defaults
local defaults = {
    reminders = {},
    notes = {}
}

-- Frame for event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

-- Helper: Print with Void theme
local function VoidPrint(msg)
    print(ADDON_COLOR .. "[VoidWhispers]|r " .. msg)
end

-- Helper: Parse time string (e.g., "10m", "1h", "30s")
local function ParseTime(timeStr)
    if not timeStr then return nil end
    local multiplier = 1
    local unit = string.sub(timeStr, -1)
    local value = tonumber(string.sub(timeStr, 1, -2))

    if not value then
        -- Try parsing as just a number (seconds)
        value = tonumber(timeStr)
        if value then return value end
        return nil
    end

    if unit == "s" then multiplier = 1
    elseif unit == "m" then multiplier = 60
    elseif unit == "h" then multiplier = 3600
    else return nil end

    return value * multiplier
end

-- Helper: Void-ify text (Zalgo-lite effect or just ominous phrasing)
local voidPhrases = {
    "The Void sees all...",
    "Do not forget...",
    "It whispers...",
    "Time is an illusion...",
    "The shadows lengthen...",
    "Midnight comes...",
}

local function GetVoidWhisper()
    return voidPhrases[math.random(#voidPhrases)]
end

-- Reminder System
local function CheckReminders()
    if not VoidWhispersDB then return end
    
    local now = GetTime()
    local pending = {}
    
    for i, reminder in ipairs(VoidWhispersDB.reminders) do
        if reminder.due <= now then
            -- Trigger reminder
            PlaySound(12867) -- Ominous sound (e.g., Shadow Priest sound or similar)
            RaidNotice_AddMessage(RaidWarningFrame, WHISPER_COLOR .. GetVoidWhisper() .. "|n" .. reminder.msg .. "|r", ChatTypeInfo["RAID_WARNING"])
            print(ADDON_COLOR .. "[The Void Whispers]:|r " .. WHISPER_COLOR .. reminder.msg .. "|r")
        else
            table.insert(pending, reminder)
        end
    end
    
    VoidWhispersDB.reminders = pending
end

-- Main Loop
C_Timer.NewTicker(1, CheckReminders)

-- Slash Command Handler
local function HandleSlash(msg)
    local args = {}
    for word in msg:gmatch("%S+") do table.insert(args, word) end

    local command = args[1]
    
    if command == "note" then
        local note = table.concat(args, " ", 2)
        if note and note ~= "" then
            table.insert(VoidWhispersDB.notes, note)
            VoidPrint("Note consumed by the Void.")
        else
            VoidPrint("The Void requires substance. (/void note <text>)")
        end
        
    elseif command == "remind" then
        local timeStr = args[2]
        local msgText = table.concat(args, " ", 3)
        
        local seconds = ParseTime(timeStr)
        
        if seconds and msgText and msgText ~= "" then
            table.insert(VoidWhispersDB.reminders, {
                due = GetTime() + seconds,
                msg = msgText
            })
            VoidPrint("The Void will remind you in " .. timeStr .. ".")
        else
            VoidPrint("Invalid ritual. Usage: /void remind <time> <text> (e.g. 10m Check Auction)")
        end
        
    elseif command == "list" then
        VoidPrint("--- Pending Whispers ---")
        if #VoidWhispersDB.reminders == 0 then
            print("   " .. WHISPER_COLOR .. "Silence..." .. "|r")
        else
            for i, r in ipairs(VoidWhispersDB.reminders) do
                local remaining = math.ceil(r.due - GetTime())
                print(string.format("   %d. %s (%ds)", i, r.msg, remaining))
            end
        end
        
        VoidPrint("--- Void Notes ---")
        if #VoidWhispersDB.notes == 0 then
            print("   " .. WHISPER_COLOR .. "Empty..." .. "|r")
        else
            for i, n in ipairs(VoidWhispersDB.notes) do
                print("   " .. i .. ". " .. n)
            end
        end

    elseif command == "clear" then
        VoidWhispersDB.reminders = {}
        VoidWhispersDB.notes = {}
        VoidPrint("The slate is wiped clean... for now.")
        
    else
        VoidPrint("Commands: note, remind, list, clear")
    end
end

-- Event Handler
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        if not VoidWhispersDB then VoidWhispersDB = CopyTable(defaults) end
        VoidPrint("The Void has awakened. (/void)")
    end
end)

-- Register Slash Commands
SLASH_VOIDWHISPERS1 = "/void"
SLASH_VOIDWHISPERS2 = "/vw"
SlashCmdList["VOIDWHISPERS"] = HandleSlash
