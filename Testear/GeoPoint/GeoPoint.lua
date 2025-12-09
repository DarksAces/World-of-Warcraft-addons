local frame = CreateFrame("Frame", "GeoPointFrame", UIParent)
frame:SetSize(100, 20)
frame:SetPoint("TOP", UIParent, "TOP", 0, -20)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("CENTER")

local timer = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer > 0.1 then
        timer = 0
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID then
            local pos = C_Map.GetPlayerMapPosition(mapID, "player")
            if pos then
                local x, y = pos:GetXY()
                text:SetText(string.format("%.1f, %.1f", x * 100, y * 100))
            else
                text:SetText("No Signal")
            end
        else
            text:SetText("Unknown")
        end
    end
end)
