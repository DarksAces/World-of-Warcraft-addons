local frame = CreateFrame("Frame")

-- Función para hacer el emote "love"
local function DoLoveEmote()
    DoEmote("love")  -- Ejecutar el emote "love"
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
                DoLoveEmote()  -- Llamar la función para hacer el emote "love"
            end
        end
    end
end)

-- Registrar el evento de combat log
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
