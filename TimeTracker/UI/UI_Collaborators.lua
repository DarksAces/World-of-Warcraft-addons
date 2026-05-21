local addonName, private = ...

-- Collaborators Panel Logic
function private.UpdateCollaboratorsPanel(frame)
    local panel = frame.collaboratorsPanel
    if not panel then return end

    local content = panel.content
    local yOffset = -15

    -- Clear/Reuse logic
    panel.collabMiscFS = panel.collabMiscFS or {}
    for _, fs in ipairs(panel.collabMiscFS) do fs:Hide() end
    local miscFSIndex = 0
    local function GetMiscCollabFS()
        miscFSIndex = miscFSIndex + 1
        return private.CreateOrReuseFontString(panel.collabMiscFS, content, miscFSIndex, "GameFontHighlight")
    end

    -- Header
    local h = GetMiscCollabFS()
    h:SetFontObject("GameFontNormalLarge")
    h:SetPoint("TOPLEFT", 15, yOffset)
    h:SetText(private.GetLocalizedText("COLLABORATORS_TITLE"))
    h:SetTextColor(0, 0.8, 1)
    yOffset = yOffset - 25

    -- Description
    local desc = GetMiscCollabFS()
    desc:SetFontObject("GameFontHighlight")
    desc:SetPoint("TOPLEFT", 15, yOffset)
    desc:SetText(private.GetLocalizedText("COLLABORATORS_DESC"))
    desc:SetTextColor(0.9, 0.9, 0.9)
    yOffset = yOffset - 45

    -- Card data setup
    local cardsData = {
        {
            name = private.GetLocalizedText("COLLABORATOR_AUTHOR"),
            role = private.GetLocalizedText("COLLABORATOR_AUTHOR_DESC"),
            desc = "Addon Creator & Lead Developer",
            icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
            color = {0, 0.8, 1}, -- cyan
        },
        {
            name = private.GetLocalizedText("COLLABORATOR_RU"),
            role = private.GetLocalizedText("COLLABORATOR_RU_DESC"),
            desc = "Russian Translation",
            icon = "Interface\\Icons\\INV_Misc_Book_09",
            color = {1, 0.8, 0}, -- gold
        },
        {
            name = private.GetLocalizedText("COLLABORATOR_JOIN_TITLE"),
            role = private.GetLocalizedText("COLLABORATOR_JOIN_DESC"),
            desc = "github.com/DarksAces/World-of-Warcraft-addons",
            icon = "Interface\\Icons\\INV_Misc_QuestionMark",
            color = {0, 1, 0.5}, -- green-ish
            isInteractive = true,
        }
    }

    if not panel.cards then
        panel.cards = {}
    end

    for i, data in ipairs(cardsData) do
        local card = panel.cards[i]
        if not card then
            card = CreateFrame("Button", nil, content, "BackdropTemplate")
            card:SetSize(780, 80)
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
            card.iconContainer:SetSize(56, 56)
            card.iconContainer:SetPoint("LEFT", 15, 0)
            card.iconContainer:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
            card.iconContainer:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.5)

            card.icon = card.iconContainer:CreateTexture(nil, "ARTWORK")
            card.icon:SetAllPoints()
            card.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

            -- Labels
            card.name = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            card.name:SetPoint("TOPLEFT", 85, -15)
            card.name:SetJustifyH("LEFT")

            card.role = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            card.role:SetPoint("TOPLEFT", 85, -36)
            card.role:SetJustifyH("LEFT")

            card.desc = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            card.desc:SetPoint("TOPLEFT", 85, -53)
            card.desc:SetTextColor(0.5, 0.5, 0.5)
            card.desc:SetJustifyH("LEFT")

            panel.cards[i] = card
        end

        card:SetPoint("TOPLEFT", content, "TOPLEFT", 15, yOffset)
        card:Show()

        card.icon:SetTexture(data.icon)
        card.name:SetText(data.name)
        card.name:SetTextColor(unpack(data.color))
        card.role:SetText(data.role)
        card.desc:SetText(data.desc)

        -- Styling interactive vs static cards
        if data.isInteractive then
            card:SetBackdropColor(0.08, 0.12, 0.1, 0.6)
            card:SetBackdropBorderColor(0, 0.8, 0.4, 0.3)
            card:EnableMouse(true)
            card:SetScript("OnClick", function()
                local link = "https://github.com/DarksAces/World-of-Warcraft-addons/tree/main/TimeTracker"
                local chatEditBox = ChatEdit_ChooseBoxForSend()
                if chatEditBox and not chatEditBox:IsVisible() then
                    ChatFrame_OpenChat(link)
                elseif chatEditBox then
                    chatEditBox:Insert(link)
                else
                    print("|cff00ccffTime Tracker:|r " .. link)
                end
            end)
            card:SetScript("OnEnter", function(self)
                card:SetBackdropColor(0.12, 0.18, 0.15, 0.8)
                card:SetBackdropBorderColor(0, 1, 0.5, 0.6)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(private.GetLocalizedText("COLLABORATOR_JOIN_TITLE"), 1, 1, 1)
                
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
            card:SetBackdropColor(0.06, 0.06, 0.08, 0.6)
            card:SetBackdropBorderColor(1, 1, 1, 0.1)
            card:EnableMouse(false)
            card:SetScript("OnClick", nil)
            card:SetScript("OnEnter", nil)
            card:SetScript("OnLeave", nil)
        end

        yOffset = yOffset - 90
    end

    content:SetHeight(math.max(450, math.abs(yOffset) + 20))
end
