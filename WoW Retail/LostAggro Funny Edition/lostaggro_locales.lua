-- Localization system for LostAggro addon
local L = {}


local locale = GetLocale()

-- Spanish (Spain)
L["esES"] = {
    aggro_lost = {
        "¡Has perdido el agro de {mob}! Ahora {target} lo tiene, ¡qué envidia!",
        "{mob} ya no te hace caso, ahora está con {target}. ¡Te cambiaron por otro!",
        "El agro de {mob} se fue contigo y llegó a manos de {target}. ¡Menuda traición!",
        "{mob} te dejó plantado por {target}. ¡Qué despecho!",
        "¡Agro perdido! {mob} ahora sigue a {target}. ¿Y tú qué haces?"
    },
    no_aggro_lost = "No has perdido agro esta sesión.",
    aggro_history = "Historial de pérdidas de agro:",
    unknown = "Desconocido"
}

-- Spanish (Mexico)
L["esMX"] = {
    aggro_lost = {
        "¡Perdiste el agro de {mob}! Ahora {target} lo tiene, ¡qué mala onda!",
        "{mob} ya no te pela, ahora sigue a {target}. ¡Te cambiaron!",
        "El agro de {mob} se fue a {target}. ¡Qué traición!",
        "{mob} te cambió por {target}. ¡Eso sí está feo!",
        "¡Adiós agro! {mob} ahora está con {target}. ¿Y tú qué?"
    },
    no_aggro_lost = "No has perdido agro esta sesión.",
    aggro_history = "Historial de pérdidas de agro:",
    unknown = "Desconocido"
}

-- English (US)
L["enUS"] = {
    aggro_lost = {
        "You lost aggro on {mob}! Now {target} has their attention. Ouch!",
        "{mob} stopped caring about you and switched to {target}. How rude!",
        "Aggro on {mob} ran away to {target}. Guess you’re not the favorite anymore!",
        "{mob} ditched you for {target}. What a betrayal!",
        "Aggro lost! {mob} is now stalking {target}. Feeling left out?"
    },
    no_aggro_lost = "You haven't lost aggro this session.",
    aggro_history = "Aggro loss history:",
    unknown = "Unknown"
}

-- French
L["frFR"] = {
    aggro_lost = {
        "Vous avez perdu l'aggro sur {mob}! Maintenant {target} l'a, quelle honte!",
        "{mob} ne vous regarde plus, il est maintenant avec {target}. Quelle trahison!",
        "L'aggro sur {mob} est partie chez {target}. Vous n'êtes plus le préféré!",
        "{mob} vous a quitté pour {target}. C'est dur à avaler!",
        "Aggro perdu! {mob} suit maintenant {target}. Et vous alors?"
    },
    no_aggro_lost = "Vous n'avez pas perdu d'aggro cette session.",
    aggro_history = "Historique des pertes d'aggro:",
    unknown = "Inconnu"
}

-- German
L["deDE"] = {
    aggro_lost = {
        "Du hast die Bedrohung von {mob} verloren! Jetzt hat {target} sie, wie gemein!",
        "{mob} interessiert sich nicht mehr für dich, sondern für {target}. Verrat!",
        "Die Bedrohung von {mob} ging zu {target}. Du bist nicht mehr der Favorit!",
        "{mob} hat dich für {target} verlassen. Wie unhöflich!",
        "Bedrohung verloren! {mob} folgt jetzt {target}. Was nun?"
    },
    no_aggro_lost = "Du hast diese Sitzung keine Bedrohung verloren.",
    aggro_history = "Bedrohungsverlust-Verlauf:",
    unknown = "Unbekannt"
}

-- Italian
L["itIT"] = {
    aggro_lost = {
        "Hai perso l'aggro su {mob}! Ora ce l'ha {target}. Che sfortuna!",
        "{mob} non ti guarda più, ora segue {target}. Che tradimento!",
        "L'aggro su {mob} è andato a {target}. Non sei più il preferito!",
        "{mob} ti ha lasciato per {target}. Che scortesia!",
        "Aggro perso! {mob} ora segue {target}. E tu?"
    },
    no_aggro_lost = "Non hai perso aggro in questa sessione.",
    aggro_history = "Cronologia perdite aggro:",
    unknown = "Sconosciuto"
}

-- Portuguese (Brazil)
L["ptBR"] = {
    aggro_lost = {
        "Você perdeu o aggro de {mob}! Agora {target} tem, que chato!",
        "{mob} não liga mais para você, agora está com {target}. Traição!",
        "O aggro de {mob} foi para {target}. Você não é mais o favorito!",
        "{mob} te trocou por {target}. Que feio!",
        "Aggro perdido! {mob} agora segue {target}. E você?"
    },
    no_aggro_lost = "Você não perdeu aggro nesta sessão.",
    aggro_history = "Histórico de perdas de aggro:",
    unknown = "Desconhecido"
}

-- Russian
L["ruRU"] = {
    aggro_lost = {
        "Вы потеряли угрозу с {mob}! Теперь её имеет {target}. Вот это удар!",
        "{mob} больше не обращает на вас внимания, теперь он с {target}. Предательство!",
        "Угроза на {mob} перешла к {target}. Вы больше не фаворит!",
        "{mob} покинул вас ради {target}. Как грубо!",
        "Потеряна угроза! {mob} теперь следует за {target}. Что теперь?"
    },
    no_aggro_lost = "Вы не теряли угрозу в этой сессии.",
    aggro_history = "История потери угрозы:",
    unknown = "Неизвестно"
}

-- Korean
L["koKR"] = {
    aggro_lost = {
        "{mob}의 어그로를 잃었습니다! 이제 {target}가 가지고 있습니다. 아쉽네요!",
        "{mob}은(는) 더 이상 당신을 신경쓰지 않고 {target}에게 갔습니다. 배신이네요!",
        "{mob}의 어그로가 {target}에게 넘어갔습니다. 당신은 이제 주목받지 못합니다!",
        "{mob}이(가) 당신을 버리고 {target}을(를) 선택했습니다. 무례하네요!",
        "어그로 상실! {mob}이(가) 이제 {target}을(를) 따라다닙니다. 어떻게 할 건가요?"
    },
    no_aggro_lost = "이번 세션에서 어그로를 잃지 않았습니다.",
    aggro_history = "어그로 상실 기록:",
    unknown = "알 수 없음"
}

-- Chinese (Simplified)
L["zhCN"] = {
    aggro_lost = {
        "你失去了{mob}的仇恨！现在{target}拥有了它。真遗憾！",
        "{mob}不再关注你，而是转向了{target}。真是背叛！",
        "{mob}的仇恨转移到了{target}。你不再是首选！",
        "{mob}抛弃了你，选择了{target}。太没礼貌了！",
        "仇恨丢失！{mob}现在追随{target}。你怎么办？"
    },
    no_aggro_lost = "本次会话中你没有失去仇恨。",
    aggro_history = "仇恨丢失历史：",
    unknown = "未知"
}

-- Chinese (Traditional)
L["zhTW"] = {
    aggro_lost = {
        "你失去了{mob}的仇恨！現在{target}擁有了它。真可惜！",
        "{mob}不再理會你，而是轉向了{target}。真是背叛！",
        "{mob}的仇恨轉移到了{target}。你不再是首選！",
        "{mob}拋棄了你，選擇了{target}。太沒禮貌了！",
        "仇恨丟失！{mob}現在追隨{target}。你怎麼辦？"
    },
    no_aggro_lost = "本次對話中你沒有失去仇恨。",
    aggro_history = "仇恨丟失歷史：",
    unknown = "未知"
}
