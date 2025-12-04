-- SmartBags: Intelligent Inventory
local ADDON_NAME = "SmartBags"
local frame = CreateFrame("Frame", "SmartBagsFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(600, 400)
frame:SetPoint("CENTER")
frame:Hide()
frame.TitleBg:SetHeight(30)
frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
frame.title:SetText("SmartBags")

-- Close button behavior
frame.CloseButton:SetScript("OnClick", function() frame:Hide() end)

-- Categories
local CATEGORIES = {
    ["Equipment"] = {},
    ["Consumable"] = {},
    ["Trade Goods"] = {},
    ["Quest"] = {},
    ["Junk"] = {},
    ["Misc"] = {}
}

local ORDER = {"Equipment", "Consumable", "Trade Goods", "Quest", "Misc", "Junk"}

-- Helper: Get Category
local function GetCategory(itemLink)
    local _, _, quality, _, _, _, _, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(itemLink)
    
    if quality == 0 then return "Junk" end
    if classID == 12 then return "Quest" end -- Quest
    if classID == 2 or classID == 4 then return "Equipment" end -- Weapon/Armor
    if classID == 0 then return "Consumable" end -- Consumable
    if classID == 7 then return "Trade Goods" end -- Trade Goods
    
    return "Misc"
end

-- Item Buttons Cache
local itemButtons = {}
local function GetItemButton(index)
    if not itemButtons[index] then
        local btn = CreateFrame("Button", "SmartBagItem"..index, frame, "ContainerFrameItemButtonTemplate")
        btn:SetSize(30, 30)
        itemButtons[index] = btn
    end
    return itemButtons[index]
end

-- Scan and Draw
local function UpdateBags()
    -- Reset Categories
    for k in pairs(CATEGORIES) do CATEGORIES[k] = {} end
    
    -- Scan
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info then
                local link = info.hyperlink
                if link then
                    local cat = GetCategory(link)
                    table.insert(CATEGORIES[cat], {bag=bag, slot=slot, info=info})
                end
            end
        end
    end
    
    -- Draw
    local x, y = 20, -40
    local btnIndex = 1
    
    -- Hide all existing buttons first
    for _, btn in pairs(itemButtons) do btn:Hide() end
    
    for _, catName in ipairs(ORDER) do
        local items = CATEGORIES[catName]
        if #items > 0 then
            -- Header
            local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header:SetPoint("TOPLEFT", x, y)
            header:SetText(catName)
            y = y - 20
            
            -- Items
            local startX = x
            for i, item in ipairs(items) do
                local btn = GetItemButton(btnIndex)
                btn:SetID(item.slot)
                -- Fix for bag ID in classic/retail variance, usually SetBagID is needed or parent
                -- For simplicity in this mockup, we just set textures
                SetItemButtonTexture(btn, item.info.iconFileID)
                SetItemButtonCount(btn, item.info.stackCount)
                SetItemButtonQuality(btn, item.info.quality, item.info.hyperlink)
                
                btn:SetPoint("TOPLEFT", x, y)
                btn:Show()
                
                -- Tooltip handling
                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetBagItem(item.bag, item.slot)
                    GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                -- Click handling (Use)
                btn:SetScript("OnClick", function()
                    C_Container.UseContainerItem(item.bag, item.slot)
                end)
                
                btnIndex = btnIndex + 1
                x = x + 35
                if x > 550 then -- Wrap
                    x = startX
                    y = y - 35
                end
            end
            
            -- New line for next category
            x = 20
            y = y - 45
        end
    end
end

-- Events
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", UpdateBags)
frame:SetScript("OnShow", UpdateBags)

-- Hook Bag Open
hooksecurefunc("OpenAllBags", function()
    frame:Show()
end)

-- Slash Command
SLASH_SMARTBAGS1 = "/sb"
SlashCmdList["SMARTBAGS"] = function()
    if frame:IsShown() then frame:Hide() else frame:Show() end
end
