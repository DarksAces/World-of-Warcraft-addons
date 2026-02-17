local addonName, addon = ...

-- Default settings
local defaults = {
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 0,
    locked = false,
}

-- Main Frame
local frame = CreateFrame("Frame", "BagWatchFrame", UIParent, "BackdropTemplate")
frame:SetSize(120, 30)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)

-- Backdrop
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0, 0, 0, 0.8)

-- Icon
local icon = frame:CreateTexture(nil, "ARTWORK")
icon:SetSize(20, 20)
icon:SetPoint("LEFT", 8, 0)
icon:SetTexture("Interface\\AddOns\\BagWatch\\icon.png")

-- Text
local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
text:SetText("Bag: --")

-- Event Handling
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("PLAYER_LOGIN")

local function UpdateBagSpace()
    local free = 0
    for bag = 0, 4 do
        free = free + C_Container.GetContainerNumFreeSlots(bag)
    end
    
    local r, g, b = 0, 1, 0 -- Green
    if free < 10 then
        r, g, b = 1, 0, 0 -- Red
    elseif free < 20 then
        r, g, b = 1, 1, 0 -- Yellow
    end
    
    text:SetText(string.format("Bag: |cff%02x%02x%02x%d|r", r*255, g*255, b*255, free))
end

local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        BagWatchDB = BagWatchDB or {}
        for k, v in pairs(defaults) do
            if BagWatchDB[k] == nil then
                BagWatchDB[k] = v
            end
        end
        
        frame:ClearAllPoints()
        frame:SetPoint(BagWatchDB.point, UIParent, BagWatchDB.relativePoint, BagWatchDB.x, BagWatchDB.y)
        
        if BagWatchDB.locked then
            frame:EnableMouse(false)
            frame:SetBackdropColor(0, 0, 0, 0)
            frame:SetBackdropBorderColor(0, 0, 0, 0)
        else
            frame:EnableMouse(true)
            frame:SetBackdropColor(0, 0, 0, 0.8)
            frame:SetBackdropBorderColor(1, 1, 1, 1)
        end
        
        UpdateBagSpace()
    elseif event == "BAG_UPDATE" then
        UpdateBagSpace()
    end
end

frame:SetScript("OnEvent", OnEvent)

-- Dragging
frame:SetScript("OnDragStart", function(self)
    if not BagWatchDB.locked then
        self:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self:GetPoint()
    BagWatchDB.point = point
    BagWatchDB.relativePoint = relativePoint
    BagWatchDB.x = x
    BagWatchDB.y = y
end)

-- Slash Commands
SLASH_BAGWATCH1 = "/bw"
SLASH_BAGWATCH2 = "/bagwatch"

SlashCmdList["BAGWATCH"] = function(msg)
    local cmd = msg:lower()
    if cmd == "reset" then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER")
        BagWatchDB.point = "CENTER"
        BagWatchDB.relativePoint = "CENTER"
        BagWatchDB.x = 0
        BagWatchDB.y = 0
        print("|cff00ff00BagWatch:|r Position reset.")
    elseif cmd == "lock" then
        BagWatchDB.locked = true
        frame:EnableMouse(false)
        frame:SetBackdropColor(0, 0, 0, 0)
        frame:SetBackdropBorderColor(0, 0, 0, 0)
        print("|cff00ff00BagWatch:|r Frame locked.")
    elseif cmd == "unlock" then
        BagWatchDB.locked = false
        frame:EnableMouse(true)
        frame:SetBackdropColor(0, 0, 0, 0.8)
        frame:SetBackdropBorderColor(1, 1, 1, 1)
        print("|cff00ff00BagWatch:|r Frame unlocked.")
    else
        print("|cff00ff00BagWatch:|r Commands: /bw lock, /bw unlock, /bw reset")
    end
end
