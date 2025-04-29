-- Database to store kills
local MobCounterDB = {
    personal = { kills = 0 },
    group = {},  -- Will store {playerName = kills} for each member
    total = 0,   -- Total kill counter for the group
    windowSize = { width = 220, height = 250 } -- Saved window size
}

-- Colors for messages
local COLOR_PREFIX = "|cFF00FF00MobCounter:|r "

-- Function to get group type (solo, group, raid)
local function GetGroupType()
    if IsInRaid() then
        return "raid", GetNumGroupMembers()
    elseif IsInGroup() then
        return "party", GetNumGroupMembers()
    else
        return "solo", 1
    end
end

-- Function to check if a GUID belongs to a group member
local function IsGroupMemberGUID(guid)
    -- Always check player first
    if guid == UnitGUID("player") then
        return true, UnitName("player")
    end
    
    -- Check group/raid members
    local groupType, numMembers = GetGroupType()
    if groupType ~= "solo" then
        for i = 1, numMembers do
            local unit = groupType .. i
            if guid == UnitGUID(unit) then
                return true, UnitName(unit)
            end
        end
    end
    
    return false, nil
end

-- Function to recalculate the group's total kills
local function RecalculateTotal()
    -- Initialize with personal kills
    local total = MobCounterDB.personal.kills
    
    -- Add all kills from other group members
    for name, kills in pairs(MobCounterDB.group) do
        total = total + kills
    end
    
    -- Update the value in the database
    MobCounterDB.total = total
    
    -- Update the text in the UI if it exists
    if MobCounterFrameTotalText then
        MobCounterFrameTotalText:SetText("Group Total: " .. total)
    end
    
    return total
end

-- Function to update the members table
local function UpdateGroupTable()
    local frame = MobCounterFrame
    if not frame then return end
    
    -- Clear existing table
    if frame.groupContainer then
        frame.groupContainer:Hide()
        frame.groupContainer:SetParent(nil)
        frame.groupContainer = nil
    end
    
    -- Create container for the group table
    local container = CreateFrame("Frame", nil, frame)
    container:SetSize(frame:GetWidth() - 20, 150)
    container:SetPoint("TOP", MobCounterFramePersonalText, "BOTTOM", 0, -10)
    frame.groupContainer = container
    
    -- Create members table sorted by kills
    local sortedMembers = {}
    local groupType, numMembers = GetGroupType()
    
    -- Add yourself first
    local playerName = UnitName("player")
    sortedMembers[1] = {
        name = playerName,
        kills = MobCounterDB.personal.kills
    }
    
    -- Add other group members if we're in a group/raid
    if groupType ~= "solo" then
        for i = 1, numMembers do
            local unit = groupType .. i
            local name = UnitName(unit)
            if name and name ~= playerName then
                -- If it doesn't exist in the DB, initialize it
                if not MobCounterDB.group[name] then
                    MobCounterDB.group[name] = 0
                end
                
                table.insert(sortedMembers, {
                    name = name,
                    kills = MobCounterDB.group[name]
                })
            end
        end
    end
    
    -- Sort by number of kills (highest to lowest)
    table.sort(sortedMembers, function(a, b) return a.kills > b.kills end)
    
    -- Create title label - MOVED DOWN A BIT
    local titleText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("TOP", container, "TOP", 0, -10) -- Moved down 10 pixels
    titleText:SetText("Members by Kills")
    titleText:SetTextColor(1, 0.82, 0) -- Gold
    
    -- Create entries for each member - ALSO MOVED DOWN
    for i, member in ipairs(sortedMembers) do
        local entry = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        entry:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -30 - (i-1)*15) -- Moved down to -30 from -20
        
        -- Color for the player (yourself)
        local nameColor = "|cFFFFFFFF"
        if member.name == playerName then
            nameColor = "|cFF00FF00"
        end
        
        entry:SetText(i .. ". " .. nameColor .. member.name .. "|r: " .. member.kills)
        entry:SetJustifyH("LEFT")
    end
    
    -- Recalculate the total after updating the list
    RecalculateTotal()
    
    -- Adjust the size of the main frame if not being manually resized
    if not frame.isResizing then
        local newHeight = math.max(150, 150 + (15 * #sortedMembers))
        frame:SetHeight(newHeight)
        -- Save the new size in the DB
        MobCounterDB.windowSize.height = newHeight
    end
end

-- Function to handle combat events
local function MobCounter_OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()
        
        -- Monitor all death events
        if subevent == "UNIT_DIED" or subevent == "PARTY_KILL" then
            -- Check GUIDs of all group members by comparing with sourceGUID
            local isGroupMember, memberName = IsGroupMemberGUID(sourceGUID)
            
            if isGroupMember then
                -- If it's the player
                if sourceGUID == UnitGUID("player") then
                    MobCounterDB.personal.kills = MobCounterDB.personal.kills + 1
                    
                    -- Update the personal counter in the interface
                    if MobCounterFramePersonalText then
                        MobCounterFramePersonalText:SetText("Your kills: " .. MobCounterDB.personal.kills)
                    end
                else
                    -- If it's another group member
                    if not MobCounterDB.group[memberName] then
                        MobCounterDB.group[memberName] = 0
                    end
                    
                    MobCounterDB.group[memberName] = MobCounterDB.group[memberName] + 1
                end
                
                -- Update group table and recalculate the total
                UpdateGroupTable()
            end
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        -- Update the table when the group composition changes
        UpdateGroupTable()
    end
end

-- Function to initialize the main UI
local function InitializeMainUI()
    -- Create a main window with simple background
    local f = CreateFrame("Frame", "MobCounterFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    f:SetSize(MobCounterDB.windowSize.width, MobCounterDB.windowSize.height) -- Use saved size
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetMovable(true) -- Make the main frame movable
    f:SetResizable(true) -- FIXED: Make the frame resizable
    
    -- Set size limits
    if f.SetResizeBounds then
        -- For modern WoW versions
        f:SetResizeBounds(180, 100, 400, 600)
    else
        -- For classic WoW versions
        f:SetMinResize(180, 100)
        f:SetMaxResize(400, 600)
    end
    
    -- Configure a simple background
    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
        tile = true, 
        tileSize = 16, 
        edgeSize = 16, 
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.8) -- Semi-transparent black background
    f:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Gray border
    
    -- Create a title bar
    local titleBar = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate")
    titleBar:SetHeight(25)
    titleBar:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    titleBar:SetBackdropColor(0.1, 0.1, 0.1, 1) -- Darker background
    
    -- Addon title
    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    title:SetText("MobCounter")
    title:SetTextColor(1, 0.82, 0) -- Gold
    
    -- Close button integrated in the title bar
    local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeButton:SetSize(20, 20)
    closeButton:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", -2, -2)
    closeButton:SetScript("OnClick", function() f:Hide() end)
    
    -- Make the window movable via the title bar
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() f:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
    
    -- Create texts to display kill count
    -- Personal count
    local personalText = f:CreateFontString("MobCounterFramePersonalText", "OVERLAY")
    personalText:SetFontObject("GameFontNormal")
    personalText:SetPoint("TOP", titleBar, "BOTTOM", 0, -10)
    personalText:SetText("Your kills: " .. MobCounterDB.personal.kills)
    personalText:SetTextColor(0, 1, 0) -- Green
    
    -- Group total count
    local totalText = f:CreateFontString("MobCounterFrameTotalText", "OVERLAY")
    totalText:SetFontObject("GameFontNormal")
    totalText:SetPoint("TOP", personalText, "BOTTOM", 0, -5)
    totalText:SetText("Group Total: 0") -- Will be updated with RecalculateTotal
    totalText:SetTextColor(1, 1, 1) -- White
    
    -- Add a reset button (position below the text)
    local resetButton = CreateFrame("Button", "MobCounterResetButton", f, "UIPanelButtonTemplate")
    resetButton:SetSize(80, 20)
    resetButton:SetPoint("BOTTOM", f, "BOTTOM", 0, 10)
    resetButton:SetText("Reset")
    resetButton:SetScript("OnClick", function()
        MobCounterDB.personal.kills = 0
        MobCounterDB.group = {}
        MobCounterDB.total = 0
        MobCounterFramePersonalText:SetText("Your kills: 0")
        MobCounterFrameTotalText:SetText("Group Total: 0")
        UpdateGroupTable()
    end)
    
    -- FIXED: Resize button
    local resizeButton = CreateFrame("Button", nil, f)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    
    -- Correct resize functionality
    resizeButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            f.isResizing = true
            f:StartSizing("BOTTOMRIGHT")
        end
    end)
    
    resizeButton:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
        f:StopMovingOrSizing()
            
            -- Ensure the size is not smaller than the desired minimum or larger than the maximum
            local width, height = f:GetSize()
            
            -- Save the new size in the DB
            MobCounterDB.windowSize.width = width
            MobCounterDB.windowSize.height = height
            
            -- Update the table after resizing
            UpdateGroupTable()
            f.isResizing = false
        end
    end)
    
    -- Initialize the group table
    UpdateGroupTable()
    
    -- Show the window by default
    f:Show()
    
    return f
