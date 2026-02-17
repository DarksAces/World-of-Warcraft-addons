local ADDON_NAME, namespace = ...
namespace.L = {}

local L = {}
setmetatable(L, { __index = function(_, key) return key end })

if GetLocale() == "esES" or GetLocale() == "esMX" then
    L.MAP_BUTTON_LABEL = "Abandonar todas las misiones"
    L.ABANDON_DIALOG_ALL = "¿Seguro que quieres abandonar todas las misiones activas?"
    L.ABANDON_DIALOG_ZONE = "¿Seguro que quieres abandonar todas las misiones en %s?"
    L.ABANDON_QUEST_SUCCESS = "Has abandonado la misión: %s"
    L.SLASH_HELP = "Usa /abandonzone [nombre] o /abandonzone all para abandonar misiones por zona o todas."
    L.ZONE_NOT_FOUND = "Zona '%s' no encontrada."
else
    L.MAP_BUTTON_LABEL = "Abandon all quests"
    L.ABANDON_DIALOG_ALL = "Are you sure you want to abandon all quests?"
    L.ABANDON_DIALOG_ZONE = "Are you sure you want to abandon all quests in %s?"
    L.ABANDON_QUEST_SUCCESS = "Abandoned quest: %s"
    L.SLASH_HELP = "Use /abandonzone [name] or /abandonzone all."
    L.ZONE_NOT_FOUND = "Zone '%s' not found."
end

namespace.L = L
