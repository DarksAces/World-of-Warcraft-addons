local addonName, NS = ...

-- Localization
local L = (GetLocale() == "esES" or GetLocale() == "esMX") and {
    ITEM_NAME = "Nombre del ítem",
    PRICE_GOLD = "Precio (Oro)",
    UPDATE = "ACTUALIZAR",
    SCAN = "ESCANEAR",
    SINGLE = "INDIVIDUAL",
    DASHBOARD = "TABLERO",
    GALLERY = "GALERÍA",
    GRID = "CUADRÍCULA",
    LAYOUT = "DISEÑO",
    SIGNAL = "Señal",
    STAGNANT = "Estancado",
    VOID_ASC = "Ascendencia del Vacío",
    VOID_CRASH = "Caída del Vacío",
    WATCHLIST_EMPTY = "Lista vacía",
    ADD_ITEMS = "Añade ítems con el botón +",
    MARKET_DATA = "Datos de mercado",
    MAX = "Máximo",
    OPEN = "Inicio",
    CLOSE = "Cierre",
    MIN = "Mínimo",
    LOADED = "v5.0 (Custom) CARGADO. Escribe /ac para abrir.",
    MATCH_FOUND = "COINCIDENCIA: %s @ %s",
    SCAN_COMPLETE = "Escaneo completo. No se encontró coincidencia exacta.",
    SCANNING = "Escaneando coincidencia EXACTA: [%s]...",
    AH_NOT_OPEN = "Subasta no abierta. Usando entrada manual.",
    ITEM_ADDED = "Ítem añadido a la lista: ",
} or {
    ITEM_NAME = "Item Name",
    PRICE_GOLD = "Price (Gold)",
    UPDATE = "UPDATE",
    SCAN = "SCAN",
    SINGLE = "SINGLE",
    DASHBOARD = "DASHBOARD",
    GALLERY = "GALLERY",
    GRID = "GRID",
    LAYOUT = "LAYOUT",
    SIGNAL = "Signal",
    STAGNANT = "Stagnant",
    VOID_ASC = "Void Ascendance",
    VOID_CRASH = "Void Crash",
    WATCHLIST_EMPTY = "Watchlist is Empty",
    ADD_ITEMS = "Add items using the + button.",
    MARKET_DATA = "Market Data",
    MAX = "High",
    OPEN = "Open",
    CLOSE = "Close",
    MIN = "Low",
    LOADED = "v5.0 (Custom) LOADED. Type /ac to open.",
    MATCH_FOUND = "MATCH FOUND: %s @ %s",
    SCAN_COMPLETE = "Scan complete. Exact match not found.",
    SCANNING = "Scanning for EXACT match: [%s]...",
    AH_NOT_OPEN = "AH Not Open. Using Manual Inputs.",
    ITEM_ADDED = "Item added to Watchlist: ",
}

-- Forward declarations for scope
local MainChart, DrawSlice, ZoomButtons = {}, nil, {}

-- Steady Storage Initialization
local function InitDB()
    if not AzerothCandlesticksDB then
        AzerothCandlesticksDB = {
            watchlist = {
                { name = "Copper Ore", lastPrice = "0.50" },
                { name = "Tin Ore", lastPrice = "1.20" },
            },
            config = {
                viewMode = "SINGLE",
                dashboardIndex = 1,
                dashboardType = "GALLERY", -- or "GRID"
                currentZoom = 168, -- 7D = 168, 24H = 24, 1H = 6
            }
        }
    else
        -- Patching existing DB if needed
        if not AzerothCandlesticksDB.config then AzerothCandlesticksDB.config = {} end
        if not AzerothCandlesticksDB.config.dashboardIndex then AzerothCandlesticksDB.config.dashboardIndex = 1 end
        if not AzerothCandlesticksDB.config.dashboardType then AzerothCandlesticksDB.config.dashboardType = "GALLERY" end
        if not AzerothCandlesticksDB.config.currentZoom then AzerothCandlesticksDB.config.currentZoom = 168 end
    end
end

-- Configuration: Midnight / TWW Theme
local CONFIG = {
    colors = {
        bg = {0.03, 0.02, 0.08, 0.95}, -- Deep Void Blue/Black
        border = {0.4, 0.2, 0.7, 1.0}, -- Void Purple
        grid = {0.15, 0.1, 0.25, 0.4},
        bullish = {0.0, 0.9, 0.8, 1.0}, -- Cyan/Void Light (Growth)
        bearish = {0.9, 0.1, 0.5, 1.0}, -- Magenta/Shadow (Decline)
        text = {0.85, 0.85, 1.0, 1.0},
        highlight = {0.4, 0.2, 0.8, 0.2},
    },
    candleWidth = 8,
    candleSpacing = 4,
}

