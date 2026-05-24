local ADDON_NAME, namespace = ...
local L = namespace.L

local QuestGroupsByName = {}


-- Slugify zone name
local function Slug(value)
    return value:lower():gsub('[^a-z]', '')
end



-- Abandon quests by group
local function AbandonQuests(slug)
    local group = QuestGroupsByName[slug] or {}
    for questId, title in pairs(group.quests or {}) do
        print(string.format("|cFFFFFF00" .. L.ABANDON_QUEST_SUCCESS .. "|r", title))
        C_QuestLog.SetSelectedQuest(questId)
        C_QuestLog.SetAbandonQuest()
        C_QuestLog.AbandonQuest()
    end
    QuestGroupsByName[slug] = nil
end

-- Build quest groups
local function FillQuestGroups()
    local all = { quests = {} }
    QuestGroupsByName = { all = all }
    local currentGroup
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        if info.isHeader then
            currentGroup = { title = info.title, quests = {} }
            QuestGroupsByName[Slug(info.title)] = currentGroup
        elseif currentGroup then
            currentGroup.quests[info.questID] = info.title
            all.quests[info.questID] = info.title
        end
    end
end

-- Popup for abandoning a zone
StaticPopupDialogs["AAQ_ZONE_CONFIRM"] = {
    text = L.ABANDON_DIALOG_ZONE,
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, data)
        AbandonQuests(data)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- Popup for abandoning all
StaticPopupDialogs["AAQ_ALL_CONFIRM"] = {
    text = L.ABANDON_DIALOG_ALL,
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)
            if not info.isHeader and not info.isHidden then
                print(string.format("|cFFFFFF00" .. L.ABANDON_QUEST_SUCCESS .. "|r", info.title))
                C_QuestLog.SetSelectedQuest(info.questID)
                C_QuestLog.SetAbandonQuest()
                C_QuestLog.AbandonQuest()
            end
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- Create main button to abandon all quests
local globalButton = CreateFrame("Button", "AbandonAllQuest_MainButton", QuestMapFrame.QuestsFrame, "UIPanelButtonTemplate")
globalButton:SetText(L.MAP_BUTTON_LABEL)
globalButton:SetSize(200, 26)
globalButton:SetPoint("BOTTOM", 0, 10)
globalButton:SetScript("OnClick", function()
    StaticPopup_Show("AAQ_ALL_CONFIRM")
end)
globalButton:Show()

-- UI Options Panel and Tabs Helpers
local function CreateTabButton(parent, text, width)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, 28)
    btn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
    })
    btn:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
    btn:SetBackdropBorderColor(1, 1, 1, 0.1)
    
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.text:SetPoint("CENTER", 0, 1)
    btn.text:SetText(text)
    btn.text:SetScale(0.95)
    
    btn:SetScript("OnEnter", function(self)
        if not self.selected then
            self:SetBackdropColor(0.15, 0.15, 0.2, 1)
            self:SetBackdropBorderColor(1, 1, 1, 0.3)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if not self.selected then
            self:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
            self:SetBackdropBorderColor(1, 1, 1, 0.1)
        end
    end)
    return btn
end

