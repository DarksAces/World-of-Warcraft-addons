local addonName, NS = ...

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

-- Canvas for drawing
local Canvas = CreateFrame("Frame", nil, MainFrame)
Canvas:SetPoint("TOPLEFT", 10, -50)
Canvas:SetPoint("BOTTOMRIGHT", -10, 10)
Canvas.content = Canvas:CreateTexture(nil, "BACKGROUND")
Canvas.content:SetAllPoints()
Canvas.content:SetColorTexture(unpack(CONFIG.colors.grid))
Canvas:SetClipsChildren(true) -- FIX: Cuts off any overflow

-- Candle Frame Pool (Interactive)
local candlePool = {}
local activeCandles = {}

local function FormatPriceTooltip(val)
    -- Internal 'val' is roughly Silver (0.50g input -> 50.0 val).
    -- We want to display it exactly as the input: "0.50 g"
    return string.format("|cffffd100%.2f g|r", val / 100)
end

local function AcquireCandle()
    local f = table.remove(candlePool)
    if not f then
        f = CreateFrame("Button", nil, Canvas)
        f:SetFrameLevel(10)
        
        f.wick = f:CreateTexture(nil, "ARTWORK")
        f.body = f:CreateTexture(nil, "ARTWORK")
        
        f:SetScript("OnEnter", function(self)
            local d = self.data
            if not d then return end
            
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Datos de Mercado", 0.4, 0.2, 0.8)
            GameTooltip:AddLine("Máximo: |cffffffff"..FormatPriceTooltip(d.high).."|r")
            GameTooltip:AddLine("Inicio: |cffffffff"..FormatPriceTooltip(d.open).."|r")
            GameTooltip:AddLine("Cierre: |cffffffff"..FormatPriceTooltip(d.close).."|r")
            GameTooltip:AddLine("Mínimo: |cffffffff"..FormatPriceTooltip(d.low).."|r")
            GameTooltip:Show()
            self.body:SetAlpha(0.6)
        end)
        
        f:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            self.body:SetAlpha(1.0)
        end)
    end
    table.insert(activeCandles, f)
    f:Show()
    return f
end

local function ReleaseAllCandles()
    for _, f in ipairs(activeCandles) do
        f:Hide()
        table.insert(candlePool, f)
    end
    activeCandles = {}
end

-- Drawing Logic
local function DrawChart(data)
    ReleaseAllCandles()
    
    local width = Canvas:GetWidth()
    local height = Canvas:GetHeight()
    local numCandles = #data
    
    if numCandles == 0 then return end
    
    -- Find ranges
    local minPrice, maxPrice = data[1].low, data[1].high
    for _, candle in ipairs(data) do
        if candle.low < minPrice then minPrice = candle.low end
        if candle.high > maxPrice then maxPrice = candle.high end
    end
    
    local priceRange = maxPrice - minPrice
    if priceRange == 0 then priceRange = 1 end
    
    -- SLOT BASED DRAWING (Precision Fit)
    local slotWidth = width / numCandles
    local spacing = 2
    
    -- Adjust spacing for very tight views
    if slotWidth < 5 then spacing = 1 end
    if slotWidth < 3 then spacing = 0 end
    
    local visualWidth = slotWidth - spacing
    
    -- Caps
    if visualWidth < 1 then visualWidth = 1 end
    if visualWidth > 150 then visualWidth = 150 end
    
    for i = 1, numCandles do
        local d = data[i]
        local xPos = (i - 1) * slotWidth
        
        -- Y Coordinates
        local yHigh = ((d.high - minPrice) / priceRange) * height
        local yLow = ((d.low - minPrice) / priceRange) * height
        local yOpen = ((d.open - minPrice) / priceRange) * height
        local yClose = ((d.close - minPrice) / priceRange) * height
        
        local color = (d.close >= d.open) and CONFIG.colors.bullish or CONFIG.colors.bearish
        
        local f = AcquireCandle()
        f.data = d 
        
        -- Frame fills the slot for easy hovering
        f:SetPoint("BOTTOMLEFT", Canvas, "BOTTOMLEFT", xPos, 0)
        f:SetSize(slotWidth, height) 
        
        -- Wick
        local wickBottom = yLow
        local wickHeight = math.max(1, yHigh - yLow)
        
        f.wick:SetColorTexture(unpack(color))
        f.wick:ClearAllPoints()
        f.wick:SetPoint("BOTTOM", f, "BOTTOM", 0, wickBottom)
        -- Wick scales slightly but stays thin relative to big candles
        f.wick:SetSize(math.max(1, visualWidth * 0.1), wickHeight) 
        
        -- Body
        local bodyTop = math.max(yOpen, yClose)
        local bodyBottom = math.min(yOpen, yClose)
        local bodyHeight = math.max(1, bodyTop - bodyBottom) 
        
        f.body:SetColorTexture(unpack(color))
        f.body:ClearAllPoints()
        f.body:SetPoint("BOTTOM", f, "BOTTOM", 0, bodyBottom)
        f.body:SetSize(visualWidth, bodyHeight)
    end
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
    lbl:SetText(name)
    
    return eb
