local PingTracker = CreateFrame("Frame")
local lastPing = 0
local lagSpikeThreshold = 100
PingTrackerDB = PingTrackerDB or {}

-- Crear frame visual (ping box) con plantilla BackdropTemplate
local pingFrame = CreateFrame("Frame", "PingTrackerFrame", UIParent, "BackdropTemplate")
pingFrame:SetSize(120, 30)

-- Posición guardada o por defecto
if PingTrackerDB.pos then
    pingFrame:SetPoint(
        PingTrackerDB.pos.point or "BOTTOMRIGHT",
        UIParent,
        PingTrackerDB.pos.relativePoint or "BOTTOMRIGHT",
        PingTrackerDB.pos.x or -20,
        PingTrackerDB.pos.y or 120
    )
else
    pingFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -20, 120)
end

pingFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
pingFrame:SetBackdropColor(0, 0, 0, 0.7)
pingFrame:Show()

pingFrame:SetMovable(true)
pingFrame:EnableMouse(true)
pingFrame:RegisterForDrag("LeftButton")
pingFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
pingFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    PingTrackerDB.pos = {point = point, relativePoint = relativePoint, x = xOfs, y = yOfs}
end)

-- Texto del ping
local pingText = pingFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
pingText:SetPoint("CENTER")
pingText:SetTextColor(1, 1, 0)
pingText:SetText("Ping: 0 ms")

local function GetZone()
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID then
        local mapInfo = C_Map.GetMapInfo(mapID)
        return mapInfo and mapInfo.name or "Zona desconocida"
    end
    return "Zona desconocida"
end

local function UpdatePing()
    local _, _, latencyHome, latencyWorld = GetNetStats()
    local currentPing = math.max(latencyHome, latencyWorld)
    local zone = GetZone()

    pingText:SetText("Ping: " .. currentPing .. " ms")

    if not PingTrackerDB[zone] then
        PingTrackerDB[zone] = {
            min = currentPing,
            max = currentPing,
            total = currentPing,
            count = 1
        }
    else
        local data = PingTrackerDB[zone]
        data.min = math.min(data.min, currentPing)
        data.max = math.max(data.max, currentPing)
        data.total = data.total + currentPing
        data.count = data.count + 1
    end

    if math.abs(currentPing - lastPing) >= lagSpikeThreshold then
        print(string.format("|cffff0000[PingTracker] Lag spike detectado: %d ms|r", currentPing))
        PlaySound(8959)
    end

    lastPing = currentPing
end

PingTracker:RegisterEvent("PLAYER_LOGIN")
PingTracker:SetScript("OnEvent", function()
    print("|cff00ff00PingTracker cargado correctamente.|r")
    lastPing = math.max(select(3, GetNetStats()))
    UpdatePing()
    C_Timer.NewTicker(5, UpdatePing)
end)

-- Slash command para testear alerta manualmente
SLASH_PINGTRACKER1 = "/pingtest"
SlashCmdList["PINGTRACKER"] = function()
    print("|cffff0000[PingTracker] Test alerta de lag spike activada!|r")
    PlaySound(8959)
end
