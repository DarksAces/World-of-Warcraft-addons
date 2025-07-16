
-- Crear frame para mostrar el resultado
local FlipCoinFrame = CreateFrame("Frame", "FlipCoinResultFrame", UIParent)
FlipCoinFrame:SetSize(400, 100)
FlipCoinFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
FlipCoinFrame:Hide()

local FlipCoinText = FlipCoinFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
FlipCoinText:SetPoint("CENTER", FlipCoinFrame, "CENTER")
FlipCoinText:SetTextColor(1, 1, 0)

local function MostrarResultado(texto)
    FlipCoinText:SetText(texto)
    FlipCoinFrame:Show()
    C_Timer.After(3, function() FlipCoinFrame:Hide() end)
end

-- Traducción de los lados
local sidesMap = {
    -- Inglés
    ["heads"] = "HEADS", ["head"] = "HEADS", ["tails"] = "TAILS", ["tail"] = "TAILS",
    -- Español
    ["cara"] = "HEADS", ["cruz"] = "TAILS",
    -- Alemán
    ["kopf"] = "HEADS", ["zahl"] = "TAILS",
    -- Francés
    ["face"] = "HEADS", ["pile"] = "TAILS",
    -- Italiano
    ["testa"] = "HEADS", ["croce"] = "TAILS",
    -- Portugués
    ["cara"] = "HEADS", ["coroa"] = "TAILS",
    -- Ruso
    ["орел"] = "HEADS", ["орёл"] = "HEADS", ["решка"] = "TAILS",
    -- Chino
    ["正面"] = "HEADS", ["反面"] = "TAILS",
    -- Coreano
    ["앞면"] = "HEADS", ["뒷면"] = "TAILS",
    -- Japonés
    ["表"] = "HEADS", ["裏"] = "TAILS",
    -- Holandés
    ["kop"] = "HEADS", ["munt"] = "TAILS",
    -- Sueco
    ["krona"] = "HEADS", ["klave"] = "TAILS",
    -- Polaco
    ["reszka"] = "HEADS", ["orzeł"] = "TAILS",
    -- Turco
    ["yazı"] = "HEADS", ["tura"] = "TAILS",
}

local function normalizeSide(input)
    if not input then return nil end
    local side = string.lower(input)
    side = side:gsub("ё", "е") -- corrección rusa
    return sidesMap[side]
end

-- Resultados por idioma
local resultTexts = {
    en = { heads = "Heads", tails = "Tails", wins = "wins!" },
    es = { heads = "Cara", tails = "Cruz", wins = "gana!" },
    de = { heads = "Kopf", tails = "Zahl", wins = "gewinnt!" },
    fr = { heads = "Face", tails = "Pile", wins = "gagne!" },
    it = { heads = "Testa", tails = "Croce", wins = "vince!" },
    pt = { heads = "Cara", tails = "Coroa", wins = "vence!" },
    ru = { heads = "Орёл", tails = "Решка", wins = "выигрывает!" },
    zh = { heads = "正面", tails = "反面", wins = "获胜!" },
    ko = { heads = "앞면", tails = "뒷면", wins = "승리!" },
    ja = { heads = "表", tails = "裏", wins = "の勝ち!" },
    nl = { heads = "Kop", tails = "Munt", wins = "wint!" },
    sv = { heads = "Krona", tails = "Klave", wins = "vinner!" },
    pl = { heads = "Reszka", tails = "Orzeł", wins = "wygrywa!" },
    tr = { heads = "Yazı", tails = "Tura", wins = "kazanır!" },
}

local function getResultText(lang, key)
    local texts = resultTexts[lang] or resultTexts["en"]
    return texts[key] or key
end

local function FlipCoinHandler(msg, lang)
    local args = {}
    for word in msg:gmatch("%S+") do table.insert(args, word) end

    if #args == 0 then
        local resultado = math.random(2) == 1 and getResultText(lang, "heads") or getResultText(lang, "tails")
        MostrarResultado(resultado)
        PlaySound(8959)
        print("|cffFFD700[FlipCoin]|r " .. resultado)
        return
    end

    local nombre1, lado1, nombre2, lado2, canal = args[1], normalizeSide(args[2]), args[3], normalizeSide(args[4]), args[5]

    if not nombre1 or not lado1 or not nombre2 or not lado2 then
        print("|cffFFD700[FlipCoin]|r Uso: /flip Nombre1 LADO Nombre2 LADO [CANAL]")
        return
    end

    if lado1 == lado2 then
        print("|cffff0000[FlipCoin]|r Ambos eligieron el mismo lado.")
        return
    end

    local cara, cruz = (lado1 == "HEADS") and nombre1 or nombre2, (lado1 == "TAILS") and nombre1 or nombre2
    local resultado = math.random(2) == 1
        and getResultText(lang, "heads") .. ": " .. cara .. " " .. getResultText(lang, "wins")
        or  getResultText(lang, "tails") .. ": " .. cruz .. " " .. getResultText(lang, "wins")

    if canal then
        local c = string.upper(canal)
        if ({ SAY=true, PARTY=true, RAID=true, YELL=true, GUILD=true })[c] then
            SendChatMessage(resultado, c)
        else
            print("|cffff0000[FlipCoin]|r Canal inválido.")
            return
        end
    end

    MostrarResultado(resultado)
    PlaySound(8959)
    print("|cffFFD700[FlipCoin]|r " .. resultado)
end

-- Comandos por idioma correctamente registrados

SLASH_FLIP1 = "/flip"
SlashCmdList["FLIP"] = function(msg) FlipCoinHandler(msg, "en") end

SLASH_TIRAR1 = "/tirar"
SlashCmdList["TIRAR"] = function(msg) FlipCoinHandler(msg, "es") end

SLASH_WURF1 = "/wurf"
SlashCmdList["WURF"] = function(msg) FlipCoinHandler(msg, "de") end

SLASH_PILE1 = "/pile"
SlashCmdList["PILE"] = function(msg) FlipCoinHandler(msg, "fr") end

SLASH_LANCIO1 = "/lancio"
SlashCmdList["LANCIO"] = function(msg) FlipCoinHandler(msg, "it") end

SLASH_JOGAR1 = "/jogar"
SlashCmdList["JOGAR"] = function(msg) FlipCoinHandler(msg, "pt") end

SLASH_MONETA1 = "/монета"
SlashCmdList["MONETA"] = function(msg) FlipCoinHandler(msg, "ru") end

SLASH_THROWCN1 = "/抛硬币"
SlashCmdList["THROWCN"] = function(msg) FlipCoinHandler(msg, "zh") end

SLASH_THROWKO1 = "/던지기"
SlashCmdList["THROWKO"] = function(msg) FlipCoinHandler(msg, "ko") end

SLASH_THROWJP1 = "/コイントス"
SlashCmdList["THROWJP"] = function(msg) FlipCoinHandler(msg, "ja") end

SLASH_MUNT1 = "/munt"
SlashCmdList["MUNT"] = function(msg) FlipCoinHandler(msg, "nl") end

SLASH_KAST1 = "/kast"
SlashCmdList["KAST"] = function(msg) FlipCoinHandler(msg, "sv") end

SLASH_RZUT1 = "/rzut"
SlashCmdList["RZUT"] = function(msg) FlipCoinHandler(msg, "pl") end

SLASH_YAZI1 = "/yazi"
SlashCmdList["YAZI"] = function(msg) FlipCoinHandler(msg, "tr") end