-- Mock Data Generator (Unchanged)
local function GenerateData(count)
    local data = {}
    local currentPrice = 1000 -- 100g
    for i = 1, count do
        local open = currentPrice
        local volatility = math.random() * 50 - 25
        local close = open + volatility
        local high = math.max(open, close) + math.random() * 10
        local low = math.min(open, close) - math.random() * 10
        
        table.insert(data, {
            open = open,
            close = close,
            high = high,
            low = low,
            timestamp = i
        })
        currentPrice = close
    end
    return data
end

-- Main Frame with Midnight Aesthetic
local MainFrame = CreateFrame("Frame", "AzerothCandlesticksFrame", UIParent, "BackdropTemplate")
MainFrame:SetSize(800, 500)
MainFrame:SetPoint("CENTER")
MainFrame:SetMovable(true)
MainFrame:EnableMouse(true)
MainFrame:RegisterForDrag("LeftButton")
MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing)

-- Custom Backdrop for Void Look
MainFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false, tileSize = 0, edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
MainFrame:SetBackdropColor(unpack(CONFIG.colors.bg))
MainFrame:SetBackdropBorderColor(unpack(CONFIG.colors.border))

MainFrame.title = MainFrame:CreateFontString(nil, "OVERLAY")
MainFrame.title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
MainFrame.title:SetPoint("TOPLEFT", 15, -10)
MainFrame.title:SetTextColor(0.8, 0.6, 1.0) -- Pale Purple Title
MainFrame.title:SetText("Azeroth Candlesticks: Midnight")

-- Close Button (Custom Style)
local CloseBtn = CreateFrame("Button", nil, MainFrame, "UIPanelCloseButton")
CloseBtn:SetPoint("TOPRIGHT", -5, -5)

-- Pattern Detection Mock (Simple Text)
local signalFrame = CreateFrame("Frame", nil, MainFrame)
signalFrame:SetSize(200, 30)
signalFrame:SetPoint("TOP", 0, -80) -- Initial position (Corrected)
local signalText = signalFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
signalText:SetPoint("CENTER")
signalText:SetTextColor(0.9, 0.9, 1.0) -- Pale Blue/White text
signalText:SetText("Signal: Neutral")

-- (Old Canvas removed, using MainChart instead)

-- Candle Frame Pool (Interactive)
local globalCandlePool = {}

local function FormatPriceTooltip(val)
    return string.format("|cffffd100%.2f g|r", val / 100)
end

