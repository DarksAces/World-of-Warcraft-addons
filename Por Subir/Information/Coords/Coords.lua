local CoordsFrame = CreateFrame("Frame", "CoordsFrame", Minimap)
CoordsFrame:SetSize(40, 20)
CoordsFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 5)

local CoordsText = CoordsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
CoordsText:SetPoint("CENTER", CoordsFrame, "CENTER")
CoordsText:SetTextColor(1, 1, 1)

C_Timer.NewTicker(0.5, function()
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID then
        local pos = C_Map.GetPlayerMapPosition(mapID, "player")
        if pos then
            CoordsText:SetText(string.format("%.1f, %.1f", pos.x * 100, pos.y * 100))
        else
            CoordsText:SetText("")
        end
    end
end)
