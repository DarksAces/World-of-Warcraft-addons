-- =====================================================
-- Addon: ActionBarTweaks
-- Autor: Daniel (DAM Dev)
-- Descripción: Mover, escalar y ocultar barras con persistencia y reset
-- =====================================================
-- Version testeo Alpha Beta
-- Inicializar SavedVariables
if not ActionBarTweaksDB then
    ActionBarTweaksDB = {
        x = 0,
        y = 120,
        scale = 0.9,
        hidden = false
    }
end

-- Función para mover y escalar barras según valores guardados
local function MoveMainMenuBar(x, y, scale)
    local bar = MainMenuBar
    if not bar then return end

    bar.ignoreFramePositionManager = true
    bar:ClearAllPoints()
    bar:SetPoint("BOTTOM", UIParent, "BOTTOM", x or ActionBarTweaksDB.x, y or ActionBarTweaksDB.y)
    bar:SetScale(scale or ActionBarTweaksDB.scale)

    -- Sub-barras
    if MultiBarBottomLeft then
        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("TOP", bar, "BOTTOM", 0, -5)
        MultiBarBottomLeft:SetScale(scale or ActionBarTweaksDB.scale)
    end

    if MultiBarBottomRight then
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint("TOP", MultiBarBottomLeft, "BOTTOM", 0, -5)
        MultiBarBottomRight:SetScale(scale or ActionBarTweaksDB.scale)
    end
end

-- Aplicar configuración guardada
local function ApplySavedPosition()
    MoveMainMenuBar(ActionBarTweaksDB.x, ActionBarTweaksDB.y, ActionBarTweaksDB.scale)

    if ActionBarTweaksDB.hidden then
        if MainMenuBar then MainMenuBar:Hide() end
        if MultiBarBottomLeft then MultiBarBottomLeft:Hide() end
        if MultiBarBottomRight then MultiBarBottomRight:Hide() end
        if MultiBarRight then MultiBarRight:Hide() end
        if MultiBarLeft then MultiBarLeft:Hide() end
    else
        if MainMenuBar then MainMenuBar:Show() end
        if MultiBarBottomLeft then MultiBarBottomLeft:Show() end
        if MultiBarBottomRight then MultiBarBottomRight:Show() end
        if MultiBarRight then MultiBarRight:Show() end
        if MultiBarLeft then MultiBarLeft:Show() end
    end
end

-- Reset a la posición y escala de Blizzard
local function ResetBarsToBlizzard()
    ActionBarTweaksDB.x = 0
    ActionBarTweaksDB.y = 0
    ActionBarTweaksDB.scale = 1
    ActionBarTweaksDB.hidden = false

    -- Barra principal
    if MainMenuBar then
        MainMenuBar.ignoreFramePositionManager = false
        MainMenuBar:ClearAllPoints()
        MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
        MainMenuBar:SetScale(1)
        MainMenuBar:Show()
    end

    -- Sub-barras inferiores
    if MultiBarBottomLeft then
        MultiBarBottomLeft.ignoreFramePositionManager = false
        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", MainMenuBar, "BOTTOMLEFT", 0, 0)
        MultiBarBottomLeft:SetScale(1)
        MultiBarBottomLeft:Show()
    end
    if MultiBarBottomRight then
        MultiBarBottomRight.ignoreFramePositionManager = false
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint("BOTTOMRIGHT", MainMenuBar, "BOTTOMRIGHT", 0, 0)
        MultiBarBottomRight:SetScale(1)
        MultiBarBottomRight:Show()
    end

    -- Laterales
    if MultiBarRight then
        MultiBarRight.ignoreFramePositionManager = false
        MultiBarRight:ClearAllPoints()
        MultiBarRight:SetPoint("RIGHT", UIParent, "RIGHT", -10, 0)
        MultiBarRight:SetScale(1)
        MultiBarRight:Show()
    end
    if MultiBarLeft then
        MultiBarLeft.ignoreFramePositionManager = false
        MultiBarLeft:ClearAllPoints()
        MultiBarLeft:SetPoint("LEFT", UIParent, "LEFT", 10, 0)
        MultiBarLeft:SetScale(1)
        MultiBarLeft:Show()
    end

    print("|cff00ff00[ActionBarTweaks]|r Barras reseteadas a la posición y escala de Blizzard.")
end


-- Frame para eventos
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    C_Timer.After(0.5, ApplySavedPosition)
end)

-- ===============================================
-- SLASH COMMANDS
-- ===============================================
SLASH_BARTWEAK1 = "/bar"
SlashCmdList["BARTWEAK"] = function(msg)
    local cmd, arg1, arg2 = msg:match("^(%S*)%s*(%S*)%s*(%S*)")

    -- ESCALAR
    if cmd == "scale" then
        local scale = tonumber(arg1)
        if scale then
            ActionBarTweaksDB.scale = scale
            MoveMainMenuBar(nil, nil, scale)
            print("|cff00ff00[ActionBarTweaks]|r Escala ajustada a " .. scale)
        else
            print("|cffffff00Uso: /bar scale 0.9|r")
        end
        return

    -- MOVER
    elseif cmd == "move" then
        local x = tonumber(arg1)
        local y = tonumber(arg2)
        if x and y then
            ActionBarTweaksDB.x = x
            ActionBarTweaksDB.y = y
            MoveMainMenuBar(x, y, nil)
            print(string.format("|cff00ff00[ActionBarTweaks]|r Barra movida a X=%d Y=%d", x, y))
        else
            print("|cffffff00Uso: /bar move <x> <y>|r")
        end
        return

    -- OCULTAR
    elseif cmd == "hide" then
        ActionBarTweaksDB.hidden = true
        if arg1 == "all" then
            if MainMenuBar then MainMenuBar:Hide() end
            if MultiBarBottomLeft then MultiBarBottomLeft:Hide() end
            if MultiBarBottomRight then MultiBarBottomRight:Hide() end
            if MultiBarRight then MultiBarRight:Hide() end
            if MultiBarLeft then MultiBarLeft:Hide() end
            print("|cffff0000[ActionBarTweaks]|r Todas las barras ocultas.")
        else
            if MainMenuBar then MainMenuBar:Hide() end
            print("|cffff0000[ActionBarTweaks]|r Barra principal oculta.")
        end
        return

    -- MOSTRAR
    elseif cmd == "show" then
        ActionBarTweaksDB.hidden = false
        if arg1 == "all" then
            if MainMenuBar then MainMenuBar:Show() end
            if MultiBarBottomLeft then MultiBarBottomLeft:Show() end
            if MultiBarBottomRight then MultiBarBottomRight:Show() end
            if MultiBarRight then MultiBarRight:Show() end
            if MultiBarLeft then MultiBarLeft:Show() end
        else
            if MainMenuBar then MainMenuBar:Show() end
        end
        MoveMainMenuBar(ActionBarTweaksDB.x, ActionBarTweaksDB.y, ActionBarTweaksDB.scale)
        return

    -- RESET
    elseif cmd == "reset" then
        ResetBarsToBlizzard()
        return

    -- AYUDA
    else
        print("|cffffff00Comandos disponibles:|r")
        print("/bar scale <n>     → Escala la barra principal (ej: 0.85)")
        print("/bar move <x> <y>  → Mueve la barra principal (ej: 0 150)")
        print("/bar hide          → Oculta la barra principal")
        print("/bar show          → Muestra la barra principal")
        print("/bar hide all      → Oculta todas las barras de acción")
        print("/bar show all      → Muestra todas las barras de acción")
        print("/bar reset         → Devuelve las barras a la posición y escala originales de Blizzard")
    end
end