-- Modular Chart Component Factory
local function CreateChartView(parent, width, height)
    local view = CreateFrame("Frame", nil, parent)
    view:SetSize(width, height)
    
    view.canvas = CreateFrame("Frame", nil, view)
    view.canvas:SetAllPoints()
    view.canvas.content = view.canvas:CreateTexture(nil, "BACKGROUND")
    view.canvas.content:SetAllPoints()
    view.canvas.content:SetColorTexture(unpack(CONFIG.colors.grid))
    view.canvas:SetClipsChildren(true)

    view.activeCandles = {}
    view.data = {}

    function view:AcquireCandle()
        local f = table.remove(globalCandlePool)
        if not f then
            f = CreateFrame("Button", nil, self.canvas)
            f:SetFrameLevel(10)
            f.wick = f:CreateTexture(nil, "ARTWORK")
            f.body = f:CreateTexture(nil, "ARTWORK")
            
            f:SetScript("OnEnter", function(self)
                local d = self.data
                if not d then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L.MARKET_DATA, 0.4, 0.2, 0.8)
                GameTooltip:AddLine(L.MAX .. ": |cffffffff"..FormatPriceTooltip(d.high).."|r")
                GameTooltip:AddLine(L.OPEN .. ": |cffffffff"..FormatPriceTooltip(d.open).."|r")
                GameTooltip:AddLine(L.CLOSE .. ": |cffffffff"..FormatPriceTooltip(d.close).."|r")
                GameTooltip:AddLine(L.MIN .. ": |cffffffff"..FormatPriceTooltip(d.low).."|r")
                GameTooltip:Show()
                self.body:SetAlpha(0.6)
            end)
            f:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
                self.body:SetAlpha(1.0)
            end)
        end
        f:SetParent(self.canvas)
        table.insert(self.activeCandles, f)
        f:Show()
        return f
    end

    function view:ReleaseAllCandles()
        for _, f in ipairs(self.activeCandles) do
            f:Hide()
            table.insert(globalCandlePool, f)
        end
        self.activeCandles = {}
        if self.trendLines then
            for _, l in ipairs(self.trendLines) do l:Hide() end
        end
    end
    
    view.icon = view:CreateTexture(nil, "OVERLAY")
    view.icon:SetSize(24, 24)
    view.icon:SetPoint("TOPLEFT", 5, -5)
    view.icon:SetAlpha(0.7)

    function view:Draw(data)
        self:ReleaseAllCandles()
        self.data = data
        local w = self.canvas:GetWidth()
        local h = self.canvas:GetHeight()
        local numCandles = #data
        if numCandles == 0 then return end

        local minPrice, maxPrice = data[1].low, data[1].high
        for _, candle in ipairs(data) do
            if candle.low < minPrice then minPrice = candle.low end
            if candle.high > maxPrice then maxPrice = candle.high end
        end
        local priceRange = maxPrice - minPrice
        if priceRange == 0 then priceRange = 1 end

        local slotWidth = w / numCandles
        local spacing = (slotWidth > 5) and 2 or (slotWidth > 3 and 1 or 0)
        local visualWidth = math.max(1, math.min(150, slotWidth - spacing))

        for i = 1, numCandles do
            local d = data[i]
            local xPos = (i - 1) * slotWidth
            local yHigh = ((d.high - minPrice) / priceRange) * h
            local yLow = ((d.low - minPrice) / priceRange) * h
            local yOpen = ((d.open - minPrice) / priceRange) * h
            local yClose = ((d.close - minPrice) / priceRange) * h
            local color = (d.close >= d.open) and CONFIG.colors.bullish or CONFIG.colors.bearish
            
            local f = self:AcquireCandle()
            f.data = d 
            f:SetPoint("BOTTOMLEFT", self.canvas, "BOTTOMLEFT", xPos, 0)
            f:SetSize(slotWidth, h) 

            f.wick:SetColorTexture(unpack(color))
            f.wick:ClearAllPoints()
            f.wick:SetPoint("BOTTOM", f, "BOTTOM", 0, yLow)
            f.wick:SetSize(math.max(1, visualWidth * 0.1), math.max(1, yHigh - yLow)) 

            local bodyBottom = math.min(yOpen, yClose)
            f.body:SetColorTexture(unpack(color))
            f.body:ClearAllPoints()
            f.body:SetPoint("BOTTOM", f, "BOTTOM", 0, bodyBottom)
            f.body:SetSize(visualWidth, math.max(1, math.max(yOpen, yClose) - bodyBottom))
        end
        
        -- TREND LINE (5-period SMA)
        if numCandles > 5 then
            self.trendLines = self.trendLines or {}
            local prevX, prevY = nil, nil
            for i = 5, numCandles do
                local sum = 0
                for j = i-4, i do sum = sum + data[j].close end
                local avg = sum / 5
                
                local currentX = (i - 0.5) * slotWidth
                local currentY = ((avg - minPrice) / priceRange) * h
                
                if prevX then
                    local line = self.trendLines[i]
                    if not line then
                        line = self:CreateLine()
                        line:SetThickness(1.5)
                        line:SetColorTexture(0.7, 0.4, 1.0, 0.6) -- Soft Purple
                        self.trendLines[i] = line
                    end
                    line:SetStartPoint("BOTTOMLEFT", self.canvas, prevX, prevY)
                    line:SetEndPoint("BOTTOMLEFT", self.canvas, currentX, currentY)
                    line:Show()
                end
                prevX, prevY = currentX, currentY
            end
        end
    end
    
    function view:SetIconByItem(itemName)
        if not itemName or itemName == "" then self.icon:Hide() return end
        
        -- Try to get icon immediately
        local icon = GetItemIcon(itemName)
        if icon then
            self.icon:SetTexture(icon)
            self.icon:Show()
        else
            -- If not in cache, request info and hide/placeholder
            self.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            self.icon:Show()
            
            -- Request item info to force cache
            local item = Item:CreateFromItemName(itemName)
            if not item:IsItemEmpty() then
                item:ContinueOnItemLoad(function()
                    local newIcon = GetItemIcon(itemName)
                    if newIcon then
                        self.icon:SetTexture(newIcon)
                    end
                end)
            end
        end
    end

    return view
end

-- Initial Data
-- Top Bar Container (Inputs)
local TopBar = CreateFrame("Frame", nil, MainFrame)
TopBar:SetPoint("TOPLEFT", 10, -40)
TopBar:SetSize(600, 40)

