local frame = CreateFrame("Frame")

-- Lista de 30 emotes variados y divertidos
local emotes = {
    "dance", "laugh", "cheer", "victory", "wave", "kiss", "sorry", "bow", "flex", "roar",
    "fart", "rude", "cry", "cackle", "panic", "chicken", "blink", "salute", "train", "clap",
    "hello", "goodbye", "sleep", "point", "shrug", "no", "yes", "agree", "disagree", "think"
}

local emotesEnabled = true

local function RandomEmote()
    if not emotesEnabled then return end
    local emoteIndex = math.random(1, #emotes)
    local emote = emotes[emoteIndex]
    DoEmote(emote)
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, eventType, _, sourceGUID = CombatLogGetCurrentEventInfo()
        if (eventType == "UNIT_DIED" or eventType == "PARTY_KILL") and sourceGUID == UnitGUID("player") then
            RandomEmote()
        end
    end
end)

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Comandos slash para activar/desactivar y alternar
SLASH_BETTEREMOTES1 = "/betteremotes"
SLASH_BETTEREMOTES2 = "/bemotes"

local function PrintUsage()
    print("|cff00ff00BetterEmotes|r comandos:")
    print("|cff00ffff/betteremotes on|r - Activar emotes")
    print("|cff00ffff/betteremotes off|r - Desactivar emotes")
    print("|cff00ffff/betteremotes toggle|r - Alternar estado")
end

SlashCmdList["BETTEREMOTES"] = function(msg)
    msg = msg:lower()
    if msg == "on" then
        emotesEnabled = true
        print("|cff00ff00BetterEmotes activado.|r")
    elseif msg == "off" then
        emotesEnabled = false
        print("|cffff0000BetterEmotes desactivado.|r")
    elseif msg == "toggle" then
        emotesEnabled = not emotesEnabled
        print(emotesEnabled and "|cff00ff00BetterEmotes activado.|r" or "|cffff0000BetterEmotes desactivado.|r")
    else
        PrintUsage()
    end
end
