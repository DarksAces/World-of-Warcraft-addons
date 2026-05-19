local ADDON_NAME, ns = ...
ns.Options = {}

local panel = CreateFrame("Frame", "CursorTrailOptionsPanel", UIParent, "BasicFrameTemplateWithInset")
panel:SetSize(350, 480)
panel:SetPoint("CENTER")
panel:SetMovable(true)
panel:EnableMouse(true)
panel:RegisterForDrag("LeftButton")
panel:SetScript("OnDragStart", panel.StartMoving)
panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
panel:Hide()
tinsert(UISpecialFrames, "CursorTrailOptionsPanel")

panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
panel.title:SetPoint("CENTER", panel.TitleBg, "CENTER", 0, 0)
panel.title:SetText("CursorTrail Control Panel")

local function CreateCheckbox(parent, label, dbKey, x, y)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", x, y)
    
    cb.Text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cb.Text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    cb.Text:SetText(label)
    
    cb:SetScript("OnShow", function(self) self:SetChecked(CursorTrailDB[dbKey]) end)
    cb:SetScript("OnClick", function(self) 
        CursorTrailDB[dbKey] = self:GetChecked()
        if dbKey == "enabled" and not self:GetChecked() then
            if ns.Effects and ns.Effects.ClearTrail then
                ns.Effects.ClearTrail()
            end
        end
    end)
    return cb
end

local cbEnabled = CreateCheckbox(panel, "Enable Addon", "enabled", 20, -40)
local cbClick = CreateCheckbox(panel, "Click Ripples", "clickEffects", 20, -70)
local cbSound = CreateCheckbox(panel, "Click Sounds", "soundEffects", 20, -100)
local cbSparkles = CreateCheckbox(panel, "Magical Sparkles", "sparkles", 20, -130)
local cbShadow = CreateCheckbox(panel, "Shadow Trail", "shadowTrail", 20, -160)
local cbAura = CreateCheckbox(panel, "Idle Aura", "idleAura", 20, -190)

local cbRainbow = CreateCheckbox(panel, "Rainbow Color", "rainbow", 180, -70)
local cbClass = CreateCheckbox(panel, "Class Color", "classColor", 180, -100)
local cbPulse = CreateCheckbox(panel, "Pulse Effect", "pulse", 180, -130)

local sliderCount = 0
local function CreateSlider(parent, label, dbKey, minVal, maxVal, step, x, y)
    sliderCount = sliderCount + 1
    local name = "CT_Slider_" .. sliderCount
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    
    _G[name .. "Low"]:SetText(minVal)
    _G[name .. "High"]:SetText(maxVal)
    _G[name .. "Text"]:SetText(label)
    
    slider:SetScript("OnShow", function(self)
        self:SetValue(CursorTrailDB[dbKey])
    end)
    
    slider:SetScript("OnValueChanged", function(self, value)
        CursorTrailDB[dbKey] = value
    end)
    return slider
end

local slWidth = CreateSlider(panel, "Trail Width", "lineWidth", 1, 10, 1, 20, -250)
local slLength = CreateSlider(panel, "Trail Length", "trailLength", 0.5, 3.0, 0.1, 180, -250)

local presetY = -310
local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", 20, presetY)
title:SetText("Presets:")

local function CreatePresetBtn(parent, label, presetName, x, y)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(100, 22)
    btn:SetPoint("TOPLEFT", x, y)
    btn:SetText(label)
    btn:SetScript("OnClick", function()
        ns.Config.ApplyPreset(presetName)
        panel:Hide()
        panel:Show() -- Refresh checkboxes
    end)
end

CreatePresetBtn(panel, "Fire", "Fire Trail", 20, presetY - 20)
CreatePresetBtn(panel, "Blue", "Electric Blue", 125, presetY - 20)
CreatePresetBtn(panel, "Green", "Neon Green", 230, presetY - 20)
CreatePresetBtn(panel, "Rainbow", "Rainbow Power", 20, presetY - 45)
CreatePresetBtn(panel, "Classy", "Classy", 125, presetY - 45)
