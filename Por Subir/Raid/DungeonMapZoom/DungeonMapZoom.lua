local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function()
    if IsInInstance() then
        Minimap:SetZoom(2)
    else
        Minimap:SetZoom(0)
    end
end)
