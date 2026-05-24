local addonName = ...
local L = _G.MicroMetrics_Locale or {}

-- Variables de seguimiento
local combatStartTime = 0
local lastDamageTime = 0
local timeWithoutDamage = 0
local totalCombatTime = 0
local inCombat = false

-- Referencia a SavedVariables
MicroMetricsDB = MicroMetricsDB or { longestCombat = 0, bestUptime = 0 }

local records = MicroMetricsDB

-- Frame para eventos y UI
local f = CreateFrame("Frame")

-- Variables UI
local uiFrame

local function CreateUI()
    if uiFrame then return end -- Solo una vez

    uiFrame = CreateFrame("Frame", "MicroMetricsUIFrame", UIParent, "BackdropTemplate")
    uiFrame:SetSize(220, 100)
    uiFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
    uiFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    uiFrame:SetBackdropColor(0, 0, 0, 0.7)
    uiFrame:SetMovable(true)
    uiFrame:EnableMouse(true)

    uiFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and IsShiftKeyDown() then
            self:StartMoving()
        end
    end)
    uiFrame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)

    uiFrame.title = uiFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    uiFrame.title:SetPoint("TOP", 0, -10)
    uiFrame.title:SetText("MicroMetrics")

    uiFrame.stat1 = uiFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    uiFrame.stat1:SetPoint("TOPLEFT", 15, -30)

    uiFrame.stat2 = uiFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    uiFrame.stat2:SetPoint("TOPLEFT", 15, -45)

    uiFrame.stat3 = uiFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    uiFrame.stat3:SetPoint("TOPLEFT", 15, -60)

    uiFrame:Hide()
end

local function ShowUI(totalTime, noDamageTime, uptimePercent, improved)
    CreateUI()

    uiFrame.stat1:SetFormattedText(L["Duration"]:format(totalTime))
    uiFrame.stat2:SetFormattedText(L["NoDamage"]:format(noDamageTime))
    uiFrame.stat3:SetFormattedText("%s %s", L["Uptime"]:format(uptimePercent), improved and L["Improved"] or L["Worse"])

    uiFrame:Show()
    uiFrame:SetAlpha(1)

    uiFrame.fadeTimer = 5
    uiFrame:SetScript("OnUpdate", function(self, elapsed)
        self.fadeTimer = self.fadeTimer - elapsed
        if self.fadeTimer <= 0 then
            local alpha = self:GetAlpha() - 0.05
            if alpha <= 0 then
                self:Hide()
                self:SetScript("OnUpdate", nil)
                self.fadeTimer = nil
            else
                self:SetAlpha(alpha)
            end
        end
    end)
end

local function PrintStats()
    local uptimePercent = 100
    if totalCombatTime > 0 then
        local activeTime = totalCombatTime - timeWithoutDamage
        uptimePercent = math.floor((activeTime / totalCombatTime) * 100)
    end

    local improved = uptimePercent > (records and records.bestUptime or 0)

    if records then
        if totalCombatTime > records.longestCombat then
            records.longestCombat = totalCombatTime
        end
        if uptimePercent > records.bestUptime then
            records.bestUptime = uptimePercent
        end
    end

    if MicroMetricsDB and MicroMetricsDB.showOnCombatEnd == nil then MicroMetricsDB.showOnCombatEnd = true end
    if MicroMetricsDB and MicroMetricsDB.showOnCombatEnd then
        ShowUI(totalCombatTime, timeWithoutDamage, uptimePercent, improved)
    end
end

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
                print("|cff00ccffMicroMetrics:|r " .. link)
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

local MicroMetricsOptionsFrame
local MicroMetricsOptionsCategory

