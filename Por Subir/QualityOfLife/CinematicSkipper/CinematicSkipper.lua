local frame = CreateFrame("Frame")
frame:RegisterEvent("CINEMATIC_START")
frame:RegisterEvent("PLAY_MOVIE")

frame:SetScript("OnEvent", function(self, event)
    if event == "CINEMATIC_START" then
        CinematicFrame_CancelCinematic()
    elseif event == "PLAY_MOVIE" then
        MovieFrame_PlayMovie(MovieFrame, 0) -- Force stop/skip if possible
    end
end)
