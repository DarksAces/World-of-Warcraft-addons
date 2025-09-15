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

    local improved = uptimePercent > records.bestUptime

    if totalCombatTime > records.longestCombat then
        records.longestCombat = totalCombatTime
    end
    if uptimePercent > records.bestUptime then
        records.bestUptime = uptimePercent
    end

    ShowUI(totalCombatTime, timeWithoutDamage, uptimePercent, improved)
end

-- Eventos
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

f:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
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
SlashCmdList["MICROMETRICS"] = function()
    local uptimePercent = math.floor(((records.longestCombat - records.bestUptime) / (records.longestCombat > 0 and records.longestCombat or 1)) * 100)
    ShowUI(records.longestCombat, 0, records.bestUptime, true)
end
