local ADDON_NAME, namespace = ...
local L = namespace.L

local QuestGroupsByName = {}
local buttonPool = CreateFramePool("Button", QuestMapFrame.QuestsFrame, "UIPanelButtonTemplate")

-- Slugify zone name
local function Slug(value)
    return value:lower():gsub('[^a-z]', '')
end

-- Create abandon button near zone headers
local function PlaceButton(parent, offset, title, tooltip, slug)
    title = title or parent:GetText()
    tooltip = tooltip or title
    slug = slug or Slug(title)
    if QuestGroupsByName[slug] then
        local button = buttonPool:Acquire()
        button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", offset, 0)
        button:SetText("X")
        button:SetSize(24, 24)
        button.title = title
        button.tooltip = tooltip
        button.slug = slug
        button:SetScript("OnClick", function(self)
            local dialog = StaticPopup_Show("AAQ_ZONE_CONFIRM", self.title)
            if dialog then
                dialog.data = self.slug
            end
        end)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self)
            GameTooltip:SetText(string.format(L.ABANDON_DIALOG_ZONE, self.title))
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        button:Show()
    end
end

-- Show buttons for all headers
local function ButtonsShow()
    buttonPool:ReleaseAll()
    for header in QuestScrollFrame.headerFramePool:EnumerateActive() do
        PlaceButton(header, 240)
    end
    for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
        PlaceButton(header.Text, 15)
    end
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
local globalButton = CreateFrame("Button", "AbandonAllQuest_MainButton", QuestScrollFrame.Contents, "UIPanelButtonTemplate")
globalButton:SetText(L.MAP_BUTTON_LABEL)
globalButton:SetSize(200, 26)
globalButton:SetPoint("BOTTOM", 0, -40)
globalButton:SetScript("OnClick", function()
    StaticPopup_Show("AAQ_ALL_CONFIRM")
end)
globalButton:Show()

-- Slash command
SLASH_ABANDONALLQUEST1 = "/abandonzone"
SlashCmdList["ABANDONALLQUEST"] = function(zone)
    local slug = Slug(zone)
    if slug == "help" or zone == "" then
        print(L.SLASH_HELP)
    elseif not QuestGroupsByName[slug] then
        print(string.format(L.ZONE_NOT_FOUND, zone))
    else
        AbandonQuests(slug)
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
        FillQuestGroups()
    else
        FillQuestGroups()
    end
end)

QuestMapFrame:HookScript("OnShow", ButtonsShow)
QuestMapFrame:HookScript("OnHide", function() buttonPool:ReleaseAll() end)
