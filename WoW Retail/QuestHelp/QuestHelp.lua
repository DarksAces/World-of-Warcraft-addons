-- Better Quest Help
local ADDON, ns = ...
local BQH = {}
_G.BetterQuestHelp = BQH

------------------------------------------------------------------------
-- Utilidades de QuestID (Retail + Classic)
------------------------------------------------------------------------

local function SafeGetQuestIDFromLogIndex(index)
    if not index then return nil end

    -- Retail moderno
    if C_QuestLog and C_QuestLog.GetInfo then
        local info = C_QuestLog.GetInfo(index)
        if info and info.questID then
            return info.questID
        end
    end

    -- Classic: parsear link "quest:12345:"
    if GetQuestLink then
        local link = GetQuestLink(index)
        if link then
            local id = link:match("quest:(%d+)")
            if id then return tonumber(id) end
        end
    end

    -- Classic detalle abierto
    if GetQuestID then
        local qid = GetQuestID()
        if qid and qid > 0 then return qid end
    end

    return nil
end

local function SafeGetSelectedQuestLogIndex()
    if C_QuestLog and C_QuestLog.GetSelectedQuest then
        -- Retail: devuelve questID, no índice
        local qid = C_QuestLog.GetSelectedQuest()
        if qid and C_QuestLog.GetLogIndexForQuestID then
            return C_QuestLog.GetLogIndexForQuestID(qid), qid
        end
        return nil, qid
    end
    if GetQuestLogSelection then
        local idx = GetQuestLogSelection()
        return idx, SafeGetQuestIDFromLogIndex(idx)
    end
    return nil, nil
end

local function GetQuestID_Selected()
    local idx, qid = SafeGetSelectedQuestLogIndex()
    if qid then return qid end
    if idx then return SafeGetQuestIDFromLogIndex(idx) end
    return nil
end

------------------------------------------------------------------------
-- Generar y mostrar URL de Wowhead
------------------------------------------------------------------------

local function WowheadQuestURL(questID, localeTag)
    -- Wowhead locales: en, es, es.classic usan dominios/caminos distintos.
    -- Por simplicidad: https://www.wowhead.com/quest=ID funciona globalmente en Retail.
    -- Para Classic, muchos usan https://www.wowhead.com/classic/quest=ID
    -- Detectamos si el cliente es Classic con WOW_PROJECT_ID.
    local isClassic = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC or _G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC or _G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC)
    if isClassic then
        return ("https://www.wowhead.com/classic/quest=%d"):format(questID)
    else
        return ("https://www.wowhead.com/quest=%d"):format(questID)
    end
end

-- Popup con EditBox para copiar fácil
StaticPopupDialogs["BQH_COPY_URL"] = {
    text = "Copiar enlace de Wowhead",
    button1 = OKAY,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    hasEditBox = true,
    preferredIndex = 3,
    OnShow = function(self, data)
        local box = self.editBox or self.EditBox
        if not box then return end
        box:SetText(data or "")
        box:HighlightText()
        box:SetFocus()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    OnAccept = function(self) end,
}


local function ShowWowheadLink(questID, silent)
    if not questID then
        if not silent then
            print("|cffff5555[BQH]|r No se pudo determinar el QuestID.")
        end
        return
    end

    local url = WowheadQuestURL(questID)
    -- Mostrar en chat
    print(("|cff00ff88[BQH]|r Wowhead link: |cff00ccff%s|r"):format(url))

    -- Popup para copiar
    StaticPopup_Show("BQH_COPY_URL", nil, nil, url)
end

------------------------------------------------------------------------
-- Botón “ Help” en el panel de detalles del Quest Log
------------------------------------------------------------------------

