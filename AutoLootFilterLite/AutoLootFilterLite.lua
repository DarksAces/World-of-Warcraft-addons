local addonName, addonTable = ...

-- Lista de bloqueados
local blockedItems = {
    --["Rama rota"] = true,
}

-- Filtrar por calidad
local blockQuality = {
    [0] = true,  -- Gris
    [1] = false, -- Blanco
    [2] = false, -- Verde
    [3] = false, -- Azul
    [4] = false, -- Épico
    [5] = false, -- Legendario
}

-- Frame principal
local f = CreateFrame("Frame", "AutoLootFilterFrame")
f:RegisterEvent("LOOT_OPENED")

f:SetScript("OnEvent", function(self, event, ...)
    if event == "LOOT_OPENED" then
        C_Timer.After(0.1, function() -- Pequeño delay para asegurar que el loot esté disponible
            for i = GetNumLootItems(), 1, -1 do
                local icon, name, quantity, currencyID, quality, locked = GetLootSlotInfo(i)
                
                if name and not locked then
                    if blockedItems[name] or blockQuality[quality] then
                        -- Aviso de bloqueo
                        print("|cffFF5555AutoLootFilter:|r Bloqueado " .. name)
                    else
                        -- Loot normal
                        LootSlot(i)
                    end
                end
            end
        end)
    end
end)

-- Comando /alfl para bloquear/desbloquear por nombre
SLASH_ALFL1 = "/alfl"
SlashCmdList["ALFL"] = function(msg)
    local item = msg:match("^%s*(.-)%s*$")
    if item == "" then
        print("|cff55FF55AutoLootFilter|r - Objetos bloqueados:")
        local hasItems = false
        for name in pairs(blockedItems) do
            print(" - " .. name)
            hasItems = true
        end
        if not hasItems then
            print("  (Ningún objeto bloqueado)")
        end
        return
    end

    if blockedItems[item] then
        blockedItems[item] = nil
        print("|cff55FF55AutoLootFilter:|r " .. item .. " desbloqueado.")
    else
        blockedItems[item] = true
        print("|cff55FF55AutoLootFilter:|r " .. item .. " bloqueado.")
    end
end

-- Comando /alflq para bloquear/desbloquear por calidad
SLASH_ALFLQ1 = "/alflq"
SlashCmdList["ALFLQ"] = function(msg)
    local qualityNames = {
        ["gris"] = 0, ["gray"] = 0, ["grey"] = 0,
        ["blanco"] = 1, ["white"] = 1, ["común"] = 1, ["comun"] = 1, ["common"] = 1,
        ["verde"] = 2, ["green"] = 2, ["poco común"] = 2, ["poco comun"] = 2, ["uncommon"] = 2,
        ["azul"] = 3, ["blue"] = 3, ["raro"] = 3, ["rare"] = 3,
        ["épico"] = 4, ["epico"] = 4, ["epic"] = 4, ["morado"] = 4, ["purple"] = 4,
        ["legendario"] = 5, ["legendary"] = 5, ["naranja"] = 5, ["orange"] = 5
    }
    
    local qualityColors = {
        [0] = "|cff9d9d9d", -- Gris
        [1] = "|cffffffff", -- Blanco
        [2] = "|cff1eff00", -- Verde
        [3] = "|cff0070dd", -- Azul
        [4] = "|cffa335ee", -- Épico
        [5] = "|cffff8000"  -- Legendario
    }
    
    local qualityText = {
        [0] = "Gris", [1] = "Blanco", [2] = "Verde", 
        [3] = "Azul", [4] = "Épico", [5] = "Legendario"
    }
    
    local input = msg:match("^%s*(.-)%s*$"):lower()
    
    if input == "" or input == "help" or input == "ayuda" then
        print("|cff55FF55AutoLootFilter|r - Estado de bloqueo por calidad:")
        for i = 0, 5 do
            local status = blockQuality[i] and "|cffFF5555BLOQUEADO|r" or "|cff55FF55PERMITIDO|r"
            print(qualityColors[i] .. qualityText[i] .. "|r: " .. status)
        end
        print("|cffFFFF00Uso:|r /alflq <calidad> (gris, blanco, verde, azul, épico, legendario)")
        return
    end

    local quality = qualityNames[input]
    if quality then
        blockQuality[quality] = not blockQuality[quality]
        local status = blockQuality[quality] and "bloqueada" or "permitida"
        local color = qualityColors[quality]
        print("|cff55FF55AutoLootFilter:|r Calidad " .. color .. qualityText[quality] .. "|r " .. status .. ".")
    else
        print("|cffFF5555AutoLootFilter:|r Calidad no reconocida. Usa: gris, blanco, verde, azul, épico, legendario")
    end
end

-- Mensaje de carga
print("|cff00FF00AutoLootFilter|r cargado.")
print("Comandos: |cffFFFF00/alfl|r [objeto] - |cffFFFF00/alflq|r [calidad]")