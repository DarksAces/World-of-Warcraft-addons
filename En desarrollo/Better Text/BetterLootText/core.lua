local addonName = "BetterLootText"
local f = CreateFrame("Frame")
local enabled = true
local debug = false
local filterGold = true
local filterGray = false
local minQuality = 0  -- 0=poor, 1=common, 2=uncommon, 3=rare, 4=epic, 5=legendary

local qualityColors = {
    [0] = {0.62, 0.62, 0.62},  -- Poor (gris)
    [1] = {1, 1, 1},           -- Common (blanco)
    [2] = {0.12, 1, 0},        -- Uncommon (verde)
    [3] = {0, 0.44, 0.87},     -- Rare (azul)
    [4] = {0.64, 0.21, 0.93},  -- Epic (morado)
    [5] = {1, 0.5, 0},         -- Legendary (naranja)
}

local function ShowLoot(msg, r, g, b)
    if IsAddOnLoaded("BetterCombatText") and CombatText_AddMessage then
        CombatText_AddMessage(msg, CombatText_StandardScroll, r or 1, g or 0.82, b or 0, "sticky")
    else
        UIErrorsFrame:AddMessage(msg, r or 1, g or 0.82, b or 0, 53, 3)
    end
end

local function ParseLoot(msg)
    -- Parsear oro/plata/cobre
    local gold = msg:match("(%d+) Gold") or msg:match("(%d+) Oro")
    local silver = msg:match("(%d+) Silver") or msg:match("(%d+) Plata")
    local copper = msg:match("(%d+) Copper") or msg:match("(%d+) Cobre")
    
    if gold or silver or copper then
        if filterGold then return end
        local moneyStr = ""
        if gold then moneyStr = moneyStr .. gold .. "g " end
        if silver then moneyStr = moneyStr .. silver .. "s " end
        if copper then moneyStr = moneyStr .. copper .. "c" end
        ShowLoot(moneyStr:trim(), 1, 0.82, 0)
        return
    end
    
    -- Parsear items con link
    local itemLink = msg:match("|c%x+|Hitem:.-|h%[.-%]|h|r")
    if itemLink then
        local itemString = itemLink:match("item:([%-?%d:]+)")
        local itemID = itemString and tonumber(itemString:match("^(%d+)"))
        
        if itemID then
            local _, _, quality, _, _, _, _, _, _, _, _, _, _, _, _, _ = GetItemInfo(itemID)
            
            if quality and quality >= minQuality then
                if filterGray and quality == 0 then return end
                
                -- Extraer nombre y cantidad del item
                local itemName = itemLink:match("%[(.-)%]")
                local count = msg:match("x(%d+)")
                
                local displayMsg = itemName
                if count and tonumber(count) > 1 then
                    displayMsg = count .. "x " .. displayMsg
                end
                
                local color = qualityColors[quality] or {1, 0.82, 0}
                ShowLoot(displayMsg, color[1], color[2], color[3])
            end
        end
        return
    end
    
    -- Si no es oro ni item conocido, mostrar mensaje original
    if debug then
        print("|cff00ff00[DEBUG LOOT]|r " .. msg)
    end
end

f:RegisterEvent("CHAT_MSG_LOOT")
f:SetScript("OnEvent", function(_, _, msg)
    if not enabled then return end
    
    if debug then
        print("|cff00ff00[DEBUG RAW]|r " .. msg)
    end
    
    ParseLoot(msg)
end)

SLASH_LOOTTEXT1 = "/loottext"
SlashCmdList["LOOTTEXT"] = function(msg)
    msg = msg:lower()
    local args = {strsplit(" ", msg)}
    local cmd = args[1]
    
    if cmd == "off" then 
        enabled = false
        print("|cffff8800[BetterLootText]|r Desactivado")
    elseif cmd == "on" then 
        enabled = true
        print("|cff88ff00[BetterLootText]|r Activado")
    elseif cmd == "debug" then
        debug = not debug
        print("|cff00ffff[BetterLootText]|r Debug: " .. (debug and "ON" or "OFF"))
    elseif cmd == "gold" then
        filterGold = not filterGold
        print("|cffffaa00[BetterLootText]|r Filtrar oro: " .. (filterGold and "ON" or "OFF"))
    elseif cmd == "gray" then
        filterGray = not filterGray
        print("|cff999999[BetterLootText]|r Filtrar grises: " .. (filterGray and "ON" or "OFF"))
    elseif cmd == "quality" then
        local qual = tonumber(args[2])
        if qual and qual >= 0 and qual <= 5 then
            minQuality = qual
            local names = {"Pobre", "Común", "Poco común", "Raro", "Épico", "Legendario"}
            print("|cff00ffff[BetterLootText]|r Calidad mínima: " .. names[qual+1])
        else
            print("|cffff0000Error:|r /loottext quality <0-5>")
        end
    else 
        print("|cffffff00Uso:|r /loottext <comando>")
        print("  |cff88ff00on/off|r - Activar/desactivar")
        print("  |cff88ff00gold|r - Filtrar oro (actualmente: " .. (filterGold and "ON" or "OFF") .. ")")
        print("  |cff88ff00gray|r - Filtrar items grises (actualmente: " .. (filterGray and "ON" or "OFF") .. ")")
        print("  |cff88ff00quality <0-5>|r - Calidad mínima (actual: " .. minQuality .. ")")
        print("  |cff88ff00debug|r - Modo debug")
    end
end