local addonName = "BetterHonorText"
local f = CreateFrame("Frame")
local enabled = true
local debug = false
local showKills = true
local showHonor = true
local showConquest = true

local lastHonor = 0
local lastConquest = 0

local function ShowMessage(msg, r, g, b)
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, r, g, b, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, r, g, b, 53, 3)
    end
end

local function CheckHonorGain()
    local currentHonor = UnitHonor("player") or 0
    local currentConquest = C_CurrencyInfo.GetCurrencyInfo(1602) -- Conquest currency ID
    local conquestAmount = currentConquest and currentConquest.quantity or 0
    
    if debug then
        print("|cff00ff00[DEBUG]|r Honor: " .. currentHonor .. " (anterior: " .. lastHonor .. ")")
        print("|cff00ff00[DEBUG]|r Conquest: " .. conquestAmount .. " (anterior: " .. lastConquest .. ")")
    end
    
    -- Comprobar ganancia de Honor
    if showHonor and lastHonor > 0 and currentHonor > lastHonor then
        local gain = currentHonor - lastHonor
        ShowMessage("+" .. gain .. " Honor", 1, 0.2, 0.2)
    end
    
    -- Comprobar ganancia de Conquista
    if showConquest and lastConquest > 0 and conquestAmount > lastConquest then
        local gain = conquestAmount - lastConquest
        ShowMessage("+" .. gain .. " Conquest", 1, 0.5, 0)
    end
    
    lastHonor = currentHonor
    lastConquest = conquestAmount
end

local function InitializeValues()
    lastHonor = UnitHonor("player") or 0
    local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(1602)
    lastConquest = conquestInfo and conquestInfo.quantity or 0
    
    if debug then
        print("|cff00ffff[BetterHonorText]|r Inicializado - Honor: " .. lastHonor .. " | Conquest: " .. lastConquest)
    end
end

-- Eventos para PvP
f:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
f:RegisterEvent("HONOR_XP_UPDATE")
f:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(self, event, ...)
    if not enabled then return end
    
    if event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, InitializeValues)
        
    elseif event == "PLAYER_PVP_KILLS_CHANGED" then
        if showKills then
            local kills = GetNumKills() or 0
            ShowMessage("PvP Kill! (" .. kills .. ")", 1, 0, 0)
        end
        -- Esperar un momento para que se actualice el honor
        C_Timer.After(0.5, CheckHonorGain)
        
    elseif event == "HONOR_XP_UPDATE" then
        CheckHonorGain()
        
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        local currencyType = ...
        -- 1602 es el ID de Conquest
        if currencyType == 1602 then
            C_Timer.After(0.1, CheckHonorGain)
        end
    end
    
    if debug then
        print("|cff00ff00[DEBUG EVENT]|r " .. event)
    end
end)

SLASH_HONORTEXT1 = "/honortext"
SlashCmdList["HONORTEXT"] = function(msg)
    msg = msg:lower()
    local args = {strsplit(" ", msg)}
    local cmd = args[1]
    
    if cmd == "off" then 
        enabled = false
        print("|cffff8800[BetterHonorText]|r Desactivado")
        
    elseif cmd == "on" then 
        enabled = true
        print("|cff88ff00[BetterHonorText]|r Activado")
        
    elseif cmd == "debug" then
        debug = not debug
        print("|cff00ffff[BetterHonorText]|r Debug: " .. (debug and "ON" or "OFF"))
        
    elseif cmd == "kills" then
        showKills = not showKills
        print("|cffff0000[BetterHonorText]|r Mostrar kills: " .. (showKills and "ON" or "OFF"))
        
    elseif cmd == "honor" then
        showHonor = not showHonor
        print("|cffff3333[BetterHonorText]|r Mostrar honor: " .. (showHonor and "ON" or "OFF"))
        
    elseif cmd == "conquest" then
        showConquest = not showConquest
        print("|cffff8800[BetterHonorText]|r Mostrar conquest: " .. (showConquest and "ON" or "OFF"))
        
    elseif cmd == "reset" then
        InitializeValues()
        print("|cffff00ff[BetterHonorText]|r Valores reseteados")
        
    elseif cmd == "status" then
        print("|cff00ffff[BetterHonorText]|r Estado actual:")
        print("  Honor: " .. (UnitHonor("player") or 0))
        local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(1602)
        print("  Conquest: " .. (conquestInfo and conquestInfo.quantity or 0))
        print("  Kills totales: " .. (GetNumKills() or 0))
        
    else 
        print("|cffffff00Uso:|r /honortext <comando>")
        print("  |cff88ff00on/off|r - Activar/desactivar")
        print("  |cff88ff00kills|r - Toggle mostrar kills (actualmente: " .. (showKills and "ON" or "OFF") .. ")")
        print("  |cff88ff00honor|r - Toggle mostrar honor (actualmente: " .. (showHonor and "ON" or "OFF") .. ")")
        print("  |cff88ff00conquest|r - Toggle mostrar conquest (actualmente: " .. (showConquest and "ON" or "OFF") .. ")")
        print("  |cff88ff00status|r - Ver estado actual")
        print("  |cff88ff00reset|r - Resetear valores")
        print("  |cff88ff00debug|r - Modo debug")
    end
end