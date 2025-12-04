-- Mockup: Adds buttons to the side of the trade skill frame
local function CreateTab(id, text)
    local btn = CreateFrame("Button", nil, ProfessionsFrame, "UIPanelButtonTemplate")
    btn:SetSize(30, 30)
    btn:SetPoint("TOPRIGHT", ProfessionsFrame, "TOPRIGHT", 30, -30 * id)
    btn:SetText(text)
end

if ProfessionsFrame then
    CreateTab(1, "1")
    CreateTab(2, "2")
end
