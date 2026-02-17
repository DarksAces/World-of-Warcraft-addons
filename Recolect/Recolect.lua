-- Recollect - DPS/Damage/Healing Meter - Modern Interface with Resizing and Pet Support
local ADDON_NAME = "Recollect"

-- Main frame with modern design and resizing capability
local Recollect = CreateFrame("Frame", "RecollectFrame", UIParent, "BackdropTemplate")
Recollect:SetSize(380, 520)
Recollect:SetPoint("CENTER", -300, 0)

-- Set minimum and maximum sizes manually (since SetMinResize doesn't exist in Classic)
local MIN_WIDTH, MIN_HEIGHT = 180, 200
local MAX_WIDTH, MAX_HEIGHT = 1000, 1200

-- Main background with simulated gradient
Recollect:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Glues/Common/TextPanel-Border",
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
Recollect:SetBackdropColor(0.02, 0.02, 0.08, 0.98)
Recollect:SetBackdropBorderColor(0.15, 0.4, 0.8, 1)

-- Make draggable and resizable
Recollect:EnableMouse(true)
Recollect:SetMovable(true)
Recollect:SetResizable(true)
Recollect:RegisterForDrag("LeftButton")
Recollect:SetScript("OnDragStart", function(self, button)
    if button == "LeftButton" and not IsShiftKeyDown() then
        self:StartMoving()
    end
end)
Recollect:SetScript("OnDragStop", Recollect.StopMovingOrSizing)

-- Resize grip
local resizeGrip = CreateFrame("Button", nil, Recollect)
resizeGrip:SetSize(20, 20)
resizeGrip:SetPoint("BOTTOMRIGHT", -2, 2)
resizeGrip:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
resizeGrip:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
resizeGrip:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")

resizeGrip:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        Recollect:StartSizing("BOTTOMRIGHT")
    end
end)

resizeGrip:SetScript("OnMouseUp", function(self, button)
    Recollect:StopMovingOrSizing()
    
    -- Enforce size limits
    local width, height = Recollect:GetSize()
    width = math.max(MIN_WIDTH, math.min(MAX_WIDTH, width))
    height = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, height))
    Recollect:SetSize(width, height)
    
    UpdateScrollFrameSize()
end)

-- Keep UI responsive to manual size changes
Recollect:SetScript("OnSizeChanged", function(self, width, height)
    if not width or not height then return end
    -- Enforce clamped sizes
    local clampedW = math.max(MIN_WIDTH, math.min(MAX_WIDTH, width))
    local clampedH = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, height))
    local curW, curH = self:GetSize()
    if clampedW ~= curW or clampedH ~= curH then
        self:SetSize(clampedW, clampedH)
        return -- wait for next OnSizeChanged to update layout
    end
    UpdateScrollFrameSize()
end)

-- Header with gradient
local headerBg = Recollect:CreateTexture(nil, "BACKGROUND", nil, 1)
headerBg:SetPoint("TOPLEFT", 5, -5)
headerBg:SetPoint("TOPRIGHT", -5, -5)
headerBg:SetHeight(45)
headerBg:SetTexture("Interface/LFGFrame/UI-LFG-BACKGROUND-Heroic")
headerBg:SetVertexColor(0.1, 0.25, 0.6, 0.9)

-- Title with glow effect
local title = Recollect:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -22)
title:SetText("|TInterface/Icons/Spell_Holy_PowerWordShield:20:20|t |cFF00D4FFRecollect|r |TInterface/Icons/Spell_Holy_PowerWordShield:20:20|t")
title:SetFont("Fonts/MORPHEUS.ttf", 18, "OUTLINE")
title:SetShadowOffset(2, -2)
title:SetShadowColor(0, 0, 0, 1)

-- Data variables
local data = {}
local combatStart = 0
local inCombat = false
local currentView = "DPS"
local sortDescending = true
local expandedPlayers = {} 
local playerClassCache = {}

-- Views with icons
local views = {
    { id = "DPS", name = "DPS", icon = "Interface/Icons/Ability_DualWield", color = {1, 0.7, 0} },
    { id = "DAMAGE", name = "Damage", icon = "Interface/Icons/Ability_Warrior_Trauma", color = {1, 0.2, 0.2} },
    { id = "DAMAGE_TAKEN", name = "Taken", icon = "Interface/Icons/Ability_Defend", color = {0.8, 0.3, 0.3} },
    { id = "HEALING_DONE", name = "Healing", icon = "Interface/Icons/Spell_Holy_Heal", color = {0.2, 1, 0.2} },
    { id = "HEALING_TAKEN", name = "Healed", icon = "Interface/Icons/Spell_Holy_Renew", color = {0.5, 1, 0.8} }
}

-- Stylized view buttons
local viewButtons = {}
local buttonWidth = 70
local buttonHeight = 32

