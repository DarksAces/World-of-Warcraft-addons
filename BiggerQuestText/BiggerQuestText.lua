-- =============================================================================
-- BIGGER QUEST TEXT - ADDON SIMPLE
-- =============================================================================

local ADDON_NAME = "BiggerQuestText"
local frame = CreateFrame("Frame")

-- Base de datos simple
BiggerQuestTextDB = BiggerQuestTextDB or {
    scale = 1.3,  -- Multiplicador de tamaño (1.3 = 30% más grande)
    enabled = true
}

-- Variables locales
local originalFonts = {} -- Para guardar fuentes originales

-- =============================================================================
-- FUNCIONES PRINCIPALES
-- =============================================================================

local function SaveOriginalFonts()
    -- Frames principales de misiones y diálogos
    local questFrames = {
        "QuestTitleFont",
        "QuestFont", 
        "QuestFontNormalSmall",
        "QuestFontHighlight",
        "QuestMapRewardsFont",
        "GameFontNormal",
        "GameFontNormalSmall",
        "GameFontHighlight",
        "GameFontHighlightSmall"
    }
    
    -- Guardar fuentes originales
    for _, fontName in ipairs(questFrames) do
        local fontObject = _G[fontName]
        if fontObject then
            local font, size, flags = fontObject:GetFont()
            if font and size then
                originalFonts[fontName] = {font, size, flags}
            end
        end
    end
    
    -- Guardar fuentes de frames específicos
    local frames = {
        "QuestFrameDetailPanel",
        "QuestFrameProgressPanel", 
        "QuestFrameRewardPanel",
        "QuestMapDetailsScrollFrame",
        "GossipFrame"
    }
    
    for _, frameName in ipairs(frames) do
        local frame = _G[frameName]
        if frame then
            -- Buscar elementos de texto dentro del frame
            local regions = {frame:GetRegions()}
            for i, region in ipairs(regions) do
                if region:GetObjectType() == "FontString" then
                    local font, size, flags = region:GetFont()
                    if font and size then
                        originalFonts[frameName .. i] = {region, font, size, flags}
                    end
                end
            end
        end
    end
end

local function MakeQuestTextBigger()
    local scale = BiggerQuestTextDB.scale
    
    -- Agrandar fuentes principales
    local questFonts = {
        "QuestTitleFont",
        "QuestFont",
        "QuestFontNormalSmall", 
        "QuestFontHighlight",
        "QuestMapRewardsFont",
        "GameFontNormal",
        "GameFontNormalSmall",
        "GameFontHighlight",
        "GameFontHighlightSmall"
    }
    
    for _, fontName in ipairs(questFonts) do
        local fontObject = _G[fontName]
        if fontObject and originalFonts[fontName] then
            local font, size, flags = unpack(originalFonts[fontName])
            fontObject:SetFont(font, size * scale, flags)
        end
    end
    
    -- Agrandar texto en frames específicos
    local frames = {
        "QuestFrameDetailPanel",
        "QuestFrameProgressPanel",
        "QuestFrameRewardPanel", 
        "QuestMapDetailsScrollFrame",
        "GossipFrame"
    }
    
    for _, frameName in ipairs(frames) do
        local frame = _G[frameName]
        if frame then
            local regions = {frame:GetRegions()}
            for i, region in ipairs(regions) do
                if region:GetObjectType() == "FontString" then
                    local savedFont = originalFonts[frameName .. i]
                    if savedFont then
                        local fontString, font, size, flags = unpack(savedFont)
                        fontString:SetFont(font, size * scale, flags)
                    end
                end
            end
        end
    end
    
    -- Frames específicos adicionales
    local specificFrames = {
        "QuestInfoDescriptionText",
        "QuestInfoObjectivesText", 
        "QuestInfoRewardText",
        "QuestInfoTimerText",
        "QuestInfoSpecialObjectivesText"
    }
    
    for _, frameName in ipairs(specificFrames) do
        local frame = _G[frameName]
        if frame and frame.GetFont then
            local font, size, flags = frame:GetFont()
            if font and size and originalFonts[frameName] then
                frame:SetFont(font, originalFonts[frameName][2] * scale, flags)
            elseif font and size and not originalFonts[frameName] then
                originalFonts[frameName] = {font, size, flags}
                frame:SetFont(font, size * scale, flags)
            end
        end
    end
    
    print("|cff00ff00BiggerQuestText:|r Texto de misiones |cff00ff00AGRANDADO|r (" .. math.floor(scale * 100) .. "%)")
end

local function RestoreOriginalFonts()
    -- Restaurar fuentes principales
    for fontName, fontData in pairs(originalFonts) do
        local fontObject = _G[fontName]
        if fontObject and fontObject.SetFont then
            local font, size, flags = unpack(fontData)
            fontObject:SetFont(font, size, flags)
        elseif type(fontData[1]) == "userdata" then
            -- Es un FontString específico
            local fontString, font, size, flags = unpack(fontData)
            if fontString and fontString.SetFont then
                fontString:SetFont(font, size, flags)
            end
        end
    end
    
    print("|cffff9900BiggerQuestText:|r Texto de misiones |cffff9900NORMAL|r")
