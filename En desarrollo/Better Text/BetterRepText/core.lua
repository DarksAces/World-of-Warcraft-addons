local addonName = "BetterRepText"
local f = CreateFrame("Frame")
local enabled = true
local debug = false
local lastRepValue = {}

local function ShowRep(amount, faction)
    local msg = "+"..amount.." "..faction
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, 0.2, 0.8, 0.2, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, 0.2, 0.8, 0.2, 53, 3)
    end
end

f:RegisterEvent("COMBAT_TEXT_UPDATE")
f:SetScript("OnEvent", function(_, _, arg1, arg2)
    if not enabled then return end
    
    if arg1 == "FACTION" and arg2 then
        local name, _, _, _, value = GetWatchedFactionInfo()
        
        if debug then
            print("|cff00ff00[DEBUG]|r Facción: " .. tostring(name) .. " | Valor actual: " .. tostring(value) .. " | Anterior: " .. tostring(lastRepValue[name]))
        end
        
        if name and value then
            -- Calcular el incremento
            if lastRepValue[name] then
                local gain = value - lastRepValue[name]
                if gain > 0 then
                    ShowRep(gain, name)
                end
            end
            -- Guardar el valor actual para la próxima vez
            lastRepValue[name] = value
        end
    end
end)

-- Inicializar el valor al cargar
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_FACTION")

local function InitializeRep()
    local name, _, _, _, value = GetWatchedFactionInfo()
    if name and value then
        lastRepValue[name] = value
        if debug then
            print("|cff00ffff[BetterRepText]|r Inicializado: " .. name .. " = " .. value)
        end
    end
end

local originalHandler = f:GetScript("OnEvent")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_FACTION" then
        InitializeRep()
    else
        originalHandler(self, event, ...)
    end
end)

SLASH_REPTEXT1 = "/reptext"
SlashCmdList["REPTEXT"] = function(msg)
    msg = msg:lower()
    if msg == "off" then 
        enabled = false
        print("|cffff8800[BetterRepText]|r Desactivado")
    elseif msg == "on" then 
        enabled = true
        print("|cff88ff00[BetterRepText]|r Activado")
    elseif msg == "debug" then
        debug = not debug
        print("|cff00ffff[BetterRepText]|r Debug: " .. (debug and "ON" or "OFF"))
    elseif msg == "reset" then
        lastRepValue = {}
        InitializeRep()
        print("|cffff00ff[BetterRepText]|r Valores reseteados")
    else 
        print("|cffffff00Uso:|r /reptext on | off | debug | reset") 
    end
end