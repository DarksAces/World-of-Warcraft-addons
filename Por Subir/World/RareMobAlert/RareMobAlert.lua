local frame = CreateFrame("Frame")
frame:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")

frame:SetScript("OnEvent", function(self, event, vignetteGUID)
    local info = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
    if info then
        print("Rare Mob Detected: " .. (info.name or "Unknown"))
        PlaySound(11466)
    end
end)
