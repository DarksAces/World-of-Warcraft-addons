local frame = CreateFrame("Frame")
frame:RegisterEvent("CINEMATIC_START")
frame:RegisterEvent("PLAY_MOVIE")

frame:SetScript("OnEvent", function(self, event)
    if event == "CINEMATIC_START" then
        if CinematicFrame then
            CinematicFrame_CancelCinematic()
            print("|cFF00FF00MidnightCinematics:|r Skipped cinematic.")
        end
    elseif event == "PLAY_MOVIE" then
        if MovieFrame and MovieFrame:IsShown() then
            MovieFrame:Hide()
            print("|cFF00FF00MidnightCinematics:|r Skipped movie.")
        end
    end
end)
