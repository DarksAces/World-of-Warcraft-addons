if MinimapZoomIn then MinimapZoomIn:Hide() end
if MinimapZoomOut then MinimapZoomOut:Hide() end
if MinimapZoneTextButton then MinimapZoneTextButton:Hide() end
if MinimapBorderTop then MinimapBorderTop:Hide() end
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, delta)
    if delta > 0 then
        Minimap_ZoomIn()
    else
        Minimap_ZoomOut()
    end
end)
