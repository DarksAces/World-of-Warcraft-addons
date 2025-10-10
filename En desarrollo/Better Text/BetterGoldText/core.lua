local addonName = "BetterGoldText"
local f = CreateFrame("Frame")
local enabled = true
local debug = false
local minAmount = 0  -- Mínimo en cobre para mostrar (0 = mostrar todo)
local showCopper = true
local trackTotal = false
local sessionGain = 0
local sessionLoss = 0

local function ShowMoney(amount, isGain)
    local gold = math.floor(amount / 10000)
    local silver = math.floor((amount % 10000) / 100)
    local copper = amount % 100
    
    local msg = ""
    local sign = isGain and "+" or "-"
    
    if gold > 0 then
        msg = sign .. gold .. "g"
        if silver > 0 then
            msg = msg .. " " .. silver .. "s"
        end
        if showCopper and copper > 0 then
            msg = msg .. " " .. copper .. "c"
        end
    elseif silver > 0 then
        msg = sign .. silver .. "s"
        if showCopper and copper > 0 then
            msg = msg .. " " .. copper .. "c"
        end
    elseif showCopper then
        msg = sign .. copper .. "c"
    else
        return  -- No mostrar si solo hay cobre y está desactivado
    end
    
    local r, g, b = isGain and 1 or 1, isGain and 0.8 or 0.3, 0
    
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, r, g, b, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, r, g, b, 53, 3)
    end
    
    -- Trackear total de sesión
    if trackTotal then
        if isGain then
            sessionGain = sessionGain + amount
        else
            sessionLoss = sessionLoss + amount
        end
    end
end

local function ParseMoneyMessage(msg)
    -- Parsear mensajes en inglés y español
    local gold = tonumber((msg:match("(%d+) [Gg]old") or msg:match("(%d+) [Oo]ro") or "0"):gsub(",", ""))
    local silver = tonumber((msg:match("(%d+) [Ss]ilver") or msg:match("(%d+) [Pp]lata") or "0"):gsub(",", ""))
    local copper = tonumber((msg:match("(%d+) [Cc]opper") or msg:match("(%d+) [Cc]obre") or "0"):gsub(",", ""))
    
    local totalCopper = (gold * 10000) + (silver * 100) + copper
    
    if debug then
        print("|cff00ff00[DEBUG]|r Mensaje: " .. msg)
        print("|cff00ff00[DEBUG]|r Parseado: " .. gold .. "g " .. silver .. "s " .. copper .. "c (total: " .. totalCopper .. " cobre)")
    end
    
    return totalCopper
end

f:RegisterEvent("CHAT_MSG_MONEY")
f:SetScript("OnEvent", function(_, _, msg)
    if not enabled then return end
    
    local amount = ParseMoneyMessage(msg)
    
    -- Determinar si es ganancia o pérdida
    local isGain = msg:find("receive") or msg:find("loot") or msg:find("recibes") or msg:find("obtienes")
    if isGain == nil then
        isGain = true  -- Por defecto asumir ganancia
    end
    
    -- Filtrar por cantidad mínima
    if amount >= minAmount then
        ShowMoney(amount, isGain)
    elseif debug then
        print("|cffff0000[DEBUG]|r Cantidad " .. amount .. " menor que mínimo " .. minAmount)
    end
end)

-- También trackear cambios directos en el oro del jugador
local lastMoney = 0
f:RegisterEvent("PLAYER_MONEY")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        lastMoney = GetMoney()
        if debug then
            print("|cff00ffff[BetterGoldText]|r Oro inicial: " .. lastMoney)
        end
    elseif event == "PLAYER_MONEY" then
        local currentMoney = GetMoney()
        local diff = currentMoney - lastMoney
        
        if diff ~= 0 and math.abs(diff) >= minAmount then
            ShowMoney(math.abs(diff), diff > 0)
        end
        
        lastMoney = currentMoney
    elseif event == "CHAT_MSG_MONEY" then
        -- Ya manejado arriba
        local msg = ...
        if not enabled then return end
        
        local amount = ParseMoneyMessage(msg)
        local isGain = msg:find("receive") or msg:find("loot") or msg:find("recibes") or msg:find("obtienes")
        if isGain == nil then isGain = true end
        
        if amount >= minAmount then
            ShowMoney(amount, isGain)
        elseif debug then
            print("|cffff0000[DEBUG]|r Cantidad " .. amount .. " menor que mínimo " .. minAmount)
        end
    end
end)

f:RegisterEvent("PLAYER_ENTERING_WORLD")

SLASH_GOLDTEXT1 = "/goldtext"
SlashCmdList["GOLDTEXT"] = function(msg)
    msg = msg:lower()
    local args = {strsplit(" ", msg)}
    local cmd = args[1]
    
    if cmd == "off" then 
        enabled = false
        print("|cffff8800[BetterGoldText]|r Desactivado")
        
    elseif cmd == "on" then 
        enabled = true
        print("|cff88ff00[BetterGoldText]|r Activado")
        
    elseif cmd == "debug" then
        debug = not debug
        print("|cff00ffff[BetterGoldText]|r Debug: " .. (debug and "ON" or "OFF"))
        
    elseif cmd == "copper" then
        showCopper = not showCopper
        print("|cffcc6600[BetterGoldText]|r Mostrar cobre: " .. (showCopper and "ON" or "OFF"))
        
    elseif cmd == "min" then
        local amount = tonumber(args[2])
        if amount and amount >= 0 then
            minAmount = amount
            local g = math.floor(amount / 10000)
            local s = math.floor((amount % 10000) / 100)
            local c = amount % 100
            print("|cff00ffff[BetterGoldText]|r Cantidad mínima: " .. g .. "g " .. s .. "s " .. c .. "c")
        else
            print("|cffff0000Error:|r /goldtext min <cantidad_en_cobre>")
            print("Ejemplo: /goldtext min 10000 (= 1g)")
        end
        
    elseif cmd == "track" then
        trackTotal = not trackTotal
        if trackTotal then
            sessionGain = 0
            sessionLoss = 0
        end
        print("|cffffff00[BetterGoldText]|r Trackear sesión: " .. (trackTotal and "ON" or "OFF"))
        
    elseif cmd == "session" then
        if trackTotal then
            local gainG = math.floor(sessionGain / 10000)
            local lossG = math.floor(sessionLoss / 10000)
            local netG = math.floor((sessionGain - sessionLoss) / 10000)
            print("|cff00ffff[BetterGoldText]|r Estadísticas de sesión:")
            print("  Ganado: |cff00ff00" .. gainG .. "g|r")
            print("  Gastado: |cffff0000" .. lossG .. "g|r")
            print("  Neto: " .. (netG >= 0 and "|cff00ff00+" or "|cffff0000") .. netG .. "g|r")
        else
            print("|cffff0000[BetterGoldText]|r Tracking de sesión desactivado. Usa /goldtext track")
        end
        
    else 
        print("|cffffff00Uso:|r /goldtext <comando>")
        print("  |cff88ff00on/off|r - Activar/desactivar")
        print("  |cff88ff00copper|r - Mostrar cobre (actualmente: " .. (showCopper and "ON" or "OFF") .. ")")
        print("  |cff88ff00min <cobre>|r - Cantidad mínima para mostrar (actual: " .. minAmount .. ")")
        print("  |cff88ff00track|r - Trackear ganancias/pérdidas de sesión")
        print("  |cff88ff00session|r - Ver estadísticas de sesión")
        print("  |cff88ff00debug|r - Modo debug")
    end
end