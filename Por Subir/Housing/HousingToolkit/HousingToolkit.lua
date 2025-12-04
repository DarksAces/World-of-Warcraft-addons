-- Mockup toolkit frame
local frame = CreateFrame("Frame", "HousingToolkitFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(300, 400)
frame:SetPoint("CENTER")
frame:Hide()

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
frame.title:SetText("Housing Toolkit")

local function CreateButton(text, yOffset)
    local btn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    btn:SetPoint("TOP", frame, "TOP", 0, yOffset)
    btn:SetSize(140, 30)
    btn:SetText(text)
    return btn
end

CreateButton("Toggle Grid", -40)
CreateButton("Rotate Left", -80)
CreateButton("Rotate Right", -120)
CreateButton("Scale Up", -160)
CreateButton("Scale Down", -200)

SLASH_HOUSINGTOOLKIT1 = "/ht"
SlashCmdList["HOUSINGTOOLKIT"] = function()
    if frame:IsShown() then frame:Hide() else frame:Show() end
end