for i, view in ipairs(views) do
    local btn = CreateFrame("Button", nil, Recollect, "BackdropTemplate")
    btn:SetSize(buttonWidth, buttonHeight)
    btn:SetPoint("TOPLEFT", 10 + (i-1) * (buttonWidth + 2), -60)
    
    -- Background with gradient
    btn:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Buttons/UI-Panel-Button-Up",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    
    -- Button icon
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", 5, 0)
    icon:SetTexture(view.icon)
    
    -- Button text
    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btnText:SetPoint("RIGHT", -5, 0)
    btnText:SetText(view.name)
    btnText:SetFont("Fonts/FRIZQT__.TTF", 10, "OUTLINE")
    
    btn.text = btnText
    btn.icon = icon
    btn.view = view
    
    -- Button states with animations
    local function UpdateButtonState()
        if currentView == view.id then
            btn:SetBackdropColor(view.color[1], view.color[2], view.color[3], 0.9)
            btn:SetBackdropBorderColor(1, 1, 1, 1)
            btnText:SetTextColor(1, 1, 1)
            icon:SetVertexColor(1, 1, 1, 1)
            btn:SetScale(1.05)
        else
            btn:SetBackdropColor(0.15, 0.15, 0.25, 0.8)
            btn:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.9)
            btnText:SetTextColor(0.7, 0.7, 0.7)
            icon:SetVertexColor(0.6, 0.6, 0.6, 0.8)
            btn:SetScale(1.0)
        end
    end
    
    btn:SetScript("OnClick", function()
        currentView = view.id
        for _, button in ipairs(viewButtons) do
            button.updateState()
        end
        UpdateDisplay()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    
    btn:SetScript("OnEnter", function()
        if currentView ~= view.id then
            btn:SetBackdropColor(view.color[1] * 0.6, view.color[2] * 0.6, view.color[3] * 0.6, 0.7)
            btn:SetScale(1.02)
        end
        GameTooltip:SetOwner(btn, "ANCHOR_TOP")
        GameTooltip:SetText(view.name, 1, 1, 1)
        GameTooltip:Show()
    end)
    
    btn:SetScript("OnLeave", function()
        if currentView ~= view.id then
            btn:SetBackdropColor(0.15, 0.15, 0.25, 0.8)
            btn:SetScale(1.0)
        end
        GameTooltip:Hide()
    end)
    
    btn.updateState = UpdateButtonState
    UpdateButtonState()
    
    viewButtons[i] = btn
end

-- Combat information bar
local combatInfo = Recollect:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
combatInfo:SetPoint("TOP", 0, -100)
combatInfo:SetFont("Fonts/FRIZQT__.TTF", 11, "OUTLINE")
combatInfo:SetTextColor(0.8, 0.8, 1)

-- Bottom buttons with modern style
local function CreateStyledButton(parent, text, color, icon)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(90, 30)
    
    btn:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Buttons/UI-Panel-Button-Up",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn:SetBackdropColor(color[1], color[2], color[3], 0.8)
    btn:SetBackdropBorderColor(1, 1, 1, 0.8)
    
    if icon then
        local btnIcon = btn:CreateTexture(nil, "ARTWORK")
        btnIcon:SetSize(16, 16)
        btnIcon:SetPoint("LEFT", 8, 0)
        btnIcon:SetTexture(icon)
        btn.icon = btnIcon
    end
    
    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btnText:SetPoint(icon and "RIGHT" or "CENTER", icon and -8 or 0, 0)
    btnText:SetText(text)
    btnText:SetFont("Fonts/FRIZQT__.TTF", 11, "OUTLINE")
    btnText:SetTextColor(1, 1, 1)
    btn.text = btnText
    
    btn:SetScript("OnEnter", function()
        btn:SetBackdropColor(color[1] * 1.2, color[2] * 1.2, color[3] * 1.2, 1)
        btn:SetScale(1.05)
    end)
    
    btn:SetScript("OnLeave", function()
        btn:SetBackdropColor(color[1], color[2], color[3], 0.8)
        btn:SetScale(1.0)
    end)
    
    return btn
end

-- Reset button
local resetBtn = CreateStyledButton(Recollect, "Reset", {0.8, 0.3, 0.3}, "Interface/Icons/Spell_ChargeNegative")
resetBtn:SetPoint("BOTTOMRIGHT", -40, 20)
resetBtn:SetScript("OnClick", function() 
    ResetData()
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
end)

-- Sort button
local sortBtn = CreateStyledButton(Recollect, "↓ Desc", {0.3, 0.6, 0.9}, "Interface/Icons/INV_Misc_Note_01")
sortBtn:SetPoint("BOTTOMLEFT", 20, 20)
sortBtn:SetScript("OnClick", function() 
    sortDescending = not sortDescending
    sortBtn.text:SetText(sortDescending and "↓ Desc" or "↑ Asc")
    UpdateDisplay()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end)

-- Close button
local closeBtn = CreateFrame("Button", nil, Recollect, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", 2, -2)
closeBtn:SetScript("OnClick", function() Recollect:Hide() end)

-- Scroll frame with style
local scrollBg = CreateFrame("Frame", nil, Recollect, "BackdropTemplate")
scrollBg:SetPoint("TOPLEFT", 15, -120)
scrollBg:SetPoint("BOTTOMRIGHT", -15, 60)
scrollBg:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Common/Common-Input-Border",
    edgeSize = 8,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
scrollBg:SetBackdropColor(0, 0, 0, 0.4)
scrollBg:SetBackdropBorderColor(0.3, 0.3, 0.4, 0.8)

local scrollFrame = CreateFrame("ScrollFrame", nil, scrollBg, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 5, -5)
scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)

local content = CreateFrame("Frame", nil, scrollFrame)
scrollFrame:SetScrollChild(content)

-- Function to update scroll frame size when window is resized
function UpdateScrollFrameSize()
    local width = scrollFrame and scrollFrame:GetWidth() or 300
    content:SetWidth(width)

    -- Calculate dynamic content height based on number of rows (row spacing ~28)
    local rowSpacing = 28
    local totalRows = (maxRows or 50)
    local totalRowsHeight = totalRows * rowSpacing
    -- Ensure content height at least the visible scroll area to avoid tiny scroll regions
    local minContentH = scrollFrame and scrollFrame:GetHeight() or 200
    content:SetHeight(math.max(totalRowsHeight, minContentH))

    -- Update all row widths (regardless of visibility so layout adapts)
    if rows then
        for _, row in pairs(rows) do
            if row then
                row:SetWidth(math.max(width - 10, 10))
            end
        end
    end

    -- Adapt view buttons layout to available width
    if viewButtons and #viewButtons > 0 then
        local totalButtons = #viewButtons
        local available = math.max(Recollect:GetWidth() - 20, 40)
        local per = math.max(40, math.floor((available - (totalButtons - 1) * 2) / totalButtons))
        for i, btn in ipairs(viewButtons) do
            btn:SetSize(per, buttonHeight)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", Recollect, "TOPLEFT", 10 + (i - 1) * (per + 2), -60)
            if btn.updateState then pcall(btn.updateState) end
        end
    end

    -- Refresh display to recalc progress bar widths
    UpdateDisplay()
end

-- Create modern rows
local rows = {}
local maxRows = 50

for i = 1, maxRows do
    local row = CreateFrame("Frame", nil, content, "BackdropTemplate")
    row:SetHeight(26)
    row:SetPoint("TOPLEFT", 5, -(i-1) * 28)
    row:SetPoint("RIGHT", -5, 0)
    
    row:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeSize = 0
    })
    
    -- Expand/collapse button (positioned on the left)
    local expandBtn = CreateFrame("Button", nil, row)
    expandBtn:SetSize(16, 16)
    expandBtn:SetPoint("LEFT", 2, 0)
    expandBtn:SetNormalTexture("Interface/Buttons/UI-PlusButton-Up")
    expandBtn:SetPushedTexture("Interface/Buttons/UI-PlusButton-Down")
    expandBtn:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
    expandBtn:Hide()
    
    -- Class icon
    local classIcon = row:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(18, 18)
    classIcon:SetPoint("LEFT", 22, 0)
    
    -- Progress bar with gradient
    local progressBar = row:CreateTexture(nil, "BACKGROUND")
    progressBar:SetPoint("LEFT", 45, 0)
    progressBar:SetHeight(22)
    progressBar:SetTexture("Interface/TargetingFrame/UI-StatusBar")
    
    -- Bar overlay
    local progressOverlay = row:CreateTexture(nil, "BORDER")
    progressOverlay:SetAllPoints(progressBar)
    progressOverlay:SetTexture("Interface/RaidFrame/Raid-Bar-Hp-Fill")
    progressOverlay:SetBlendMode("ADD")
    progressOverlay:SetAlpha(0.3)
    
    -- Player text
    local playerText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    playerText:SetPoint("LEFT", 50, 0)
    playerText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    playerText:SetShadowOffset(1, -1)
    
    -- Value text
    local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueText:SetPoint("RIGHT", -5, 0)
    valueText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    valueText:SetShadowOffset(1, -1)
    
    -- Position number
    local posText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    posText:SetPoint("RIGHT", -5, 8)
    posText:SetFont("Fonts/FRIZQT__.TTF", 9, "OUTLINE")
    posText:SetTextColor(0.6, 0.6, 0.6)
    
    row.progressBar = progressBar
    row.progressOverlay = progressOverlay
    row.classIcon = classIcon
    row.playerText = playerText
    row.valueText = valueText
    row.posText = posText
    row.expandBtn = expandBtn
    row.isExpanded = false
    
    rows[i] = row