local function CreateHelpButton_Retail()
    if not QuestMapFrame or not QuestMapFrame.DetailsFrame then return end
    if BQH.DetailsButton then return end

    local parent = QuestMapFrame.DetailsFrame
    local btn = CreateFrame("Button", "BQH_DetailsHelpButton", parent, "UIPanelButtonTemplate")
    btn:SetSize(70, 20)
    btn:SetText("Help")
    -- Colocamos arriba a la derecha del panel de detalles
    btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, -14)

    btn:SetScript("OnClick", function()
        local qid = GetQuestID_Selected()
        ShowWowheadLink(qid)
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Abrir enlace de Wowhead", 1, 1, 1)
        GameTooltip:AddLine("Usa /qh para más opciones.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    BQH.DetailsButton = btn
end

local function CreateHelpButton_ClassicQuestFrame()
    -- Algunos Classic usan QuestFrame (ventana grande de NPC)
    if not QuestFrame or not QuestFrameDetailPanel then return end
    if BQH.QuestFrameButton then return end

    local parent = QuestFrameDetailPanel
    local btn = CreateFrame("Button", "BQH_QuestFrameHelpButton", parent, "UIPanelButtonTemplate")
    btn:SetSize(90, 22)
    btn:SetText("Help")
    btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -30, -30)

    btn:SetScript("OnClick", function()
        local qid = GetQuestID() or GetQuestID_Selected()
        ShowWowheadLink(qid)
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Abrir enlace de Wowhead", 1, 1, 1)
        GameTooltip:AddLine("Desde el panel de misión del NPC.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    BQH.QuestFrameButton = btn
end


SLASH_BETTERQUESTHELP1 = "/qh"
SLASH_BETTERQUESTHELP2 = "/questhelp"
SlashCmdList["BETTERQUESTHELP"] = function(msg)
    msg = msg and msg:match("^%s*(.-)%s*$") or ""
    if msg == "" then
        -- Usar misión seleccionada en el Quest Log
        local qid = GetQuestID_Selected()
        if qid then
            ShowWowheadLink(qid)
        else
            print("|cffff5555[BQH]|r Usa: /qh <QuestID> o selecciona una misión en el Quest Log.")
        end
        return
    end

    -- /qh 12345
    local num = tonumber(msg)
    if num then
        ShowWowheadLink(num)
        return
    end

    -- /qh find 10 flores (buscar por nombre en el log y usar la primera coincidencia)
    local cmd, rest = msg:match("^(%S+)%s+(.+)$")
    if cmd and cmd:lower() == "find" and rest and rest ~= "" then
        local matchedQID = nil
        if C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
            local numEntries = C_QuestLog.GetNumQuestLogEntries()
            for i = 1, numEntries do
                local info = C_QuestLog.GetInfo(i)
                if info and not info.isHeader and info.title and info.title:lower():find(rest:lower(), 1, true) then
                    matchedQID = info.questID
                    break
                end
            end
        else
            -- Classic: iterar títulos
            local numEntries = GetNumQuestLogEntries and GetNumQuestLogEntries() or 0
            for i = 1, numEntries do
                local title, _, _, _, _, isComplete, _, _, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(i)
                if title and title:lower():find(rest:lower(), 1, true) then
                    matchedQID = SafeGetQuestIDFromLogIndex(i)
                    break
                end
            end
        end

        if matchedQID then
            ShowWowheadLink(matchedQID)
        else
            print("|cffff5555[BQH]|r No encontré una misión en tu log que coincida con: " .. rest)
        end
        return
    end

    -- Ayuda
    print("|cff00ff88[BQH]|r Uso:")
    print("  /qh                 -> Link de la misión seleccionada")
    print("  /qh 12345           -> Link por QuestID")
    print("  /qh find <texto>    -> Busca por nombre en tu Quest Log")
end

------------------------------------------------------------------------
-- Inicialización
------------------------------------------------------------------------

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    -- Botón en Detalles (Retail)
    C_Timer.After(1, function()
        pcall(CreateHelpButton_Retail)
        pcall(CreateHelpButton_ClassicQuestFrame)
        -- Si quieres intentar los botones por título (experimental), descomenta:
        -- hooksecurefunc("QuestMapFrame_UpdateAll", TryAttachButtonsToQuestTitles)
    end)

    print("|cff00ff88[BQH]|r Cargado. Usa /qh o el botón 'Help' en el Quest Log.")
end)