-- Helper to create styled input
local function CreateStyledInput(name, w, xPos, placeholder)
    local f = CreateFrame("Frame", nil, TopBar, "BackdropTemplate")
    f:SetSize(w, 26)
    f:SetPoint("LEFT", xPos, 0)
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    f:SetBackdropColor(0, 0, 0, 0.5)
    f:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    
    local eb = CreateFrame("EditBox", nil, f)
    eb:SetPoint("TOPLEFT", 4, -4)
    eb:SetPoint("BOTTOMRIGHT", -4, 4)
    eb:SetFontObject("GameFontHighlight")
    eb:SetAutoFocus(false)
    eb:SetText(placeholder)
    
    -- Drag & Drop / Shift-Click Support
    local function OnItemRecv()
        local type, id, link = GetCursorInfo()
        if type == "item" then
            local itemName = GetItemInfo(id)
            if itemName then
                if name == "Item Name" then
                    eb:SetText(itemName)
                    AC_SearchBtn:Click() -- Auto analyze
                end
            end
            ClearCursor()
        end
    end
    
    eb:SetScript("OnReceiveDrag", OnItemRecv)
    eb:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and IsModifiedClick("CHATLINK") then
            -- Handle chat linking logic if needed.
        end
    end)
    eb:SetScript("OnTextChanged", function(self)
        -- Cleanup Item Links to just Name if pasted
        local text = self:GetText()
        if text:find("|Hitem:") then
            local itemName = GetItemInfo(text)
            if itemName then
               self:SetText(itemName)
            else
               -- Fallback regex
               local extracted = text:match("%[(.-)%]")
               if extracted then self:SetText(extracted) end
            end
        end
    end)
    
    local lbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 2)
    lbl:SetText(L[name:gsub(" ", "_"):upper()] or name)
    
    return eb
end

local SearchBox = CreateStyledInput("ITEM_NAME", 160, 10, "Copper Ore")
local PriceBox = CreateStyledInput("PRICE_GOLD", 80, 180, "0.50")

-- Track Button
local TrackBtn = CreateFrame("Button", nil, TopBar, "BackdropTemplate")
TrackBtn:SetSize(26, 26)
TrackBtn:SetPoint("LEFT", 270, 0)
TrackBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})
TrackBtn:SetBackdropColor(0.2, 0.6, 0.4, 1)
local TrackText = TrackBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
TrackText:SetPoint("CENTER")
TrackText:SetText("+")
TrackBtn:SetScript("OnClick", function()
    local name = SearchBox:GetText()
    local price = PriceBox:GetText()
    if name ~= "" and price ~= "" then
        table.insert(AzerothCandlesticksDB.watchlist, { name = name, lastPrice = price })
        print("|cff00e5ccAC:|r " .. L.ITEM_ADDED .. name)
        NS.RefreshDashboard()
    end
end)

-- Dashboard Toggle
local DashBtn = CreateFrame("Button", nil, TopBar, "BackdropTemplate")
DashBtn:SetSize(100, 26)
DashBtn:SetPoint("LEFT", 400, 0)
DashBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})
DashBtn:SetBackdropColor(0.2, 0.2, 0.5, 1)
local DashText = DashBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
DashText:SetPoint("CENTER")
DashText:SetText(L.DASHBOARD)

local function UpdateDashBtnText()
    if not AzerothCandlesticksDB or not AzerothCandlesticksDB.config then return end
    if AzerothCandlesticksDB.config.viewMode == "SINGLE" then
        DashText:SetText(L.DASHBOARD)
    else
        DashText:SetText(L.SINGLE)
    end
end

DashBtn:SetScript("OnClick", function()
    if AzerothCandlesticksDB.config.viewMode == "SINGLE" then
        AzerothCandlesticksDB.config.viewMode = "DASHBOARD"
    else
        AzerothCandlesticksDB.config.viewMode = "SINGLE"
    end
    UpdateDashBtnText()
    NS.RefreshView()
end)
-- Enable mouse interaction for drag
SearchBox:EnableMouse(true)
PriceBox:EnableMouse(true)

-- Analyze Button (Renamed to AC_SearchBtn to ensure uniqueness)
AC_SearchBtn = CreateFrame("Button", nil, TopBar, "BackdropTemplate")
AC_SearchBtn:SetSize(80, 26)
AC_SearchBtn:SetPoint("LEFT", 310, 0)
AC_SearchBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
AC_SearchBtn:SetBackdropColor(0.4, 0.1, 0.6, 1) -- Bright Purple
AC_SearchBtn:SetBackdropBorderColor(0.8, 0.4, 1.0, 1)

local SearchBtnText = AC_SearchBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
SearchBtnText:SetPoint("CENTER")
SearchBtnText:SetText(L.UPDATE)

-- ... (Data Management logic remains) ...

-- Zoom buttons logic follows... (SignalFrame positioned at init)

-- Zoom Buttons Container
local ZoomBar = CreateFrame("Frame", nil, MainFrame)
ZoomBar:SetPoint("TOPRIGHT", -20, -40) -- Aligned with Inputs
ZoomBar:SetSize(200, 25)

-- ... (Zoom buttons logic) ...

-- Adjust TopBar position if needed

-- Data Management
local activeData = {}

