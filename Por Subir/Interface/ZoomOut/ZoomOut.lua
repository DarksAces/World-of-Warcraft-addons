local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function()
    SetCVar("cameraDistanceMaxZoomFactor", 2.6)
    MoveViewOutStart(50000) -- Zoom out for a long time (effectively max)
    C_Timer.After(1, MoveViewOutStop)
end)
