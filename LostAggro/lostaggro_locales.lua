local L = {}

local locale = GetLocale()

L["esES"] = {
    aggro_lost = {
        "Has perdido el agro de {mob}. Ahora lo tiene {target}."
    },
    no_aggro_lost = "No has perdido agro esta sesión.",
    aggro_history = "Historial de pérdidas de agro:",
    unknown = "Desconocido"
}

L["esMX"] = {
    aggro_lost = {
        "Perdiste el agro de {mob}. Ahora lo tiene {target}."
    },
    no_aggro_lost = "No has perdido agro esta sesión.",
    aggro_history = "Historial de pérdidas de agro:",
    unknown = "Desconocido"
}

L["enUS"] = {
    aggro_lost = {
        "You lost aggro on {mob}. Now {target} has it."
    },
    no_aggro_lost = "You haven't lost aggro this session.",
    aggro_history = "Aggro loss history:",
    unknown = "Unknown"
}

L["frFR"] = {
    aggro_lost = {
        "Vous avez perdu l'aggro sur {mob}. Maintenant, c'est {target} qui l'a."
    },
    no_aggro_lost = "Vous n'avez pas perdu d'aggro cette session.",
    aggro_history = "Historique des pertes d'aggro:",
    unknown = "Inconnu"
}

L["deDE"] = {
    aggro_lost = {
        "Du hast die Bedrohung von {mob} verloren. Jetzt hat {target} sie."
    },
    no_aggro_lost = "Du hast diese Sitzung keine Bedrohung verloren.",
    aggro_history = "Bedrohungsverlust-Verlauf:",
    unknown = "Unbekannt"
}

L["itIT"] = {
    aggro_lost = {
        "Hai perso l'aggro su {mob}. Ora ce l'ha {target}."
    },
    no_aggro_lost = "Non hai perso aggro in questa sessione.",
    aggro_history = "Cronologia perdite aggro:",
    unknown = "Sconosciuto"
}

L["ptBR"] = {
    aggro_lost = {
        "Você perdeu o aggro de {mob}. Agora {target} tem."
    },
    no_aggro_lost = "Você não perdeu aggro nesta sessão.",
    aggro_history = "Histórico de perdas de aggro:",
    unknown = "Desconhecido"
}

L["ruRU"] = {
    aggro_lost = {
        "Вы потеряли угрозу с {mob}. Теперь её имеет {target}."
    },
    no_aggro_lost = "Вы не теряли угрозу в этой сессии.",
    aggro_history = "История потери угрозы:",
    unknown = "Неизвестно"
}

L["koKR"] = {
    aggro_lost = {
        "{mob}의 어그로를 잃었습니다. 이제 {target}가 가지고 있습니다."
    },
    no_aggro_lost = "이번 세션에서 어그로를 잃지 않았습니다.",
    aggro_history = "어그로 상실 기록:",
    unknown = "알 수 없음"
}

L["zhCN"] = {
    aggro_lost = {
        "你失去了{mob}的仇恨。现在{target}拥有了它。"
    },
    no_aggro_lost = "本次会话中你没有失去仇恨。",
    aggro_history = "仇恨丢失历史：",
    unknown = "未知"
}

L["zhTW"] = {
    aggro_lost = {
        "你失去了{mob}的仇恨。現在{target}擁有了它。"
    },
    no_aggro_lost = "本次對話中你沒有失去仇恨。",
    aggro_history = "仇恨丟失歷史：",
    unknown = "未知"
}

-- Funciones para obtener frases localizadas
local function GetLocalizedString(key)
    local currentLocale = L[locale] or L["enUS"]
    return currentLocale[key] or L["enUS"][key] or key
end

local function FormatString(str, mob, target)
    str = string.gsub(str, "{mob}", mob or GetLocalizedString("unknown"))
    str = string.gsub(str, "{target}", target or GetLocalizedString("unknown"))
    return str
end

function LostAggro_GetRandomPhrase(mob, newTarget)
    local messages = GetLocalizedString("aggro_lost")
    local message = messages[1] -- Solo una frase
    return FormatString(message, mob, newTarget)
end

function LostAggro_GetLocalizedMessage(key)
    return GetLocalizedString(key)
end