local function CreateCollabCard(parent, data, yOffset)
    local card = CreateFrame("Button", nil, parent, "BackdropTemplate")
    card:SetSize(580, 70)
    card:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, yOffset)
    card:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    card:SetBackdropColor(0.06, 0.06, 0.08, 0.6)
    card:SetBackdropBorderColor(1, 1, 1, 0.1)

    -- Icon Container
    card.iconContainer = CreateFrame("Frame", nil, card, "BackdropTemplate")
    card.iconContainer:SetSize(46, 46)
    card.iconContainer:SetPoint("LEFT", 12, 0)
    card.iconContainer:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    card.iconContainer:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.5)

    card.icon = card.iconContainer:CreateTexture(nil, "ARTWORK")
    card.icon:SetAllPoints()
    card.icon:SetTexture(data.icon)
    card.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Labels
    card.name = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    card.name:SetPoint("TOPLEFT", 70, -10)
    card.name:SetJustifyH("LEFT")
    card.name:SetText(data.name)
    card.name:SetTextColor(unpack(data.color))

    card.role = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    card.role:SetPoint("TOPLEFT", 70, -28)
    card.role:SetJustifyH("LEFT")
    card.role:SetText(data.role)
    card.role:SetScale(0.95)

    card.desc = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    card.desc:SetPoint("TOPLEFT", 70, -43)
    card.desc:SetTextColor(0.5, 0.5, 0.5)
    card.desc:SetJustifyH("LEFT")
    card.desc:SetText(data.desc)

    -- Styling interactive vs static cards
    if data.isInteractive then
        card:SetBackdropColor(0.08, 0.12, 0.1, 0.6)
        card:SetBackdropBorderColor(0, 0.8, 0.4, 0.3)
        card:EnableMouse(true)
        card:SetScript("OnClick", function()
            local link = data.link
            local chatEditBox = ChatEdit_ChooseBoxForSend()
            if chatEditBox and not chatEditBox:IsVisible() then
                ChatFrame_OpenChat(link)
            elseif chatEditBox then
                chatEditBox:Insert(link)
            else
                print("|cff00ccffAbandonAllQuest:|r " .. link)
            end
        end)
        card:SetScript("OnEnter", function(self)
            card:SetBackdropColor(0.12, 0.18, 0.15, 0.8)
            card:SetBackdropBorderColor(0, 1, 0.5, 0.6)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(data.name, 1, 1, 1)
            
            local tooltipHelp = "Haz clic para copiar el enlace en el chat"
            if GetLocale() == "ruRU" then
                tooltipHelp = "Нажмите, чтобы скопировать ссылку в чат"
            elseif GetLocale() ~= "esES" and GetLocale() ~= "esMX" then
                tooltipHelp = "Click to copy the link into chat"
            end
            GameTooltip:AddLine(tooltipHelp, 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end)
        card:SetScript("OnLeave", function(self)
            card:SetBackdropColor(0.08, 0.12, 0.1, 0.6)
            card:SetBackdropBorderColor(0, 0.8, 0.4, 0.3)
            GameTooltip:Hide()
        end)
    else
        card:EnableMouse(false)
    end
    
    return card
end

local AbandonAllQuestOptionsFrame
local AbandonAllQuestOptionsCategory

local function UpdateMapButtonVisibility()
    if AbandonAllQuestDB and AbandonAllQuestDB.showMapButton then
        globalButton:Show()
    else
        globalButton:Hide()
    end
end

local function CreateOptionsPanel()
    local optionsFrame = CreateFrame("Frame", "AbandonAllQuestOptionsPanel", UIParent)
    optionsFrame.name = "AbandonAllQuest"
    optionsFrame:Hide()
    
    local function GetText(key)
        return L[key] or key
    end

    -- Tab layout
    local tabGeneral = CreateTabButton(optionsFrame, GetText("OPTIONS_TITLE") or "Opciones", 120)
    tabGeneral:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 15, -15)
    optionsFrame.tabGeneral = tabGeneral
    
    local tabCollaborators = CreateTabButton(optionsFrame, GetText("COLLABORATORS_TAB") or "Colaboradores", 120)
    tabCollaborators:SetPoint("LEFT", tabGeneral, "RIGHT", 5, 0)
    optionsFrame.tabCollaborators = tabCollaborators
    
    -- Sub-panels
    local generalPanel = CreateFrame("Frame", nil, optionsFrame)
    generalPanel:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 15, -55)
    generalPanel:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT", -15, 15)
    optionsFrame.generalPanel = generalPanel
    
    local collaboratorsPanel = CreateFrame("Frame", nil, optionsFrame)
    collaboratorsPanel:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 15, -55)
    collaboratorsPanel:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT", -15, 15)
    collaboratorsPanel:Hide()
    optionsFrame.collaboratorsPanel = collaboratorsPanel
    
    -- generalPanel Content
    local title = generalPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("AbandonAllQuest")
    
    local desc = generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", 10, -35)
    desc:SetText(GetText("OPTIONS_TITLE") or "Opciones de configuración")
    desc:SetTextColor(0.8, 0.8, 0.8)
    
    -- Checkbox: Show map button
    local showMapButtonBtn = CreateFrame("CheckButton", nil, generalPanel, "ChatConfigCheckButtonTemplate")
    showMapButtonBtn:SetPoint("TOPLEFT", 10, -70)
    local cbText = showMapButtonBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cbText:SetPoint("LEFT", showMapButtonBtn, "RIGHT", 5, 0)
    cbText:SetText(GetText("SHOW_MAP_BUTTON"))
    showMapButtonBtn:SetChecked(AbandonAllQuestDB.showMapButton)
    showMapButtonBtn:SetScript("OnClick", function(self)
        AbandonAllQuestDB.showMapButton = self:GetChecked()
        UpdateMapButtonVisibility()
    end)
    
    -- collaboratorsPanel Content
    local collabTitle = collaboratorsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    collabTitle:SetPoint("TOPLEFT", 10, -10)
    collabTitle:SetText(GetText("COLLABORATORS_TITLE"))
    collabTitle:SetTextColor(0, 0.8, 1)
    
    local collabDesc = collaboratorsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    collabDesc:SetPoint("TOPLEFT", 10, -35)
    collabDesc:SetText(GetText("COLLABORATORS_DESC"))
    collabDesc:SetTextColor(0.9, 0.9, 0.9)
    collabDesc:SetWidth(580)
    collabDesc:SetJustifyH("LEFT")
    
    local cardsData = {
        {
            name = GetText("COLLABORATOR_AUTHOR"),
            role = GetText("COLLABORATOR_AUTHOR_DESC"),
            desc = "Addon Creator & Lead Developer",
            icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
            color = {0, 0.8, 1},
        },
        {
            name = GetText("COLLABORATOR_RU"),
            role = GetText("COLLABORATOR_RU_DESC"),
            desc = "Russian Translation",
            icon = "Interface\\Icons\\INV_Misc_Book_09",
            color = {1, 0.8, 0},
        },
        {
            name = GetText("COLLABORATOR_JOIN_TITLE"),
            role = GetText("COLLABORATOR_JOIN_DESC"),
            desc = "github.com/DarksAces/World-of-Warcraft-addons",
            icon = "Interface\\Icons\\INV_Misc_QuestionMark",
            color = {0, 1, 0.5},
            isInteractive = true,
            link = "https://github.com/DarksAces/World-of-Warcraft-addons/tree/main/AbandonAllQuest",
        }
    }
    
    local yOffset = -70
    for _, cData in ipairs(cardsData) do
        CreateCollabCard(collaboratorsPanel, cData, yOffset)
        yOffset = yOffset - 80
    end
    
    local function ShowTab(id)
        optionsFrame.tabGeneral.selected = (id == "General")
        optionsFrame.tabCollaborators.selected = (id == "Collaborators")
        
        if optionsFrame.tabGeneral.selected then
            optionsFrame.tabGeneral:SetBackdropColor(0, 0.5, 0.8, 1)
            optionsFrame.tabGeneral:SetBackdropBorderColor(0, 1, 1, 1)
            optionsFrame.tabGeneral.text:SetTextColor(1, 1, 1)
        else
            optionsFrame.tabGeneral:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
            optionsFrame.tabGeneral:SetBackdropBorderColor(1, 1, 1, 0.1)
            optionsFrame.tabGeneral.text:SetTextColor(0.8, 0.8, 0.8)
        end
        
        if optionsFrame.tabCollaborators.selected then
            optionsFrame.tabCollaborators:SetBackdropColor(0, 0.5, 0.8, 1)
            optionsFrame.tabCollaborators:SetBackdropBorderColor(0, 1, 1, 1)
            optionsFrame.tabCollaborators.text:SetTextColor(1, 1, 1)
        else
            optionsFrame.tabCollaborators:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
            optionsFrame.tabCollaborators:SetBackdropBorderColor(1, 1, 1, 0.1)
            optionsFrame.tabCollaborators.text:SetTextColor(0.8, 0.8, 0.8)
        end
        
        if id == "General" then
            optionsFrame.generalPanel:Show()
            optionsFrame.collaboratorsPanel:Hide()
        else
            optionsFrame.generalPanel:Hide()
            optionsFrame.collaboratorsPanel:Show()
        end
    end

    -- Tab scripts
    tabGeneral:SetScript("OnClick", function() ShowTab("General") end)
    tabCollaborators:SetScript("OnClick", function() ShowTab("Collaborators") end)
    
    -- Select first tab initially
    ShowTab("General")
    
    -- Register options frame in Blizzard Options
    if Settings and Settings.RegisterCanvasLayoutCategory then
        AbandonAllQuestOptionsCategory = Settings.RegisterCanvasLayoutCategory(optionsFrame, optionsFrame.name)
        Settings.RegisterAddOnCategory(AbandonAllQuestOptionsCategory)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(optionsFrame)
    end
    
    AbandonAllQuestOptionsFrame = optionsFrame
