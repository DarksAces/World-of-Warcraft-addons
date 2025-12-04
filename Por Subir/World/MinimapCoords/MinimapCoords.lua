local text = Minimap:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 5)

local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer > 0.5 then
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID then
            local pos = C_Map.GetPlayerMapPosition(mapID, "player")
            if pos then
                text:SetText(string.format("%.1f, %.1f", pos.x * 100, pos.y * 100))
            end
        end
        self.timer = 0
    end
end)