end

-- Class colors and icons
local CLASS_DATA = {
    WARRIOR = {color = {0.78, 0.61, 0.43}, icon = "Interface/Icons/ClassIcon_Warrior"},
    PALADIN = {color = {0.96, 0.55, 0.73}, icon = "Interface/Icons/ClassIcon_Paladin"},
    HUNTER = {color = {0.67, 0.83, 0.45}, icon = "Interface/Icons/ClassIcon_Hunter"},
    ROGUE = {color = {1.00, 0.96, 0.41}, icon = "Interface/Icons/ClassIcon_Rogue"},
    PRIEST = {color = {1.00, 1.00, 1.00}, icon = "Interface/Icons/ClassIcon_Priest"},
    SHAMAN = {color = {0.00, 0.44, 0.87}, icon = "Interface/Icons/ClassIcon_Shaman"},
    MAGE = {color = {0.41, 0.80, 0.94}, icon = "Interface/Icons/ClassIcon_Mage"},
    WARLOCK = {color = {0.58, 0.51, 0.79}, icon = "Interface/Icons/ClassIcon_Warlock"},
    MONK = {color = {0.00, 1.00, 0.59}, icon = "Interface/Icons/ClassIcon_Monk"},
    DRUID = {color = {1.00, 0.49, 0.04}, icon = "Interface/Icons/ClassIcon_Druid"},
    DEMONHUNTER = {color = {0.64, 0.19, 0.79}, icon = "Interface/Icons/ClassIcon_DemonHunter"},
    DEATHKNIGHT = {color = {0.77, 0.12, 0.23}, icon = "Interface/Icons/ClassIcon_DeathKnight"},
    EVOKER = {color = {0.25, 0.70, 1.00}, icon = "Interface/Icons/ClassIcon_Evoker"}
}

