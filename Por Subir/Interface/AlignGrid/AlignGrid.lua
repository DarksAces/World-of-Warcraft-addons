local grid = CreateFrame("Frame", nil, UIParent)
grid:SetAllPoints(UIParent)
grid:Hide()

local function CreateLine(startPoint, endPoint)
    local line = grid:CreateLine()
    line:SetColorTexture(1, 0, 0, 0.5)
    line:SetThickness(1)
    line:SetStartPoint(unpack(startPoint))
    line:SetEndPoint(unpack(endPoint))
    return line
end

-- Simple crosshair
CreateLine({"TOP", 0, 0}, {"BOTTOM", 0, 0})
CreateLine({"LEFT", 0, 0}, {"RIGHT", 0, 0})

SLASH_ALIGNGRID1 = "/grid"
SlashCmdList["ALIGNGRID"] = function()
    if grid:IsShown() then grid:Hide() else grid:Show() end
end