end

local function ToggleBiggerText()
    BiggerQuestTextDB.enabled = not BiggerQuestTextDB.enabled
    
    if BiggerQuestTextDB.enabled then
        MakeQuestTextBigger()
    else
        RestoreOriginalFonts()
    end
end

local function SetTextSize(newScale)
    if newScale < 0.8 then newScale = 0.8 end
    if newScale > 2.5 then newScale = 2.5 end
    
    BiggerQuestTextDB.scale = newScale
    
    if BiggerQuestTextDB.enabled then
        MakeQuestTextBigger()
    end
end

local function RefreshFonts()
    SaveOriginalFonts()
    if BiggerQuestTextDB.enabled then
        MakeQuestTextBigger()
    end
end

-- =============================================================================
-- EVENTOS
-- =============================================================================

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("QUEST_PROGRESS") 
frame:RegisterEvent("QUEST_COMPLETE")
frame:RegisterEvent("GOSSIP_SHOW")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and select(1, ...) == ADDON_NAME then
        print("|cff00ff00BiggerQuestText|r cargado. Usa |cffffcc00/questtext|r para alternar.")
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Esperar un poco para que todo esté cargado
        C_Timer.After(3, function()
            SaveOriginalFonts()
            if BiggerQuestTextDB.enabled then
                MakeQuestTextBigger()
            end
        end)
        
    elseif event == "QUEST_DETAIL" or event == "QUEST_PROGRESS" or 
           event == "QUEST_COMPLETE" or event == "GOSSIP_SHOW" then
        -- Refrescar fuentes cuando se abren diálogos
        if BiggerQuestTextDB.enabled then
            C_Timer.After(0.1, MakeQuestTextBigger)
        end
    end
end)

-- =============================================================================
-- COMANDOS DE SLASH
-- =============================================================================

SLASH_BIGGERQUESTTEXT1 = "/questtext"
SLASH_BIGGERQUESTTEXT2 = "/biggerquest"

SlashCmdList["BIGGERQUESTTEXT"] = function(msg)
    local cmd = string.lower(msg or "")
    
    if cmd == "toggle" or cmd == "" then
        ToggleBiggerText()
        
    elseif cmd:match("^%d") then
        local scale = tonumber(cmd)
        if scale then
            SetTextSize(scale)
            print("BiggerQuestText: Tamaño ajustado a " .. math.floor(scale * 100) .. "%")
        else
            print("BiggerQuestText: Usar número válido (0.8 - 2.5)")
        end
        
    elseif cmd == "small" then
        SetTextSize(1.1)  -- 110% del tamaño original
        
    elseif cmd == "normal" then
        SetTextSize(1.0)  -- Tamaño original
        
    elseif cmd == "big" then
        SetTextSize(1.3)  -- 130% más grande
        
    elseif cmd == "huge" then
        SetTextSize(1.6)  -- 160% más grande
        
    elseif cmd == "giant" then
        SetTextSize(2.0)  -- 200% más grande
        
    elseif cmd == "refresh" then
        RefreshFonts()
        print("BiggerQuestText: Fuentes refrescadas")
        
    elseif cmd == "reset" then
        BiggerQuestTextDB.scale = 1.3
        BiggerQuestTextDB.enabled = true
        RefreshFonts()
        print("BiggerQuestText: Configuración reseteada")
        
    elseif cmd == "status" then
        print("|cffff9900=== BiggerQuestText Status ===|r")
        print("Estado: " .. (BiggerQuestTextDB.enabled and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
        print("Tamaño actual: " .. math.floor(BiggerQuestTextDB.scale * 100) .. "%")
        print("Fuentes guardadas: " .. (originalFonts and #originalFonts or 0))
        
    elseif cmd == "help" then
        print("|cff00ff00BiggerQuestText Commands:|r")
        print("  |cffffcc00/questtext|r - Alternar on/off")
        print("  |cffffcc00/questtext 1.3|r - Tamaño específico (1.3 = 130%)")
        print("  |cffffcc00/questtext small|r - Texto un poco más grande (110%)")
        print("  |cffffcc00/questtext normal|r - Texto normal (100%)")
        print("  |cffffcc00/questtext big|r - Texto grande (130%)")
        print("  |cffffcc00/questtext huge|r - Texto muy grande (160%)")
        print("  |cffffcc00/questtext giant|r - Texto gigante (200%)")
        print("  |cffffcc00/questtext refresh|r - Refrescar fuentes")
        print("  |cffffcc00/questtext status|r - Ver estado actual")
        print("  |cffffcc00/questtext reset|r - Resetear configuración")
        
    else
        print("BiggerQuestText: Comando no reconocido. Usa |cffffcc00/questtext help|r para ayuda.")
    end
end

-- =============================================================================
-- MENSAJE DE CARGA
-- =============================================================================

print("|cff00ff00BiggerQuestText|r loaded! Use |cffffcc00/questtext|r to toggle bigger quest text.")