-- Enhanced pet icons by specific names and types
local PET_ICONS = {
    -- Hunter pets
    Pet = "Interface/Icons/Ability_Hunter_Pet_Bear",
    -- Warlock demons
    Imp = "Interface/Icons/Spell_Shadow_SummonImp",
    Voidwalker = "Interface/Icons/Spell_Shadow_SummonVoidWalker",
    Succubus = "Interface/Icons/Spell_Shadow_SummonSuccubus",
    Felhunter = "Interface/Icons/Spell_Shadow_SummonFelHunter",
    Felguard = "Interface/Icons/Spell_Shadow_SummonFelGuard",
    Demon = "Interface/Icons/Spell_Shadow_SummonImp",
    -- Shaman totems and elementals
    Elemental = "Interface/Icons/Spell_Fire_Elemental_Totem",
    -- Death Knight minions
    Ghoul = "Interface/Icons/Spell_Shadow_RaiseDead",
    Gargoyle = "Interface/Icons/Ability_Hunter_Pet_Bat",
    Undead = "Interface/Icons/Spell_Shadow_RaiseDead",
    -- General
    Guardian = "Interface/Icons/Spell_Nature_SpiritWolf",
    Minion = "Interface/Icons/Spell_Shadow_SummonImp"
}

-- Initialize debug function
local DebugPrint = function() end
function ResetData()
    wipe(data)
    wipe(expandedPlayers)
    wipe(playerClassCache) -- Añadido para limpiar cache
    inCombat = false
    combatStart = 0
    UpdateDisplay()
    print("|cFF00D4FF[Recollect]|r |cFF88FF88Data cleared|r")
end


function GetPlayerValue(playerData, viewType)
    if viewType == "DPS" then return playerData.dps or 0
    elseif viewType == "DAMAGE" then return playerData.damage or 0
    elseif viewType == "DAMAGE_TAKEN" then return playerData.damageTaken or 0
    elseif viewType == "HEALING_DONE" then return playerData.healingDone or 0
    elseif viewType == "HEALING_TAKEN" then return playerData.healingTaken or 0 end
    return 0
end

function FormatNumber(num)
    if num >= 1000000 then return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then return string.format("%.1fK", num / 1000)
    else return string.format("%.0f", num) end
end

-- Enhanced pet detection with specific pet naming
function GetPlayerPets(playerName)
    local pets = {}
    local petCounter = {}
    
    for dataName, petData in pairs(data) do
        local petType, owner, petName = string.match(dataName, "^(%w+):([^:]+):(.+)$")
        if owner == playerName and petType then
            -- Count pets of same type for numbering
            if not petCounter[petType] then
                petCounter[petType] = 0
            end
            petCounter[petType] = petCounter[petType] + 1
            
            -- Determine icon based on pet name or type
            local petIcon = PET_ICONS[petName] or PET_ICONS[petType] or PET_ICONS.Pet
            
            table.insert(pets, {
                name = petName,
                type = petType,
                dataKey = dataName,
                data = petData,
                icon = petIcon,
                number = petCounter[petType]
            })
        end
    end
    
    -- Sort pets by damage/value
    table.sort(pets, function(a, b)
        local valueA = GetPlayerValue(a.data, currentView)
        local valueB = GetPlayerValue(b.data, currentView)
        return valueA > valueB
    end)
    
    return pets
end

