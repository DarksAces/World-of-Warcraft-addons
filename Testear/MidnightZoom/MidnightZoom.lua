local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        SetCVar("cameraDistanceMaxZoomFactor", 2.6)
        print("|cFF00FF00MidnightZoom:|r Camera distance set to max (2.6).")
    end
end)