end

-- Function to create slash commands
local function CreateSlashCommands()
    SLASH_MOBCOUNTER1 = "/mobcounter"
    SLASH_MOBCOUNTER2 = "/mc"
    
    SlashCmdList["MOBCOUNTER"] = function(msg)
        msg = msg:lower()
        
        if msg == "show" then
            if MobCounterFrame then
                MobCounterFrame:Show()
            else
                InitializeMainUI()
            end
        elseif msg == "hide" then
            if MobCounterFrame then
                MobCounterFrame:Hide()
            end
        elseif msg == "reset" then
            MobCounterDB.personal.kills = 0
            MobCounterDB.group = {}
            MobCounterDB.total = 0
            
            if MobCounterFramePersonalText then
                MobCounterFramePersonalText:SetText("Your kills: 0")
            end
            
            if MobCounterFrameTotalText then
                MobCounterFrameTotalText:SetText("Group Total: 0")
            end
            
            UpdateGroupTable()
        else
            print(COLOR_PREFIX .. "Available commands:")
            print(COLOR_PREFIX .. "/mc show - Show window")
            print(COLOR_PREFIX .. "/mc hide - Hide window")
            print(COLOR_PREFIX .. "/mc reset - Reset counters")
        end
    end
end

-- Create the main frame to handle events
local MobCounterFrame = CreateFrame("Frame")
MobCounterFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
MobCounterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
MobCounterFrame:SetScript("OnEvent", MobCounter_OnEvent)

-- Initialize the addon
local function InitializeAddon()
    -- Create the slash commands
    CreateSlashCommands()
    
    -- Create the user interface
    InitializeMainUI()
end

-- Initialize when the player enters the world
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        InitializeAddon()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)