function UpdateDisplay()
    -- Combat info
    local combatTime = inCombat and (GetTime() - combatStart) or 0
    if combatTime > 0 then
        combatInfo:SetText(string.format("|cFF88FF88In Combat|r - Time: %d:%02d", math.floor(combatTime / 60), combatTime % 60))
    else
        combatInfo:SetText("|cFFFF8888Out of Combat|r")
    end

    -- Hide all rows
    for i = 1, maxRows do
        if rows[i] then
            rows[i]:Hide()
            rows[i].isExpanded = false
        end
    end

    -- Build and sort main players
    local sortedData = {}
    for name, playerData in pairs(data) do
        if not string.find(name, ":") then
            local value = GetPlayerValue(playerData, currentView)
            if value and value > 0 then
                table.insert(sortedData, { name = name, value = value, data = playerData })
            end
        end
    end

    table.sort(sortedData, function(a, b)
        if sortDescending then return a.value > b.value else return a.value < b.value end
    end)

    -- Find max value (include pets)
    local maxValue = 0
    for _, entry in ipairs(sortedData) do
        if entry.value > maxValue then maxValue = entry.value end
        local pets = GetPlayerPets(entry.name)
        for _, pet in ipairs(pets) do
            local pv = GetPlayerValue(pet.data, currentView)
            if pv and pv > maxValue then maxValue = pv end
        end
    end

    -- Display rows
    local rowIndex = 1
    local frameWidth = scrollFrame and scrollFrame:GetWidth() or 300

    for i, entry in ipairs(sortedData) do
        if rowIndex > maxRows then break end
        local row = rows[rowIndex]
        if not row then break end

        local playerData = entry.data
        local classKey = playerData.class or GetPlayerClass(entry.name)
        if classKey == "UNKNOWN" then classKey = nil end
        local classData = CLASS_DATA[classKey] or { color = {0.8,0.8,0.8}, icon = nil }
        local classColor = classData.color or {0.8,0.8,0.8}

        -- Row visuals
        row:SetBackdropColor((classColor[1] or 0.8) * 0.15, (classColor[2] or 0.8) * 0.15, (classColor[3] or 0.8) * 0.15, 0.7)
        -- Only set or show a class icon when we have a valid one; otherwise hide it to avoid the question-mark
        if classData.icon and classData.icon ~= "" then
            row.classIcon:SetTexture(classData.icon)
            row.classIcon:SetVertexColor(1,1,1,1)
            row.classIcon:Show()
        else
            row.classIcon:Hide()
        end

        row.playerText:SetText(entry.name)
        row.playerText:SetTextColor(classColor[1] or 0.8, classColor[2] or 0.8, classColor[3] or 0.8)
        row.valueText:SetText(FormatNumber(entry.value))
        row.valueText:SetTextColor(1, 1, 0.8)
        row.posText:SetText("#" .. i)

        local barMaxWidth = math.max(frameWidth - 100, 10)
        local barWidth = maxValue > 0 and (entry.value / maxValue) * barMaxWidth or 1
        row.progressBar:SetWidth(math.max(barWidth, 1))
        row.progressBar:SetVertexColor((classColor[1] or 0.8) * 0.8, (classColor[2] or 0.8) * 0.8, (classColor[3] or 0.8) * 0.8, 0.6)

        -- Pets expand button
        local pets = GetPlayerPets(entry.name)
        if #pets > 0 then
            row.expandBtn:Show()
            if expandedPlayers[entry.name] then
                row.expandBtn:SetNormalTexture("Interface/Buttons/UI-MinusButton-Up")
                row.expandBtn:SetPushedTexture("Interface/Buttons/UI-MinusButton-Down")
            else
                row.expandBtn:SetNormalTexture("Interface/Buttons/UI-PlusButton-Up")
                row.expandBtn:SetPushedTexture("Interface/Buttons/UI-PlusButton-Down")
            end
            row.expandBtn:SetScript("OnClick", function()
                expandedPlayers[entry.name] = not expandedPlayers[entry.name]
                UpdateDisplay()
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end)
        else
            row.expandBtn:Hide()
        end

        row:Show()
        rowIndex = rowIndex + 1

        -- Show pets if expanded
        if #pets > 0 and expandedPlayers[entry.name] then
            for _, pet in ipairs(pets) do
                if rowIndex > maxRows then break end
                local petRow = rows[rowIndex]
                if not petRow then break end

                local petValue = GetPlayerValue(pet.data, currentView) or 0
                petRow:SetBackdropColor(0.1, 0.1, 0.15, 0.5)
                petRow.classIcon:SetTexture(pet.icon or "Interface/Icons/INV_Misc_QuestionMark")
                petRow.classIcon:SetVertexColor(0.8, 0.8, 0.8, 1)

                local petDisplayName = pet.number and pet.number > 1 and string.format("    └ %s %d: %s", pet.type, pet.number, pet.name)
                                               or string.format("    └ %s: %s", pet.type, pet.name)
                petRow.playerText:SetText(petDisplayName)
                petRow.playerText:SetTextColor(0.8, 0.8, 0.9)
                petRow.valueText:SetText(FormatNumber(petValue))
                petRow.valueText:SetTextColor(0.9, 0.9, 1)
                petRow.posText:SetText("")

                local petBarMax = math.max(frameWidth - 120, 10)
                local petBarWidth = maxValue > 0 and (petValue / maxValue) * petBarMax or 1
                petRow.progressBar:SetWidth(math.max(petBarWidth, 1))
                petRow.progressBar:SetVertexColor(0.4, 0.4, 0.6, 0.5)

                petRow.expandBtn:Hide()
                petRow:Show()
                rowIndex = rowIndex + 1
            end
        end
    end
end

-- Utility functions
local function IsInMyGroup(unitName)
    if UnitIsUnit(unitName, "player") then return true end
    for i = 1, 40 do
        local name = UnitName("raid" .. i)
        if name == unitName then return true end
    end
    for i = 1, 4 do
        local name = UnitName("party" .. i)
        if name == unitName then return true end
    end
    return false
end

