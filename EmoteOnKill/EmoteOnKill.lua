local frame = CreateFrame("Frame")

-- Lista de emociones posibles
local emotes = {
    "dance",    -- Bailar
    "laugh",    -- Reir
    "cheer",    -- Aplaudir
    "victory",  -- Victoria
    "wave",     -- Saludar
    "kiss",     -- Beso
    "sorry",    -- Disculparse
    "bow",      -- Reverencia
}

-- Función para elegir un emote aleatorio
local function RandomEmote()
    local emoteIndex = math.random(1, #emotes)  -- Seleccionar un número aleatorio de la lista
    local emote = emotes[emoteIndex]  -- Obtener el emote correspondiente
    DoEmote(emote)  -- Ejecutar el emote
end

-- Función que escucha los eventos del combate
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, eventType, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId = CombatLogGetCurrentEventInfo()

        -- Verificar si se trata de una muerte
        if eventType == "UNIT_DIED" or eventType == "PARTY_KILL" then
            local sourceUnit = UnitGUID("player")  -- El jugador que mató
            -- Si el jugador mató al objetivo (es decir, el jugador causó la muerte)
            if sourceGUID == sourceUnit then
                RandomEmote()  -- Llamar la función para hacer el emote aleatorio
            end
        end
    end
end)

-- Registrar el evento de combat log
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
