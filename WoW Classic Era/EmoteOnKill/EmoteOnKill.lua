local frame = CreateFrame("Frame")

-- Lista de emotes en español de las capturas
local emotes = {
    "aplaudir",
    "arrodillarse",
    "bailar",
    "besar",
    "cachas",
    "comer",
    "dormir",
    "grosero",
    "hablar",
    "levantarse",
    "llorar",
    "pollo",
    "reverenciar",
    "risa",
    "rogar",
    "rugir",
    "saludar",
    "saludo",
    "sentarse",
    "señalar",
    "timidez",
    "abrirfuego",
    "agradecer",
    "animar",
    "asentir",
    "atacar",
    "ayudadme",
    "bienvenido",
    "cargar",
    "chao",
    "chiste",
    "enemigos",
    "esperar",
    "felicitar",
    "flirtear",
    "hola",
    "huir",
    "no",
    "rasp",
    "saname",
    "sigueme",
    "sm",
    "tren",
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