end

-- Slash command
SLASH_ABANDONALLQUEST1 = "/abandonzone"
SlashCmdList["ABANDONALLQUEST"] = function(zone)
    local command = string.lower(strtrim(zone or ""))
    if command == "config" or command == "options" or command == "opciones" then
        if Settings and Settings.OpenToCategory then
            if AbandonAllQuestOptionsCategory then
                Settings.OpenToCategory(AbandonAllQuestOptionsCategory:GetID())
            end
        elseif InterfaceOptionsFrame_OpenToCategory then
            if AbandonAllQuestOptionsFrame then
                InterfaceOptionsFrame_OpenToCategory(AbandonAllQuestOptionsFrame)
            end
        end
    else
        local slug = Slug(zone)
        if slug == "help" or zone == "" then
            print(L.SLASH_HELP)
        elseif not QuestGroupsByName[slug] then
            print(string.format(L.ZONE_NOT_FOUND, zone))
        else
            AbandonQuests(slug)
        end
    end
end

-- Event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("QUEST_REMOVED")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        AbandonAllQuestDB = AbandonAllQuestDB or { showMapButton = true }
        if AbandonAllQuestDB.showMapButton == nil then AbandonAllQuestDB.showMapButton = true end
        FillQuestGroups()
        UpdateMapButtonVisibility()
        CreateOptionsPanel()
    else
        FillQuestGroups()
    end
end)


