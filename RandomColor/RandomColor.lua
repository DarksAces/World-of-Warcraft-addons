-- RandomColorBars.lua
local coloresAsignados = {}

-- Array grande de colores predefinidos
local coloresDisponibles = {
    {1,0,0}, {0,1,0}, {0,0,1}, {1,1,0}, {1,0,1}, {0,1,1},
    {1,0.5,0}, {0.5,0,1}, {0,0.5,0.5}, {0.5,0.25,0},
    {0.75,0.75,0.75}, {0.25,0.25,0.25}, {0.5,1,0.5}, {0.5,0.5,1},
    {1,0.5,0.5}, {0.5,1,1}, {1,1,0.5}, {1,0.75,0.25}, {0.75,0,0.75}, {0,0.75,0.75},
    {0.8,0.3,0.2}, {0.3,0.8,0.2}, {0.2,0.3,0.8}, {0.9,0.6,0.1}, {0.6,0.1,0.9}, {0.1,0.9,0.6},
    {0.7,0.2,0.5}, {0.2,0.7,0.5}, {0.5,0.2,0.7}, {0.9,0.9,0.9}, {0.4,0.6,0.8},
    {0.6,0.4,0.8}, {0.8,0.6,0.4}, {0.2,0.5,0.2}, {0.5,0.2,0.2}, {0.2,0.2,0.5}, {0.7,0.7,0.2},
    {0.2,0.7,0.7}, {0.7,0.2,0.7}, {0.3,0.6,0.9}, {0.9,0.3,0.6}, {0.6,0.9,0.3}, {0.4,0.8,0.4},
    {0.8,0.4,0.4}, {0.4,0.4,0.8}, {0.9,0.5,0.2}, {0.2,0.9,0.5}, {0.5,0.2,0.9}, {0.3,0.7,0.3},
    {0.7,0.3,0.3}, {0.3,0.3,0.7}, {0.8,0.8,0.3}, {0.3,0.8,0.8}, {0.8,0.3,0.8},
    {0.1,0.1,0.1}, {0.95,0.95,0.95}, {0.5,0,0}, {0,0.5,0}, {0,0,0.5},
    {0.8,0.2,0.1}, {0.1,0.8,0.2}, {0.2,0.1,0.8}, {0.95,0.7,0.3}, {0.3,0.95,0.7},
    {0.7,0.3,0.95}, {0.6,0.8,0.2}, {0.2,0.6,0.8}, {0.8,0.2,0.6}, {0.9,0.4,0.6},
    {0.6,0.9,0.4}, {0.4,0.6,0.9}, {0.7,0.5,0.1}, {0.1,0.7,0.5}, {0.5,0.1,0.7},
    {0.3,0.9,0.1}, {0.1,0.3,0.9}, {0.9,0.1,0.3}, {0.4,0.2,0.9}, {0.9,0.4,0.2},
    {0.2,0.9,0.4}, {0.8,0.1,0.4}, {0.4,0.8,0.1}, {0.1,0.4,0.8}, {0.6,0.3,0.3},
    {0.3,0.6,0.3}, {0.3,0.3,0.6}, {0.9,0.8,0.2}, {0.2,0.9,0.8}, {0.8,0.2,0.9},
    {0.7,0.9,0.5}, {0.5,0.7,0.9}, {0.9,0.5,0.7}, {0.1,0.6,0.5}, {0.5,0.1,0.6},
    {0.6,0.5,0.1}, {0.2,0.4,0.7}, {0.7,0.2,0.4}, {0.4,0.7,0.2}, {0.8,0.5,0.6},
    {0.6,0.8,0.5}, {0.5,0.6,0.8}, {0.9,0.2,0.8}, {0.8,0.9,0.2}, {0.2,0.8,0.9},
    {0.4,0.1,0.4}, {0.4,0.4,0.1}, {0.1,0.4,0.4}, {0.7,0.1,0.1}, {0.1,0.7,0.1},
    {0.1,0.1,0.7}, {0.5,0.8,0.9}, {0.9,0.5,0.8}, {0.8,0.9,0.5}, {0.3,0.5,0.7},
    {0.7,0.3,0.5}, {0.5,0.7,0.3}, {0.6,0.6,0.1}, {0.1,0.6,0.6}, {0.6,0.1,0.6},
    {0.2,0.8,0.3}, {0.3,0.2,0.8}, {0.9,0.9,0.2}, {0.2,0.9,0.9}, {0.9,0.2,0.9},
    {0.7,0.4,0.8}, {0.8,0.7,0.4}, {0.4,0.8,0.7}, {0.5,0.5,0}, {0.5,0,0.5},
    {0.8,0.8,0}, {0,0.8,0.8}, {0.8,0,0.8}, {0.3,0.4,0.5}, {0.5,0.3,0.4}, {0.4,0.5,0.3},
    {0.6,0.7,0.8}, {0.8,0.6,0.7}, {0.7,0.8,0.6}, {0.1,0.2,0.3}, {0.3,0.1,0.2}, {0.2,0.3,0.1},
    {0.4,0.9,0.7}, {0.7,0.4,0.9}, {0.9,0.7,0.4}, {0.2,0.6,0.4}, {0.4,0.2,0.6}, {0.6,0.4,0.2},
    -- Añadidos extra
    {0.05,0.05,0.2}, {0.05,0.2,0.05}, {0.2,0.05,0.05}, {0.15,0.3,0.45}, {0.45,0.15,0.3}, {0.3,0.45,0.15},
    {0.12,0.56,0.78}, {0.78,0.12,0.56}, {0.56,0.78,0.12}, {0.23,0.34,0.45}, {0.45,0.34,0.23}, {0.34,0.23,0.45},
    {0.11,0.22,0.33}, {0.33,0.22,0.11}, {0.22,0.33,0.11}, {0.14,0.26,0.58}, {0.58,0.14,0.26}, {0.26,0.58,0.14},
    {0.16,0.48,0.64}, {0.64,0.16,0.48}, {0.48,0.64,0.16}, {0.09,0.18,0.27}, {0.27,0.18,0.09}, {0.18,0.27,0.09},
    {0.33,0.66,0.99}, {0.99,0.33,0.66}, {0.66,0.99,0.33}, {0.02,0.5,0.75}, {0.75,0.02,0.5}, {0.5,0.75,0.02},
    {0.88,0.44,0.22}, {0.22,0.88,0.44}, {0.44,0.22,0.88}, {0.13,0.57,0.79}, {0.79,0.13,0.57}, {0.57,0.79,0.13},
    {0.21,0.47,0.68}, {0.68,0.21,0.47}, {0.47,0.68,0.21}, {0.29,0.53,0.73}, {0.73,0.29,0.53}, {0.53,0.73,0.29},
    {0.01,0.14,0.27}, {0.27,0.01,0.14}, {0.14,0.27,0.01}, {0.34,0.67,0.89}, {0.89,0.34,0.67}, {0.67,0.89,0.34},
    {0.06,0.36,0.66}, {0.66,0.06,0.36}, {0.36,0.66,0.06}, {0.24,0.58,0.82}, {0.82,0.24,0.58}, {0.58,0.82,0.24}
}