-- Enhanced pet owner detection with specific pet identification
local function GetOwnerName(unitGUID, unitName, flags)
    -- Check if it's a pet/guardian
    if bit.band(flags, COMBATLOG_OBJECT_TYPE_PET) > 0 or bit.band(flags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0 then
        -- Try to find owner by checking all group members
        if IsInRaid() then
            for i = 1, GetNumGroupMembers() do
                local memberName = GetRaidRosterInfo(i)
                if memberName then
                    -- Check for regular pets
                    local petName = UnitName(memberName .. "pet")
                    if petName == unitName then
                        return memberName, "Pet"
                    end
                    
                    -- Check for additional pets (hunter can have multiple)
                    for j = 1, 5 do
                        local additionalPet = UnitName(memberName .. "pet" .. j)
                        if additionalPet == unitName then
                            return memberName, "Pet"
                        end
                    end
                end
            end
        else
            for i = 0, GetNumSubgroupMembers() do
                local unit = i == 0 and "player" or "party" .. i
                local memberName = UnitName(unit)
                if memberName then
                    local petName = UnitName(unit .. "pet")
                    if petName == unitName then
                        return memberName, "Pet"
                    end
                    
                    -- Check for multiple pets
                    for j = 1, 5 do
                        local additionalPet = UnitName(unit .. "pet" .. j)
                        if additionalPet == unitName then
                            return memberName, "Pet"
                        end
                    end
                end
            end
        end
    end
    
    -- Enhanced pet type detection by name patterns and class
    local foundOwner = nil
    local petType = "Pet"
    
    -- Warlock demons - check by name patterns
    local warlockDemons = {
        ["Imp"] = "Imp",
        ["Voidwalker"] = "Voidwalker", 
        ["Succubus"] = "Succubus",
        ["Felhunter"] = "Felhunter",
        ["Felguard"] = "Felguard"
    }
    
    for demonName, demonType in pairs(warlockDemons) do
        if string.find(unitName, demonName) then
            petType = demonType
            break
        end
    end
    
    -- Death Knight minions
    if string.find(unitName, "Ghoul") then
        petType = "Ghoul"
    elseif string.find(unitName, "Gargoyle") then
        petType = "Gargoyle"
    end
    
    -- Shaman totems and elementals
    if string.find(unitName, "Totem") or string.find(unitName, "Elemental") then
        petType = "Elemental"
    end
    
    -- Find owner by class for specific pet types
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local memberName = GetRaidRosterInfo(i)
            if memberName then
                local _, class = UnitClass(memberName)
                if class == "WARLOCK" and (petType == "Imp" or petType == "Voidwalker" or petType == "Succubus" or petType == "Felhunter" or petType == "Felguard") then
                    foundOwner = memberName
                    break
                elseif class == "SHAMAN" and petType == "Elemental" then
                    foundOwner = memberName
                    break
                elseif class == "DEATHKNIGHT" and (petType == "Ghoul" or petType == "Gargoyle") then
                    foundOwner = memberName
                    break
                elseif class == "HUNTER" and petType == "Pet" then
                    foundOwner = memberName
                    break
                end
            end
        end
    else
        for i = 0, GetNumSubgroupMembers() do
            local unit = i == 0 and "player" or "party" .. i
            local memberName = UnitName(unit)
            if memberName then
                local _, class = UnitClass(memberName)
                if class == "WARLOCK" and (petType == "Imp" or petType == "Voidwalker" or petType == "Succubus" or petType == "Felhunter" or petType == "Felguard") then
                    foundOwner = memberName
                    break
                elseif class == "SHAMAN" and petType == "Elemental" then
                    foundOwner = memberName
                    break
                elseif class == "DEATHKNIGHT" and (petType == "Ghoul" or petType == "Gargoyle") then
                    foundOwner = memberName
                    break
                elseif class == "HUNTER" and petType == "Pet" then
                    foundOwner = memberName
                    break
                end
            end
        end
    end

    return foundOwner, petType
end

-- Función mejorada para inicializar datos de jugador usando cache
local function InitializePlayerData(name)
    if not data[name] then
        local class = GetPlayerClass(name)
        -- Don't store the literal "UNKNOWN" class; use nil so UI can fallback gracefully
        if class == "UNKNOWN" then
            class = nil
        end
        data[name] = {
            damage = 0, dps = 0, damageTaken = 0,
            healingDone = 0, healingTaken = 0,
            class = class
        }
    end
end

-- Función mejorada para obtener la clase de un jugador
function GetPlayerClass(unitName)
    if not unitName then return "UNKNOWN" end
    if playerClassCache[unitName] ~= nil then
        return playerClassCache[unitName]
    end

    local function Normalize(name)
        if not name then return nil end
        return name:match("^[^-]+")
    end
    local norm = Normalize(unitName)
    local class

    -- Check player
    if Normalize(UnitName("player")) == norm then
        _, class = UnitClass("player")
    else
        -- Check party
        for i = 1, GetNumSubgroupMembers() do
            local unit = "party"..i
            if Normalize(UnitName(unit)) == norm then
                _, class = UnitClass(unit)
                break
            end
        end
        -- Check raid if still not found
        if not class and IsInRaid() then
            for i = 1, GetNumGroupMembers() do
                local unit = "raid"..i
                if Normalize(UnitName(unit)) == norm then
                    _, class = UnitClass(unit)
                    break
                end
            end
        end
    end

    -- If still not found, mark UNKNOWN (do NOT default to WARRIOR)
    class = class or "UNKNOWN"
    playerClassCache[unitName] = class
    return class
end

-- Función para actualizar clases de jugadores existentes
local function UpdatePlayerClasses()
    for name in pairs(data) do
        local c = GetPlayerClass(name)
        if c == "UNKNOWN" then c = nil end
        data[name].class = c
    end
end

-- Event handler para actualizar clases cuando sea necesario
local function OnGroupRosterUpdate()
    UpdatePlayerClasses()
end




-- Event handler with improved pet detection and size constraints
Recollect:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
Recollect:RegisterEvent("PLAYER_REGEN_DISABLED")
Recollect:RegisterEvent("PLAYER_REGEN_ENABLED")
Recollect:RegisterEvent("ADDON_LOADED")
Recollect:RegisterEvent("GROUP_ROSTER_UPDATE")
Recollect:RegisterEvent("RAID_ROSTER_UPDATE")

Recollect:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == ADDON_NAME then
        UpdateScrollFrameSize()
    elseif event == "PLAYER_REGEN_DISABLED" then
        if not inCombat then
            inCombat = true
            combatStart = GetTime()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    elseif event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" then
        wipe(playerClassCache) -- <--- Añade esto para limpiar el cache
        UpdatePlayerClasses()
        UpdateDisplay()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
              destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
        -- Solo procesar eventos de daño y sanación
        if not subevent:find("_DAMAGE") and not subevent:find("_HEAL") then
            return
        end
        -- Obtener los argumentos específicos según el tipo de evento
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
        if subevent:find("_DAMAGE") then
            spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, CombatLogGetCurrentEventInfo())
        elseif subevent:find("_HEAL") then
            spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = select(12, CombatLogGetCurrentEventInfo())
        end
        -- Verificar que amount sea un número válido
        if not amount or type(amount) ~= "number" or amount <= 0 then 
            return 
        end
        -- === PROCESAMIENTO DE DAÑO HECHO ===
        if sourceName and subevent:find("_DAMAGE") then
            local ownerName = sourceName
            local petKey = nil
            local petType = nil
            -- Enhanced pet detection para el que hace daño
            if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0 or bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0 then
                local realOwner, detectedPetType = GetOwnerName(sourceGUID, sourceName, sourceFlags)
                if realOwner and IsInMyGroup(realOwner) then
                    ownerName = realOwner
                    petType = detectedPetType or "Pet"
                    petKey = petType .. ":" .. realOwner .. ":" .. sourceName
                else
                    -- Pet de alguien que no está en el grupo
                    ownerName = nil
                end
            elseif not IsInMyGroup(sourceName) then
                -- Check if it's a demon/elemental/undead minion
                local foundOwner, detectedPetType = GetOwnerName(sourceGUID, sourceName, sourceFlags)
                if foundOwner then
                    ownerName = foundOwner
                    petType = detectedPetType
                    petKey = petType .. ":" .. foundOwner .. ":" .. sourceName
                else
                    -- No está en nuestro grupo
                    ownerName = nil
                end
            end
            -- Solo procesar daño hecho si el atacante está en nuestro grupo
            if ownerName and IsInMyGroup(ownerName) then
                InitializePlayerData(ownerName)
                if petKey then InitializePlayerData(petKey) end
                data[ownerName].damage = data[ownerName].damage + amount
                if petKey then 
                    data[petKey].damage = (data[petKey].damage or 0) + amount
                    data[petKey].class = petType
                end
                local elapsed = inCombat and (GetTime() - combatStart) or 0
                if elapsed > 0 then
                    data[ownerName].dps = data[ownerName].damage / elapsed
                    if petKey then data[petKey].dps = (data[petKey].damage or 0) / elapsed end
                end
            end
            -- === PROCESAMIENTO DE DAÑO RECIBIDO ===
            -- SIEMPRE verificar si el destino está en nuestro grupo (independiente del atacante)
            if destName and IsInMyGroup(destName) then
                InitializePlayerData(destName)
                data[destName].damageTaken = data[destName].damageTaken + amount
                -- Debug: mostrar daño recibido si el debug está activo
                DebugPrint(destName .. " recibió " .. amount .. " de daño de " .. (sourceName or "Unknown"))
            end
        -- === PROCESAMIENTO DE SANACIÓN ===
        elseif sourceName and subevent:find("_HEAL") then
            local ownerName = sourceName
            local petKey = nil
            local petType = nil
            -- Enhanced pet detection para el que sana
            if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0 or bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0 then
                local realOwner, detectedPetType = GetOwnerName(sourceGUID, sourceName, sourceFlags)
                if realOwner and IsInMyGroup(realOwner) then
                    ownerName = realOwner
                    petType = detectedPetType or "Pet"
                    petKey = petType .. ":" .. realOwner .. ":" .. sourceName
                else
                    ownerName = nil
                end
            elseif not IsInMyGroup(sourceName) then
                local foundOwner, detectedPetType = GetOwnerName(sourceGUID, sourceName, sourceFlags)
                if foundOwner then
                    ownerName = foundOwner
                    petType = detectedPetType
                    petKey = petType .. ":" .. foundOwner .. ":" .. sourceName
                else
                    ownerName = nil
                end
            end
            -- Solo procesar sanación hecha si el sanador está en nuestro grupo
            if ownerName and IsInMyGroup(ownerName) then
                InitializePlayerData(ownerName)
                if petKey then InitializePlayerData(petKey) end
                data[ownerName].healingDone = data[ownerName].healingDone + amount
                if petKey then 
                    data[petKey].healingDone = (data[petKey].healingDone or 0) + amount
                    data[petKey].class = petType
                end
            end
            -- === PROCESAMIENTO DE SANACIÓN RECIBIDA ===
            -- SIEMPRE verificar si el destino está en nuestro grupo
            if destName and IsInMyGroup(destName) then
                InitializePlayerData(destName)
                data[destName].healingTaken = data[destName].healingTaken + amount
                -- Debug: mostrar sanación recibida si el debug está activo
                DebugPrint(destName .. " recibió " .. amount .. " de sanación de " .. (sourceName or "Unknown"))
            end
        end
        UpdateDisplay()
    end