local function CreateOptionsPanel()
    local optionsFrame = CreateFrame("Frame", "MicroMetricsOptionsPanel", UIParent)
    optionsFrame.name = "MicroMetrics"
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
    title:SetText("MicroMetrics")
    
    local desc = generalPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", 10, -35)
    desc:SetText(GetText("OPTIONS_TITLE") or "Opciones de configuración")
    desc:SetTextColor(0.8, 0.8, 0.8)
    
    -- Checkbox: Show on combat end
    local showOnCombatEndBtn = CreateFrame("CheckButton", nil, generalPanel, "ChatConfigCheckButtonTemplate")
    showOnCombatEndBtn:SetPoint("TOPLEFT", 10, -70)
    local cbText = showOnCombatEndBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cbText:SetPoint("LEFT", showOnCombatEndBtn, "RIGHT", 5, 0)
    cbText:SetText(GetText("SHOW_ON_COMBAT_END"))
    showOnCombatEndBtn:SetChecked(MicroMetricsDB.showOnCombatEnd)
    showOnCombatEndBtn:SetScript("OnClick", function(self)
        MicroMetricsDB.showOnCombatEnd = self:GetChecked()
    end)
    
    -- Button: Reset Records
    local resetBtn = CreateFrame("Button", nil, generalPanel, "UIPanelButtonTemplate")
    resetBtn:SetPoint("TOPLEFT", 10, -110)
    resetBtn:SetSize(150, 25)
    resetBtn:SetText(GetText("RESET_RECORDS"))
    
    -- Confirm popup dialog
    StaticPopupDialogs["MICROMETRICS_RESET_CONFIRM"] = {
        text = GetText("RESET_RECORDS_CONFIRM"),
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            MicroMetricsDB.longestCombat = 0
            MicroMetricsDB.bestUptime = 0
            print(GetText("RECORDS_RESET_SUCCESS"))
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("MICROMETRICS_RESET_CONFIRM")
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
            link = "https://github.com/DarksAces/World-of-Warcraft-addons/tree/main/MicroMetrics",
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
        MicroMetricsOptionsCategory = Settings.RegisterCanvasLayoutCategory(optionsFrame, optionsFrame.name)
        Settings.RegisterAddOnCategory(MicroMetricsOptionsCategory)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(optionsFrame)
    end
    
    MicroMetricsOptionsFrame = optionsFrame
end

-- Eventos
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

f:SetScript("OnEvent", function(_, event, ...)
    local arg1 = ...
    if event == "ADDON_LOADED" and arg1 == addonName then
        MicroMetricsDB = MicroMetricsDB or { longestCombat = 0, bestUptime = 0, showOnCombatEnd = true }
        if MicroMetricsDB.showOnCombatEnd == nil then MicroMetricsDB.showOnCombatEnd = true end
        records = MicroMetricsDB
        CreateOptionsPanel()
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
        combatStartTime = GetTime()
        lastDamageTime = combatStartTime
        timeWithoutDamage = 0
    elseif event == "PLAYER_REGEN_ENABLED" and inCombat then
        inCombat = false
        local combatEndTime = GetTime()
        totalCombatTime = combatEndTime - combatStartTime
        timeWithoutDamage = combatEndTime - lastDamageTime
        PrintStats()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and inCombat then
        local _, subEvent, _, sourceGUID = CombatLogGetCurrentEventInfo()
        if sourceGUID == UnitGUID("player") and subEvent:find("DAMAGE") then
            lastDamageTime = GetTime()
        end
    end
end)

-- Comando para mostrar los récords actuales manualmente
SLASH_MICROMETRICS1 = "/micrometrics"
SlashCmdList["MICROMETRICS"] = function(msg)
    local command = string.lower(strtrim(msg or ""))
    if command == "config" or command == "options" or command == "opciones" then
        if Settings and Settings.OpenToCategory then
            if MicroMetricsOptionsCategory then
                Settings.OpenToCategory(MicroMetricsOptionsCategory:GetID())
            end
        elseif InterfaceOptionsFrame_OpenToCategory then
            if MicroMetricsOptionsFrame then
                InterfaceOptionsFrame_OpenToCategory(MicroMetricsOptionsFrame)
            end
        end
    else
        local longest = records and records.longestCombat or 0
        local best = records and records.bestUptime or 0
        ShowUI(longest, 0, best, true)
    end
end