end

local SearchBox = CreateStyledInput("Item Name", 160, 10, "Copper Ore")
local PriceBox = CreateStyledInput("Price (Gold)", 80, 180, "0.50")
-- Enable mouse interaction for drag
SearchBox:EnableMouse(true)
PriceBox:EnableMouse(true)

-- Analyze Button (Renamed to AC_SearchBtn to ensure uniqueness)
AC_SearchBtn = CreateFrame("Button", nil, TopBar, "BackdropTemplate")
AC_SearchBtn:SetSize(80, 26)
AC_SearchBtn:SetPoint("LEFT", 270, 0)
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
SearchBtnText:SetText("UPDATE")

-- ... (Data Management logic remains) ...

-- Zoom buttons logic follows... (SignalFrame positioned at init)

-- Zoom Buttons Container
local ZoomBar = CreateFrame("Frame", nil, MainFrame)
ZoomBar:SetPoint("TOPRIGHT", -20, -40) -- Aligned with Inputs
ZoomBar:SetSize(200, 25)

-- ... (Zoom buttons logic) ...

-- Adjust Canvas Top to make room for everything
Canvas:SetPoint("TOPLEFT", 10, -100)

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
local function DrawSlice(count)
    if #activeData == 0 then return end
    currentViewCount = count
    
    -- Slice the last 'count' entries
    local startIndex = math.max(1, #activeData - count + 1)
    local slice = {}
    for i = startIndex, #activeData do
        table.insert(slice, activeData[i])
    end
    DrawChart(slice)
    
    -- Update Signal based on sliced view context
    local lastClose = slice[#slice].close
    local prevClose = slice[1].close -- Compare to start of view
    local perf = (lastClose - prevClose) / prevClose
    
    local priceStr = string.format("|cffffd100%.2fg|r", lastClose / 100)
    
    if perf > 0.05 then
        signalText:SetText(string.format("Price: %s  Signal: |cff00e5ccVoid Ascendance|r (+%d%%)", priceStr, math.floor(perf*100)))
    elseif perf < -0.05 then
        signalText:SetText(string.format("Price: %s  Signal: |cffe50080Void Crash|r (%d%%)", priceStr, math.floor(perf*100)))
    else
        signalText:SetText(string.format("Price: %s  Signal: |cffadb0baStagnant|r", priceStr))
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
    return btn
end

local btn7D = CreateZoomButton("7D", 168) 
btn7D:SetPoint("RIGHT", 0, 0)
local btn24H = CreateZoomButton("24H", 24)
btn24H:SetPoint("RIGHT", btn7D, "LEFT", -5, 0)
local btn1H = CreateZoomButton("1H", 6)
btn1H:SetPoint("RIGHT", btn24H, "LEFT", -5, 0)

-- Initial Load
LoadItemData("Copper Ore", "0.50")
DrawSlice(168)

-- Adjust Canvas Top to make room for everything
Canvas:SetPoint("TOPLEFT", 10, -120)

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
            SearchBtnText:SetText("SCAN")
            self:SetBackdropColor(0.0, 0.6, 0.2, 1) -- Green for Scan
        else
            SearchBtnText:SetText("UPDATE")
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
            print("|cff00e5ccAC:|r MATCH FOUND: " .. Scanner.targetItem .. " @ " .. GetMoneyString(bestPrice))
            
            -- Auto update chart with real price
            LoadItemData(Scanner.targetItem, tostring(goldVal))
            DrawSlice(168)
        else
            print("|cff00e5ccAC:|r Scan complete. Exact match not found.")
        end
    end
end)

-- Update Search Button to use Real Scan if AH is Open
AC_SearchBtn:SetScript("OnClick", function()
    local item = SearchBox:GetText()
    local isOpen = (AuctionHouseFrame and AuctionHouseFrame:IsShown())
    
    if isOpen and C_AuctionHouse then
        print("|cff00e5ccAC:|r Scanning for EXACT match: ["..item.."]...")
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
             print("|cff00e5ccAC:|r AH Not Open. Using Manual Inputs.")
        end
    end

    SearchBox:ClearFocus()
    PriceBox:ClearFocus()
end)

-- Load Confirmation
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    print("|cff00e5ccAC:|r v3.0 LOADED - CHECK CHAT. Type /ac to open.")
end)