local function LoadItemData(itemName, startPrice)
    -- Deterministic "random" based on item name (Simple LCG)
    local seed = 0
    for i=1, #itemName do seed = seed + string.byte(itemName, i) end
    
    -- Local PRNG function
    local function PseudoRandom()
        seed = (seed * 1103515245 + 12345) % 2147483648
        return (seed / 2147483648)
    end
    
    -- Generate 7 days of hourly data (7 * 24 = 168 candles)
    -- BACKWARDS GENERATION: Start at current price and walk back
    local dataCount = 168
    local data = {}
    
    -- Parse Input Price safely (Handle commas for Spanish users: 0,30 vs 0.30)
    -- Also handle suffixes like "30s" or "50c"
    local pStr = tostring(startPrice or ""):lower()
    pStr = pStr:gsub(",", ".") -- Replace comma with dot
    
    local multiplier = 1
    if pStr:find("s") then
        multiplier = 0.01 -- Silver
        pStr = pStr:gsub("s", "")
    elseif pStr:find("c") then
        multiplier = 0.0001 -- Copper
        pStr = pStr:gsub("c", "")
    elseif pStr:find("g") then
        pStr = pStr:gsub("g", "")
    end
    
    local val = tonumber(pStr)
    local currentClose = 10.00 -- Default if failed
    if val then
        currentClose = val * multiplier
    end
    
    if currentClose <= 0.0001 then currentClose = 0.01 end
    
    -- We convert gold to copper internal calculation for precision
    local currentPrice = currentClose * 100 -- Working in Silver/Copper scale approx
    
    -- Generate history backwards
    local history = {}
    -- Trend Bias: Some items naturally trend up or down slightly over the week
    local trend = (PseudoRandom() - 0.5) * 0.002
    
    for i = 1, dataCount do
        -- Volatility: Reduced to 0.5%
        local volFactor = 0.005 + (PseudoRandom() * 0.01) 
        local change = (PseudoRandom() - 0.5) * (currentPrice * volFactor)
        
        -- Apply trend bias inverted (since we walk backwards)
        change = change - (currentPrice * trend)
        
        local close = currentPrice
        local open = close - change
        
        -- Realistic Wicks
        local high = math.max(open, close) + (PseudoRandom() * currentPrice * 0.005)
        local low = math.min(open, close) - (PseudoRandom() * currentPrice * 0.005)
        
        -- Safety: Price cannot go below 1 copper
        if low < 1 then low = 1 end
        if open < 1 then open = 1 end
        if close < 1 then close = 1 end
        if high < 1 then high = 1 end
        
        table.insert(history, 1, { -- Insert at beginning
            open = open, close = close, high = high, low = low, timestamp = i
        })
        
        -- Next iteration's "close" is this iteration's "open" (walking backwards)
        currentPrice = open
    end
    
    MainFrame.title:SetText("Azeroth Candlesticks: " .. itemName)
    activeData = history
    return history
end

local currentViewCount = 168

