local addonName = "BetterComboText"
local f = CreateFrame("Frame")
local enabled = true
local debug = false

-- Configuración de combos
local comboWindow = 2.5  -- Segundos entre golpes para mantener combo
local minComboHits = 3   -- Mínimo de golpes para considerar combo
local showEveryHit = false  -- Mostrar cada golpe o solo el total

-- Estado del combo
local comboCount = 0
local lastHitTime = 0
local comboTimer = nil
local totalDamage = 0
local critCount = 0

local comboMessages = {
    [3] = "3-HIT COMBO!",
    [5] = "5-HIT COMBO!",
    [7] = "7-HIT COMBO!!",
    [10] = "10-HIT COMBO!!!",
    [15] = "15-HIT COMBO!!!",
    [20] = "MEGA COMBO!!!",
}

local function GetComboColor(count)
    if count >= 20 then return 1, 0, 1 end      -- Magenta
    if count >= 15 then return 1, 0.2, 0 end    -- Naranja brillante
    if count >= 10 then return 1, 0.5, 0 end    -- Naranja
    if count >= 7 then return 1, 0.8, 0 end     -- Amarillo-naranja
    if count >= 5 then return 1, 1, 0 end       -- Amarillo
    return 0.8, 1, 0.2                          -- Verde-amarillo
end

local function ShowCombo(msg, r, g, b)
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, r or 1, g or 0, b or 1, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, r or 1, g or 0, b or 1, 53, 3)
    end
end

local function ResetCombo()
    if comboCount >= minComboHits then
        -- Mostrar combo final
        local r, g, b = GetComboColor(comboCount)
        local msg = comboCount .. "-HIT COMBO!"
        
        if totalDamage > 0 then
            msg = msg .. " (" .. math.floor(totalDamage) .. " dmg"
            if critCount > 0 then
                msg = msg .. ", " .. critCount .. " crit"
            end
            msg = msg .. ")"
        end
        
        ShowCombo(msg, r, g, b)
        
        if debug then
            print("|cff00ff00[DEBUG]|r Combo finalizado: " .. comboCount .. " golpes")
        end
    end
    
    comboCount = 0
    totalDamage = 0
    critCount = 0
    lastHitTime = 0
    
    if comboTimer then
        comboTimer:Cancel()
        comboTimer = nil
    end
end

local function AddHit(damage, isCrit)
    local currentTime = GetTime()
    
    -- Si pasó mucho tiempo, resetear combo
    if currentTime - lastHitTime > comboWindow then
        if comboCount > 0 then
            ResetCombo()
        end
    end
    
    comboCount = comboCount + 1
    totalDamage = totalDamage + (damage or 0)
    if isCrit then critCount = critCount + 1 end
    lastHitTime = currentTime
    
    if debug then
        print("|cff00ff00[DEBUG]|r Hit #" .. comboCount .. " - Daño: " .. (damage or 0) .. (isCrit and " CRIT" or ""))
    end
    
    -- Mostrar mensaje cada golpe si está activado
    if showEveryHit then
        local r, g, b = GetComboColor(comboCount)
        ShowCombo(comboCount .. " hits", r, g, b)
    end
    
    -- Mostrar mensajes especiales en hitos
    if not showEveryHit and comboMessages[comboCount] then
        local r, g, b = GetComboColor(comboCount)
        ShowCombo(comboMessages[comboCount], r, g, b)
    end
    
    -- Reiniciar timer de reset
    if comboTimer then
        comboTimer:Cancel()
    end
    comboTimer = C_Timer.NewTimer(comboWindow, ResetCombo)
end

f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
    if not enabled then return end
    
    local timestamp, subevent, _, sourceGUID, _, _, _, destGUID, _, _, _, arg12, arg13, arg14, arg15 = CombatLogGetCurrentEventInfo()
    
    -- Solo trackear golpes del jugador
    if sourceGUID ~= UnitGUID("player") then return end
    
    -- Detectar diferentes tipos de daño
    local damage = 0
    local isCrit = false
    
    if subevent == "SWING_DAMAGE" then
        damage = arg12
        isCrit = arg15  -- overkill flag puede indicar crit en algunos casos
        AddHit(damage, isCrit)
        
    elseif subevent == "SPELL_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE" then
        damage = arg15
        isCrit = arg18
        AddHit(damage, isCrit)
        
    elseif subevent == "RANGE_DAMAGE" then
        damage = arg15
        isCrit = arg18
        AddHit(damage, isCrit)
    end
end)

-- Resetear combo al salir de combate
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- Manejado arriba
        if not enabled then return end
        
        local timestamp, subevent, _, sourceGUID, _, _, _, destGUID, _, _, _, arg12, arg13, arg14, arg15 = CombatLogGetCurrentEventInfo()
        
        if sourceGUID ~= UnitGUID("player") then return end
        
        local damage = 0
        local isCrit = false
        
        if subevent == "SWING_DAMAGE" then
            damage = arg12
            isCrit = arg15
            AddHit(damage, isCrit)
            
        elseif subevent == "SPELL_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE" then
            damage = arg15
            isCrit = arg18
            AddHit(damage, isCrit)
            
        elseif subevent == "RANGE_DAMAGE" then
            damage = arg15
            isCrit = arg18
            AddHit(damage, isCrit)
        end
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Salir de combate
        if comboCount > 0 then
            C_Timer.After(comboWindow, ResetCombo)
        end
    end
end)

SLASH_COMBOTEXT1 = "/combotext"
SlashCmdList["COMBOTEXT"] = function(msg)
    msg = msg:lower()
    local args = {strsplit(" ", msg)}
    local cmd = args[1]
    
    if cmd == "off" then 
        enabled = false
        print("|cffff8800[BetterComboText]|r Desactivado")
        
    elseif cmd == "on" then 
        enabled = true
        print("|cff88ff00[BetterComboText]|r Activado")
        
    elseif cmd == "debug" then
        debug = not debug
        print("|cff00ffff[BetterComboText]|r Debug: " .. (debug and "ON" or "OFF"))
        
    elseif cmd == "window" then
        local time = tonumber(args[2])
        if time and time > 0 and time <= 10 then
            comboWindow = time
            print("|cff00ffff[BetterComboText]|r Ventana de combo: " .. time .. " segundos")
        else
            print("|cffff0000Error:|r /combotext window <0.5-10>")
        end
        
    elseif cmd == "min" then
        local hits = tonumber(args[2])
        if hits and hits >= 2 and hits <= 20 then
            minComboHits = hits
            print("|cff00ffff[BetterComboText]|r Mínimo de golpes: " .. hits)
        else
            print("|cffff0000Error:|r /combotext min <2-20>")
        end
        
    elseif cmd == "every" then
        showEveryHit = not showEveryHit
        print("|cffff00ff[BetterComboText]|r Mostrar cada golpe: " .. (showEveryHit and "ON" or "OFF"))
        
    elseif cmd == "reset" then
        ResetCombo()
        print("|cffff00ff[BetterComboText]|r Combo reseteado")
        
    else 
        print("|cffffff00Uso:|r /combotext <comando>")
        print("  |cff88ff00on/off|r - Activar/desactivar")
        print("  |cff88ff00window <seg>|r - Tiempo entre golpes (actual: " .. comboWindow .. "s)")
        print("  |cff88ff00min <golpes>|r - Mínimo para combo (actual: " .. minComboHits .. ")")
        print("  |cff88ff00every|r - Mostrar cada golpe (actual: " .. (showEveryHit and "ON" or "OFF") .. ")")
        print("  |cff88ff00reset|r - Resetear combo actual")
        print("  |cff88ff00debug|r - Modo debug")
    end
end