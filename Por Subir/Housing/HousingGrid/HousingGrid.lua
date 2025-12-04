local grid = CreateFrame("Frame", nil, UIParent)
grid:SetAllPoints(UIParent)
grid:Hide()

local function CreateGridLine(startPoint, endPoint)
    local line = grid:CreateLine()
    line:SetColorTexture(0, 1, 0, 0.3)
    line:SetThickness(1)
    line:SetStartPoint(unpack(startPoint))
    line:SetEndPoint(unpack(endPoint))
end

-- Create a 10x10 grid
for i = 0, 10 do
    local pos = i / 10 * GetScreenHeight()
    CreateGridLine({"LEFT", 0, pos - GetScreenHeight()/2}, {"RIGHT", 0, pos - GetScreenHeight()/2})
end
for i = 0, 10 do
    local pos = i / 10 * GetScreenWidth()
    CreateGridLine({"TOP", pos - GetScreenWidth()/2, 0}, {"BOTTOM", pos - GetScreenWidth()/2, 0})
end

SLASH_HOUSINGGRID1 = "/hgrid"
SlashCmdList["HOUSINGGRID"] = function()
    if grid:IsShown() then grid:Hide() else grid:Show() end
end
