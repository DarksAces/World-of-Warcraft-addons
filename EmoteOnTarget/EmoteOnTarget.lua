-- Nombre del addon
local addonName = "EmoteOnTarget"

-- Crear el frame principal
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_LOGIN")

-- Tabla de emotes personalizados
local emotes = {
    FRIENDLY_NPC    = { "/salute", "/bow", "/talk" },       -- NPC amistoso (verde, naranja, amarillo)
    HOSTILE_PLAYER  = { "/rude", "/chicken", "/laugh", "/roar" },  -- Jugador enemigo (PvP)
    FRIENDLY_PLAYER = { "/wave", "/cheer", "/hug", "/clap" },      -- Jugador amistoso
    HOSTILE_NPC     = { "/roar", "/threaten" },           -- NPC hostil (rojo)
}

-- Función para elegir un emote aleatorio de una lista
local function GetRandomEmote(emoteList)
    return emoteList[math.random(1, #emoteList)]
end

-- Función principal para manejar eventos
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        -- Verificar si hay un objetivo seleccionado
        if UnitExists("target") then
            local targetName = UnitName("target")
            local reaction = UnitReaction("player", "target")
            local isPlayer = UnitIsPlayer("target")
            local isFriend = UnitIsFriend("player", "target")
            
            -- Determinar el tipo de objetivo y ejecutar un emote aleatorio
            if isPlayer then
                if isFriend then
                    local emote = GetRandomEmote(emotes.FRIENDLY_PLAYER)
                    DoEmote(emote:sub(2))  -- Elimina la barra "/" para usar DoEmote
                    print("Greeting " .. targetName .. " with " .. emote .. ".")
                else
                    local emote = GetRandomEmote(emotes.HOSTILE_PLAYER)
                    DoEmote(emote:sub(2))  -- Elimina la barra "/" para usar DoEmote
                    print("Challenging " .. targetName .. " with " .. emote .. ".")
                end
            else
                if reaction and reaction <= 4 then -- Hostil o neutral
                    local emote = GetRandomEmote(emotes.HOSTILE_NPC)
                    DoEmote(emote:sub(2))  -- Elimina la barra "/" para usar DoEmote
                    print("Challenging " .. targetName .. " with " .. emote .. ".")
                else -- Amistoso
                    local emote = GetRandomEmote(emotes.FRIENDLY_NPC)
                    DoEmote(emote:sub(2))  -- Elimina la barra "/" para usar DoEmote
                    print("Greeting " .. targetName .. " with " .. emote .. ".")
                end
            end
        else
            print("No target selected.")
        end
    elseif event == "PLAYER_LOGIN" then
        print(addonName .. " loaded. Select a target to see the emotes!")
    end
end)