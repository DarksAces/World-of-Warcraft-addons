-- ==========================================================
-- CooldownAbilityAlert v1.2 - Monitoreo de cooldowns con alerta visual
-- ==========================================================

CooldownAbilityAlert_Saved = CooldownAbilityAlert_Saved or {}
local activeCooldowns = {}
local frame = CreateFrame("Frame")

-- ==========================================================
-- Funciones auxiliares
-- ==========================================================
local function GetSpellInfoCompat(spellID)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then return info.name end
    elseif GetSpellInfo then
        return GetSpellInfo(spellID)
    end
    return nil
end

local function GetCooldown(spellID)
    local start, duration, enabled
    if C_Spell and C_Spell.GetSpellCooldown then
        local info = C_Spell.GetSpellCooldown(spellID)
        if info then
            start, duration, enabled = info.startTime, info.duration, info.isEnabled and 1 or 0
        end
    end
    if not start and GetSpellCooldown then
        start, duration, enabled = GetSpellCooldown(spellID)
    end
    return start or 0, duration or 0, enabled or 0
end

local function ShowMessage(text)
    if UIErrorsFrame and UIErrorsFrame.AddMessage then
        UIErrorsFrame:AddMessage(text, 0, 1, 0) -- alerta visual solo
    end
end

-- ==========================================================
-- Auto-detección de hechizos
-- ==========================================================
local function DetectPlayerSpells()
    for slot = 1, 120 do
        local type, id = GetActionInfo(slot)
        if type == "spell" and id then
            local spellName = GetSpellInfoCompat(id)
            if spellName and not CooldownAbilityAlert_Saved[id] then
                CooldownAbilityAlert_Saved[id] = true
                ShowMessage("Auto-detected spell: "..spellName)
            end
        end
    end
end

-- ==========================================================
-- UI del addon
-- ==========================================================
local options = CreateFrame("Frame", "CooldownAbilityAlertOptions", UIParent)
options.name = "CooldownAbilityAlert"
options:SetSize(400, 200)

local title = options:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("CooldownAbilityAlert")

local autoButton = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
autoButton:SetSize(180, 30)
autoButton:SetPoint("TOPLEFT", 16, -50)
autoButton:SetText("Auto-Detect Spells")
autoButton:SetScript("OnClick", function()
    DetectPlayerSpells()
    ShowMessage("Auto-detection complete! Monitoring your spells now.")
end)

-- ==========================================================
-- Registrar opciones en la interfaz
-- ==========================================================
local function RegisterOptions()
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(options)
    elseif Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(options, options.name)
        if Settings.RegisterAddOnCategory then Settings.RegisterAddOnCategory(category) end
    end
end

-- ==========================================================
-- Evento ADDON_LOADED
-- ==========================================================
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "CooldownAbilityAlert" then
        RegisterOptions()
        DetectPlayerSpells() -- autodetect al cargar
        ShowMessage("CooldownAbilityAlert loaded! Monitoring your spells automatically.")
        loadFrame:UnregisterEvent("ADDON_LOADED")
    end
end)

-- ==========================================================
-- OnUpdate para trackear cooldowns
-- ==========================================================
local timer = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer < 0.5 then return end
    timer = 0

    local now = GetTime()
    for spellID, enabled in pairs(CooldownAbilityAlert_Saved) do
        if enabled then
            local start, duration, cdEnabled = GetCooldown(spellID)
            if cdEnabled == 1 and duration > 1 then
                local remaining = (start + duration) - now
                if remaining > 1 then
                    activeCooldowns[spellID] = true
                elseif remaining <= 1 and activeCooldowns[spellID] then
                    activeCooldowns[spellID] = nil
                    local spellName = GetSpellInfoCompat(spellID) or ("Spell "..spellID)
                    ShowMessage(spellName.." READY!")
                end
            end
        end
    end
end)

-- ==========================================================
-- Comandos slash
-- ==========================================================
SLASH_COOLDOWNABILITYALERT1 = "/cda"
SlashCmdList["COOLDOWNABILITYALERT"] = function(msg)
    msg = msg:lower()
    if msg == "detect" then
        DetectPlayerSpells()
        ShowMessage("Auto-detection complete! Monitoring your spells now.")
    else
        ShowMessage("CooldownAbilityAlert commands:")
        ShowMessage("/cda detect - auto-detect your spells")
    end
end
