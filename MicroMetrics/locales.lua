local addonName, _ = ...
local L = {}

local locale = GetLocale()

if locale == "esES" or locale == "esMX" then
    L["CombatEnded"]   = "MicroMetrics - Combate finalizado:"
    L["Duration"]      = " - Duración total: %.1f s"
    L["NoDamage"]      = " - Tiempo sin hacer daño: %.1f s"
    L["Uptime"]        = " - Uptime: %d%%"
    L["RecordCombat"]  = "Nuevo récord de duración de combate."
    L["RecordUptime"]  = "Nuevo récord de uptime."
    L["Improved"]      = "Mejorado"
    L["Worse"]         = "Empeorado"
    L["DamageDone"]    = "Daño realizado: %d"
elseif locale == "frFR" then
    L["CombatEnded"]   = "MicroMetrics - Combat terminé :"
    L["Duration"]      = " - Durée totale : %.1f s"
    L["NoDamage"]      = " - Temps sans infliger de dégâts : %.1f s"
    L["Uptime"]        = " - Temps actif : %d%%"
    L["RecordCombat"]  = "Nouveau record de durée de combat."
    L["RecordUptime"]  = "Nouveau record de temps actif."
    L["Improved"]      = "Amélioré"
    L["Worse"]         = "Empiré"
    L["DamageDone"]    = "Dégâts infligés : %d"
elseif locale == "deDE" then
    L["CombatEnded"]   = "MicroMetrics - Kampf beendet:"
    L["Duration"]      = " - Gesamtdauer: %.1f s"
    L["NoDamage"]      = " - Zeit ohne Schaden: %.1f s"
    L["Uptime"]        = " - Aktivzeit: %d%%"
    L["RecordCombat"]  = "Neuer Rekord für Kampfdauer."
    L["RecordUptime"]  = "Neuer Rekord für Aktivzeit."
    L["Improved"]      = "Verbessert"
    L["Worse"]         = "Verschlechtert"
    L["DamageDone"]    = "Verursachter Schaden: %d"
elseif locale == "itIT" then
    L["CombatEnded"]   = "MicroMetrics - Combattimento terminato:"
    L["Duration"]      = " - Durata totale: %.1f s"
    L["NoDamage"]      = " - Tempo senza infliggere danni: %.1f s"
    L["Uptime"]        = " - Tempo attivo: %d%%"
    L["RecordCombat"]  = "Nuovo record di durata del combattimento."
    L["RecordUptime"]  = "Nuovo record di uptime."
    L["Improved"]      = "Migliorato"
    L["Worse"]         = "Peggiorato"
    L["DamageDone"]    = "Danno inflitto: %d"
else -- enUS y fallback
    L["CombatEnded"]   = "MicroMetrics - Combat ended:"
    L["Duration"]      = " - Total duration: %.1f s"
    L["NoDamage"]      = " - Time without dealing damage: %.1f s"
    L["Uptime"]        = " - Uptime: %d%%"
    L["RecordCombat"]  = "New longest combat record."
    L["RecordUptime"]  = "New uptime record."
    L["Improved"]      = "Improved"
    L["Worse"]         = "Worsened"
    L["DamageDone"]    = "Damage done: %d"
end

_G.MicroMetrics_Locale = L