end)

-- Función mejorada para verificar si alguien está en nuestro grupo
local function IsInMyGroup(unitName)
    if not unitName then return false end
    
    -- Verificar si es el jugador
    if UnitIsUnit("player", unitName) or UnitName("player") == unitName then 
        return true 
    end
    
    -- Verificar en raid
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local name = GetRaidRosterInfo(i)
            if name == unitName then return true end
        end
    else
        -- Verificar en party
        for i = 1, GetNumSubgroupMembers() do
            local name = UnitName("party" .. i)
            if name == unitName then return true end
        end
    end
    
    return false
end

-- Agregar comando de debug mejorado para verificar el daño recibido
SLASH_RECOLLECT1 = "/recollect"
SLASH_RECOLLECT2 = "/rec"
SlashCmdList["RECOLLECT"] = function(msg)
    msg = msg:lower()
    if msg == "show" then 
        Recollect:Show()
    elseif msg == "hide" then 
        Recollect:Hide()
    elseif msg == "reset" then 
        ResetData()
    elseif msg == "debug" then
        -- Toggle debug mode
        if DebugPrint == print then
            DebugPrint = function() end
            print("|cFF00D4FF[Recollect]|r Debug disabled")
        else
            DebugPrint = function(msg) print("|cFF00D4FF[Recollect Debug]|r " .. msg) end
            print("|cFF00D4FF[Recollect]|r Debug enabled")
        end
    elseif msg == "damage" then
        -- Mostrar estadísticas de daño recibido
        print("|cFF00D4FF[Recollect]|r Daño recibido por miembros del grupo:")
        local found = false
        for name, playerData in pairs(data) do
            if not string.find(name, ":") and playerData.damageTaken and playerData.damageTaken > 0 then
                print("  " .. name .. ": " .. FormatNumber(playerData.damageTaken) .. " daño recibido")
                found = true
            end
        end
        if not found then
            print("  No se ha registrado daño recibido aún.")
        end
    elseif msg == "test" then
        -- Test para verificar el grupo actual
        print("|cFF00D4FF[Recollect]|r Miembros del grupo actual:")
        print("  Jugador: " .. UnitName("player"))
        
        if IsInRaid() then
            print("  En Raid (" .. GetNumGroupMembers() .. " miembros):")
            for i = 1, GetNumGroupMembers() do
                local name = GetRaidRosterInfo(i)
                if name then
                    print("    " .. i .. ". " .. name)
                end
            end
        else
            print("  En Party (" .. (GetNumSubgroupMembers() + 1) .. " miembros):")
            for i = 1, GetNumSubgroupMembers() do
                local name = UnitName("party" .. i)
                if name then
                    print("    " .. (i+1) .. ". " .. name)
                end
            end
        end
    elseif msg == "pets" then
        -- Show current pet data organized by owner with enhanced info
        print("|cFF00D4FF[Recollect]|r Current pet data:")
        for name, playerData in pairs(data) do
            if not string.find(name, ":") then
                local pets = GetPlayerPets(name)
                if #pets > 0 then
                    local _, class = UnitClass(name)
                    print("  " .. name .. " (" .. (class or "Unknown") .. ") - " .. #pets .. " pets:")
                    for i, pet in ipairs(pets) do
                        local petValue = GetPlayerValue(pet.data, "DAMAGE")
                        print("    " .. i .. ". " .. pet.type .. ": " .. pet.name .. " - Damage: " .. FormatNumber(petValue))
                    end
                end
            end
        end
    elseif msg == "expand" then
        -- Expand all players with pets
        for name, playerData in pairs(data) do
            if not string.find(name, ":") then
                local pets = GetPlayerPets(name)
                if #pets > 0 then
                    expandedPlayers[name] = true
                end
            end
        end
        UpdateDisplay()
        print("|cFF00D4FF[Recollect]|r Expanded all players with pets")
    elseif msg == "collapse" then
        -- Collapse all players
        wipe(expandedPlayers)
        UpdateDisplay()
        print("|cFF00D4FF[Recollect]|r Collapsed all players")
    elseif msg == "size" then
        -- Show current size and limits
        local width, height = Recollect:GetSize()
        print("|cFF00D4FF[Recollect]|r Current size: " .. math.floor(width) .. "x" .. math.floor(height))
        print("  Size limits: " .. MIN_WIDTH .. "x" .. MIN_HEIGHT .. " to " .. MAX_WIDTH .. "x" .. MAX_HEIGHT)
    elseif msg == "resize" then
        -- Reset to default size
        Recollect:SetSize(380, 520)
        UpdateScrollFrameSize()
        print("|cFF00D4FF[Recollect]|r Reset to default size (380x520)")
    else
        print("|cFF00D4FF[Recollect]|r Commands:")
        print("  /rec show/hide - Show/hide the window")
        print("  /rec reset - Clear all data")
        print("  /rec debug - Toggle debug mode")
        print("  /rec damage - Show damage taken stats")
        print("  /rec test - Show current group members")
        print("  /rec pets - Show pet information")
        print("  /rec expand/collapse - Expand/collapse all pets")
        print("  /rec size - Show current window size")
        print("  /rec resize - Reset to default size")
        print("|cFFFFFF00Features:|r")
        print("  • Click +/- buttons to expand/collapse pet damage")
        print("  • Pets are automatically numbered by type")
        print("  • Supports Hunter pets, Warlock demons, DK minions, Shaman elementals")
        print("|cFFFFFF00Resize:|r Drag the grip in bottom-right corner")
        print("|cFFFFFF00Move:|r Drag the window (not while holding Shift)")
    end
end