-- Copia profunda
local function deepcopy(tbl)
    local copy = {}
    for k,v in pairs(tbl) do
        copy[k] = (type(v) == "table") and deepcopy(v) or v
    end
    return copy
end

-- Obtener color
function GetCategoryColor(categoria)
    return coloresAsignados[categoria] or {1,1,1}
end

-- Aplicar color
local function AplicarColor(frame, unit)
    if not unit then return end
    local categoria
    local reaction = UnitReaction(unit, "player")
    if UnitIsFriend("player", unit) then
        categoria = "friendly"
    elseif reaction == 4 then
        categoria = "neutral"
    else
        categoria = "hostile"
    end

    local color = GetCategoryColor(categoria)
    if frame and frame.SetStatusBarColor then
        frame:SetStatusBarColor(color[1], color[2], color[3])
    end
end

hooksecurefunc("UnitFrameHealthBar_Update", function(frame, unit)
    AplicarColor(frame, unit)
end)

-- Calcular distancia euclidiana entre dos colores RGB
local function colorDistance(c1, c2)
    local dr = c1[1] - c2[1]
    local dg = c1[2] - c2[2]
    local db = c1[3] - c2[3]
    return math.sqrt(dr*dr + dg*dg + db*db)
end

-- Reasignación de colores (función reutilizable)
local lastMapID = nil
local function getPlayerMapID()
    if C_Map and C_Map.GetBestMapForUnit then
        return C_Map.GetBestMapForUnit("player")
    end
    return nil
end

local function AssignColors()
    local categorias = {"hostile","friendly","neutral"}
    local disponibles = deepcopy(coloresDisponibles)
    local umbral = 0.3 -- Umbral de similitud (ajustable)

    for _, cat in ipairs(categorias) do
        if #disponibles == 0 then break end
        local idx = math.random(#disponibles)
        local elegido = disponibles[idx]
        coloresAsignados[cat] = elegido
        -- Eliminar colores similares (incluido el elegido)
        local nuevosDisponibles = {}
        for i, c in ipairs(disponibles) do
            if colorDistance(elegido, c) > umbral then
                table.insert(nuevosDisponibles, c)
            end
        end
        disponibles = nuevosDisponibles
    end

    print("Colores asignados:")
    for _, cat in ipairs({"hostile","friendly","neutral"}) do
        print(cat..": ", table.concat(coloresAsignados[cat], ", "))
    end
end

-- Asignar colores al cargar y cuando cambie de zona (portal)
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        AssignColors()
        lastMapID = getPlayerMapID()
        return
    end
    -- Reasignar si el mapa cambió (por ejemplo al cruzar un portal)
    local currentMap = getPlayerMapID()
    if currentMap ~= lastMapID then
        AssignColors()
        lastMapID = currentMap
    end
end)
