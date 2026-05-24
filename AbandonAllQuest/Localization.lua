local ADDON_NAME, namespace = ...
namespace.L = {}

local L = {}
setmetatable(L, { __index = function(_, key) return key end })

if GetLocale() == "ruRU" then
    L.MAP_BUTTON_LABEL = "Отменить все задания"
    L.ABANDON_DIALOG_ALL = "Вы уверены, что хотите отменить все активные задания?"
    L.ABANDON_DIALOG_ZONE = "Вы уверены, что хотите отменить все задания в зоне %s?"
    L.ABANDON_QUEST_SUCCESS = "Вы отменили задание: %s"
    L.SLASH_HELP = "Используйте /abandonzone [название] или /abandonzone all, чтобы отменить задания в зоне или все сразу."
    L.ZONE_NOT_FOUND = "Зона '%s' не найдена."
    L.COLLABORATORS_TAB = "Помощники"
    L.COLLABORATORS_TITLE = "--- Помощники и переводчики ---"
    L.COLLABORATORS_DESC = "Особая благодарность всем замечательным людям, которые помогли перевести и улучшить AbandonAllQuest!"
    L.COLLABORATOR_AUTHOR = "DarkAce"
    L.COLLABORATOR_AUTHOR_DESC = "Создатель и разработчик"
    L.COLLABORATOR_RU = "ZamestoTV"
    L.COLLABORATOR_RU_DESC = "Перевод на русский"
    L.COLLABORATOR_JOIN_TITLE = "Хотите помочь?"
    L.COLLABORATOR_JOIN_DESC = "Если вы хотите перевести аддон на другие языки или помочь с кодом, присоединяйтесь к нам на GitHub!"
    L.OPTIONS_TITLE = "Настройки AbandonAllQuest"
    L.SHOW_MAP_BUTTON = "Показывать кнопку «Отменить все задания» на карте"
elseif GetLocale() == "esES" or GetLocale() == "esMX" then
    L.MAP_BUTTON_LABEL = "Abandonar todas las misiones"
    L.ABANDON_DIALOG_ALL = "¿Seguro que quieres abandonar todas las misiones activas?"
    L.ABANDON_DIALOG_ZONE = "¿Seguro que quieres abandonar todas las misiones en %s?"
    L.ABANDON_QUEST_SUCCESS = "Has abandonado la misión: %s"
    L.SLASH_HELP = "Usa /abandonzone [nombre] o /abandonzone all para abandonar misiones por zona o todas."
    L.ZONE_NOT_FOUND = "Zona '%s' no encontrada."
    L.COLLABORATORS_TAB = "Colaboradores"
    L.COLLABORATORS_TITLE = "--- Colaboradores y Traductores ---"
    L["COLLABORATORS_DESC"] = "¡Un agradecimiento especial a todas las personas increíbles que ayudaron a traducir y mejorar AbandonAllQuest!"
    L.COLLABORATOR_AUTHOR = "DarkAce"
    L.COLLABORATOR_AUTHOR_DESC = "Creador y Desarrollador"
    L.COLLABORATOR_RU = "ZamestoTV"
    L.COLLABORATOR_RU_DESC = "Traducción al Ruso"
    L.COLLABORATOR_JOIN_TITLE = "¿Quieres ayudar?"
    L.COLLABORATOR_JOIN_DESC = "Si deseas traducir el addon a otros idiomas o contribuir con el código, ¡únete en GitHub!"
    L.OPTIONS_TITLE = "Opciones de AbandonAllQuest"
    L.SHOW_MAP_BUTTON = "Mostrar botón 'Abandonar todas las misiones' en el mapa"
else
    L.MAP_BUTTON_LABEL = "Abandon all quests"
    L.ABANDON_DIALOG_ALL = "Are you sure you want to abandon all quests?"
    L.ABANDON_DIALOG_ZONE = "Are you sure you want to abandon all quests in %s?"
    L.ABANDON_QUEST_SUCCESS = "Abandoned quest: %s"
    L.SLASH_HELP = "Use /abandonzone [name] or /abandonzone all."
    L.ZONE_NOT_FOUND = "Zone '%s' not found."
    L.COLLABORATORS_TAB = "Collaborators"
    L.COLLABORATORS_TITLE = "--- Collaborators & Translators ---"
    L.COLLABORATORS_DESC = "Special thanks to all the amazing people who helped translate and improve AbandonAllQuest!"
    L.COLLABORATOR_AUTHOR = "DarkAce"
    L.COLLABORATOR_AUTHOR_DESC = "Creator & Lead Developer"
    L.COLLABORATOR_RU = "ZamestoTV"
    L.COLLABORATOR_RU_DESC = "Russian Translation"
    L.COLLABORATOR_JOIN_TITLE = "Want to help?"
    L.COLLABORATOR_JOIN_DESC = "If you want to translate the addon to other languages or contribute code, join us on GitHub!"
    L.OPTIONS_TITLE = "AbandonAllQuest Options"
    L.SHOW_MAP_BUTTON = "Show 'Abandon all quests' button on the map"
end

namespace.L = L