-- Zoom/Slice Logic
function NS.PrepareChartData(itemName, startPrice)
    local fullData = LoadItemData(itemName, startPrice)
    local count = AzerothCandlesticksDB.config.currentZoom or 168
    
    local startIndex = math.max(1, #fullData - count + 1)
    local slice = {}
    for i = startIndex, #fullData do
        table.insert(slice, fullData[i])
    end
    return slice
end

local function UpdateSignal(data)
    if not data or #data == 0 then return end
    local lastClose = data[#data].close
    local prevClose = data[1].close
    local perf = (lastClose - prevClose) / prevClose
    local priceStr = string.format("|cffffd100%.2fg|r", lastClose / 100)
    
    if perf > 0.05 then
        signalText:SetText(string.format("%s: %s  %s: |cff00e5cc%s|r (+%d%%)", L.PRICE_GOLD, priceStr, L.SIGNAL, L.VOID_ASC, math.floor(perf*100)))
    elseif perf < -0.05 then
        signalText:SetText(string.format("%s: %s  %s: |cffe50080%s|r (%d%%)", L.PRICE_GOLD, priceStr, L.SIGNAL, L.VOID_CRASH, math.floor(perf*100)))
    else
        signalText:SetText(string.format("%s: %s  %s: |cffadb0ba%s|r", L.PRICE_GOLD, priceStr, L.SIGNAL, L.STAGNANT))
    end
end

DrawSlice = function(count)
    AzerothCandlesticksDB.config.currentZoom = count
    NS.RefreshView()
    -- Highlight active button
    for c, btn in pairs(ZoomButtons) do
        if c == count then
            btn:SetBackdropBorderColor(0.0, 0.9, 0.8, 1) -- Active Cyan
            btn:SetBackdropColor(0.3, 1.0, 0.9, 0.2)
        else
            btn:SetBackdropBorderColor(0.5, 0.3, 0.8, 1)
            btn:SetBackdropColor(0.2, 0.1, 0.3, 1)
        end
    end
end

-- Reposition Signal Text to BOTTOM LEFT corner to avoid overlap completely (ENSURE THIS runs)
signalFrame:ClearAllPoints()
signalFrame:SetPoint("BOTTOMLEFT", 10, 15)

-- Zoom Buttons Container
local ZoomBar = CreateFrame("Frame", nil, MainFrame)
ZoomBar:SetPoint("TOPRIGHT", -20, -40) -- Aligned with Inputs
ZoomBar:SetSize(200, 25)

SearchBox:SetScript("OnEnterPressed", function() AC_SearchBtn:Click() end)
PriceBox:SetScript("OnEnterPressed", function() AC_SearchBtn:Click() end)

local function CreateZoomButton(text, count)
    local btn = CreateFrame("Button", nil, ZoomBar, "BackdropTemplate")
    btn:SetSize(50, 20)
    
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    btn:SetBackdropColor(0.2, 0.1, 0.3, 1)
    btn:SetBackdropBorderColor(0.5, 0.3, 0.8, 1)
    
    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btnText:SetPoint("CENTER")
    btnText:SetText(text)
    
    btn:SetScript("OnEnter", function(s) s:SetBackdropColor(0.3, 0.2, 0.5, 1) end)
    btn:SetScript("OnLeave", function(s) s:SetBackdropColor(0.2, 0.1, 0.3, 1) end)
    
    btn:SetScript("OnClick", function()
        DrawSlice(count)
    end)
    ZoomButtons[count] = btn
    return btn
end

local btn7D = CreateZoomButton("7D", 168) 
btn7D:SetPoint("RIGHT", 0, 0)
local btn24H = CreateZoomButton("24H", 24)
btn24H:SetPoint("RIGHT", btn7D, "LEFT", -5, 0)
local btn1H = CreateZoomButton("1H", 6)
btn1H:SetPoint("RIGHT", btn24H, "LEFT", -5, 0)

-- Main Viewport Management
MainChart = CreateChartView(MainFrame, 780, 350)
MainChart:SetPoint("TOPLEFT", 10, -120)

local DashboardFrame = CreateFrame("Frame", nil, MainFrame)
DashboardFrame:SetPoint("TOPLEFT", 10, -120)
DashboardFrame:SetPoint("BOTTOMRIGHT", -10, 10)
DashboardFrame:Hide()

-- GALLERY VIEW ASSETS
local GalleryContainer = CreateFrame("Frame", nil, DashboardFrame)
GalleryContainer:SetAllPoints()

local NavPrev = CreateFrame("Button", nil, GalleryContainer, "BackdropTemplate")
NavPrev:SetSize(40, 40)
NavPrev:SetPoint("LEFT", GalleryContainer, "LEFT", -15, 0)
NavPrev:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
NavPrev:SetBackdropColor(0.1, 0.1, 0.2, 0.8)
local NavPrevText = NavPrev:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
NavPrevText:SetPoint("CENTER")
NavPrevText:SetText("<")
NavPrev:SetScript("OnClick", function()
    local count = #AzerothCandlesticksDB.watchlist
    if count == 0 then return end
    local idx = AzerothCandlesticksDB.config.dashboardIndex or 1
    AzerothCandlesticksDB.config.dashboardIndex = (idx - 2 + count) % count + 1
    NS.RefreshDashboard()
end)

local NavNext = CreateFrame("Button", nil, GalleryContainer, "BackdropTemplate")
NavNext:SetSize(40, 40)
NavNext:SetPoint("RIGHT", GalleryContainer, "RIGHT", 15, 0)
NavNext:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
NavNext:SetBackdropColor(0.1, 0.1, 0.2, 0.8)
local NavNextText = NavNext:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
NavNextText:SetPoint("CENTER")
NavNextText:SetText(">")
NavNext:SetScript("OnClick", function()
    local count = #AzerothCandlesticksDB.watchlist
    if count == 0 then return end
    local idx = AzerothCandlesticksDB.config.dashboardIndex or 1
    AzerothCandlesticksDB.config.dashboardIndex = (idx % count) + 1
    NS.RefreshDashboard()
end)

local GalleryChart = CreateChartView(GalleryContainer, 700, 350)
GalleryChart:SetPoint("CENTER", 0, 0)
GalleryChart.title = GalleryChart:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
GalleryChart.title:SetPoint("TOP", 0, 30)

local DashIndicator = GalleryContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
DashIndicator:SetPoint("BOTTOM", 0, -10)

-- GRID VIEW ASSETS (Scrollable)
local ScrollFrame = CreateFrame("ScrollFrame", "AC_ScrollFrame", DashboardFrame, "UIPanelScrollFrameTemplate")
ScrollFrame:SetPoint("TOPLEFT", 0, -30)
ScrollFrame:SetPoint("BOTTOMRIGHT", -25, 10)
ScrollFrame:Hide()

local ScrollChild = CreateFrame("Frame", nil, ScrollFrame)
ScrollChild:SetSize(ScrollFrame:GetWidth(), 1)
ScrollFrame:SetScrollChild(ScrollChild)

local gridViews = {}

-- View Toggle Button (Sub-Layout)
local LayoutToggle = CreateFrame("Button", nil, DashboardFrame, "BackdropTemplate")
LayoutToggle:SetSize(120, 22)
LayoutToggle:SetPoint("TOPLEFT", 10, 5)
LayoutToggle:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
LayoutToggle:SetBackdropColor(0.3, 0.2, 0.4, 1)
local LayoutToggleText = LayoutToggle:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
LayoutToggleText:SetPoint("CENTER")

LayoutToggle:SetScript("OnClick", function()
    if AzerothCandlesticksDB.config.dashboardType == "GALLERY" then
        AzerothCandlesticksDB.config.dashboardType = "GRID"
    else
        AzerothCandlesticksDB.config.dashboardType = "GALLERY"
    end
    NS.RefreshDashboard()
end)

function NS.RefreshDashboard()
    if AzerothCandlesticksDB.config.dashboardType == "GALLERY" then
        LayoutToggleText:SetText(L.LAYOUT .. ": " .. L.GRID)
        ScrollFrame:Hide()
        GalleryContainer:Show()
        
        local items = AzerothCandlesticksDB.watchlist
        if #items == 0 then
            GalleryChart:Hide()
            GalleryChart.title:SetText(L.WATCHLIST_EMPTY)
            DashIndicator:SetText(L.ADD_ITEMS)
            return
        end
        local idx = AzerothCandlesticksDB.config.dashboardIndex or 1
        if idx > #items then idx = 1 end
        local item = items[idx]
        GalleryChart:Show()
        GalleryChart.title:SetText(item.name)
        DashIndicator:SetText(string.format("Item %d de %d", idx, #items))
        GalleryChart:SetIconByItem(item.name)
        GalleryChart:Draw(NS.PrepareChartData(item.name, item.lastPrice))
    else
        LayoutToggleText:SetText(L.LAYOUT .. ": " .. L.GALLERY)
        GalleryContainer:Hide()
        ScrollFrame:Show()
        
        -- Clear grid views (Recycle)
        for _, v in ipairs(gridViews) do v:Hide() end
        
        local items = AzerothCandlesticksDB.watchlist
        local cols = 2
        local spacingX, spacingY = 10, 40
        local chartW = (ScrollFrame:GetWidth() - (cols-1)*spacingX) / cols
        local chartH = 160
        
        for i, item in ipairs(items) do
            local view = gridViews[i]
            if not view then
                view = CreateChartView(ScrollChild, chartW, chartH)
                table.insert(gridViews, view)
                view.title = view:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                view.title:SetPoint("BOTTOMLEFT", view, "TOPLEFT", 0, 2)
            end
            
            local row = math.floor((i-1)/cols)
            local col = (i-1)%cols
            view:SetSize(chartW, chartH)
            view:SetPoint("TOPLEFT", col*(chartW + spacingX), -(row*(chartH + spacingY) + 20))
            view:Show()
            view.title:SetText(item.name)
            view:SetIconByItem(item.name)
            view:Draw(NS.PrepareChartData(item.name, item.lastPrice))
            
            -- Update ScrollChild Height
            ScrollChild:SetHeight((row + 1) * (chartH + spacingY) + 40)
        end
    end
end

function NS.RefreshView()
    if AzerothCandlesticksDB.config.viewMode == "DASHBOARD" then
        MainChart:Hide()
        signalFrame:Hide()
        DashboardFrame:Show()
        NS.RefreshDashboard()
        MainFrame.title:SetText(L.DASHBOARD .. ": Gallery Mode")
    else
        DashboardFrame:Hide()
        MainChart:Show()
        signalFrame:Show()
        local name = SearchBox:GetText()
        local price = PriceBox:GetText()
        local data = NS.PrepareChartData(name, price)
        MainChart:SetIconByItem(name)
        MainChart:Draw(data)
        MainFrame.title:SetText("Azeroth Candlesticks: " .. name)
        UpdateSignal(data)
    end
end

-- Initial Load Implementation
local function InitialLoad()
    InitDB()
    UpdateDashBtnText()
    NS.RefreshView()
end

-- Adjusted Zoom Logic for MainChart
local function DrawSlice(count)
    if not MainChart.data or #MainChart.data == 0 then return end
    currentViewCount = count
    local startIndex = math.max(1, #activeData - count + 1)
    local slice = {}
    for i = startIndex, #activeData do table.insert(slice, activeData[i]) end
    MainChart:Draw(slice)
    
    -- Signal logic (rest unchanged but using MainChart.data)
    local lastClose = slice[#slice].close
    local prevClose = slice[1].close
    local perf = (lastClose - prevClose) / prevClose
    local priceStr = string.format("|cffffd100%.2fg|r", lastClose / 100)
    if perf > 0.05 then
        signalText:SetText(string.format("%s: %s  %s: |cff00e5cc%s|r (+%d%%)", L.PRICE_GOLD, priceStr, L.SIGNAL, L.VOID_ASC, math.floor(perf*100)))
    elseif perf < -0.05 then
        signalText:SetText(string.format("%s: %s  %s: |cffe50080%s|r (%d%%)", L.PRICE_GOLD, priceStr, L.SIGNAL, L.VOID_CRASH, math.floor(perf*100)))
    else
        signalText:SetText(string.format("%s: %s  %s: |cffadb0ba%s|r", L.PRICE_GOLD, priceStr, L.SIGNAL, L.STAGNANT))
    end
end

-- Basic resize handling
MainFrame:SetResizable(true)
MainFrame:SetScript("OnSizeChanged", function() 
    if #activeData > 0 then
        DrawSlice(currentViewCount) 
    end
end)

-- Slash Command
SLASH_AZEROTHCANDLESTICKS1 = "/ac"
SLASH_AZEROTHCANDLESTICKS2 = "/candles"
SlashCmdList["AZEROTHCANDLESTICKS"] = function(msg)
    MainFrame:Show()
end

-- REAL AUCTION HOUSE SCANNING LOGIC
-- (Logic consolidated below)


-- Search Button State Management
AC_SearchBtn:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer > 0.5 then
        self.timer = 0
        -- Fix: Removing crashing C_AuctionHouse.IsAuctionHouseOpen call.
        -- Relying strictly on Frame visibility which is reliable.
        local isOpen = (AuctionHouseFrame and AuctionHouseFrame:IsShown())
        
        -- State Change Debug (Only print on change)
        if isOpen ~= self.wasOpen then
            self.wasOpen = isOpen
        end
        
        if isOpen then
            SearchBtnText:SetText(L.SCAN)
            self:SetBackdropColor(0.0, 0.6, 0.2, 1) -- Green for Scan
        else
            SearchBtnText:SetText(L.UPDATE)
            self:SetBackdropColor(0.4, 0.1, 0.6, 1) -- Purple for Manual
        end
    end
end)

local Scanner = CreateFrame("Frame")
Scanner:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED")
Scanner.isScanning = false
Scanner.targetItem = nil

Scanner:SetScript("OnEvent", function(self, event, ...)
    if event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" and self.isScanning then
        self.isScanning = false
        
        -- Ensure C_AuctionHouse exists before calling
        if not C_AuctionHouse then return end
        
        local results = C_AuctionHouse.GetBrowseResults()
        local bestPrice = nil
        
        for _, result in ipairs(results) do
            if result.minPrice and result.minPrice > 0 then
                if not bestPrice or result.minPrice < bestPrice then
                    bestPrice = result.minPrice
                end
            end
        end
        
        if bestPrice then
            -- Convert copper to Gold string
            local goldVal = bestPrice / 10000 
            PriceBox:SetText(string.format("%.2f", goldVal))
            print("|cff00e5ccAC:|r " .. string.format(L.MATCH_FOUND, Scanner.targetItem, GetMoneyString(bestPrice)))
            
            -- Auto update chart with real price
            LoadItemData(Scanner.targetItem, tostring(goldVal))
            DrawSlice(168)
        else
            print("|cff00e5ccAC:|r " .. L.SCAN_COMPLETE)
        end
    end
end)

-- Update Search Button to use Real Scan if AH is Open
AC_SearchBtn:SetScript("OnClick", function()
    local item = SearchBox:GetText()
    local isOpen = (AuctionHouseFrame and AuctionHouseFrame:IsShown())
    
    if isOpen and C_AuctionHouse then
        print("|cff00e5ccAC:|r " .. string.format(L.SCANNING, item))
        Scanner.isScanning = true
        Scanner.targetItem = item
        
        local query = {}
        query.searchString = item
        query.minLevel = 0
        query.maxLevel = 0
        query.filters = {} 
        query.itemClassFilters = {}
        query.sorts = {
            { sortOrder = 0, reverseSort = false } -- Sort by Price Ascending
        }
        
        -- Fix: Use SendBrowseQuery for name-based searching (SendSearchQuery is for specific ItemKeys)
        C_AuctionHouse.SendBrowseQuery(query) 
    else
        LoadItemData(item, PriceBox:GetText())
        DrawSlice(168) 
        if not isOpen then
             print("|cff00e5ccAC:|r " .. L.AH_NOT_OPEN)
        end
    end

    SearchBox:ClearFocus()
    PriceBox:ClearFocus()
end)

-- Load Confirmation
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == addonName then
        InitialLoad()
        print("|cff00e5ccAC:|r " .. L.LOADED)
    end
end)
