local frame = CreateFrame("Frame")

-- Lista inicial con 20 emotes variados y divertidos
local emotes = {
    "dance",     -- Bailar
    "laugh",     -- Reír
    "cheer",     -- Aplaudir
    "victory",   -- Victoria
    "wave",      -- Saludar
    "kiss",      -- Beso
    "sorry",     -- Disculparse
    "bow",       -- Reverencia
    "flex",      -- Presumir músculo
    "roar",      -- Rugido
    "fart",      -- Tirarse un pedo (humor)
    "rude",      -- Grosería
    "cry",       -- Llorar
    "cackle",    -- Risa malvada
    "panic",     -- Pánico
    "chicken",   -- Hacer el gallina
    "blink",     -- Parpadear
    "salute",    -- Saludo militar
    "train",     -- Tren (choo choo)
    "clap",      -- Aplauso
}

local function RandomEmote()
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
