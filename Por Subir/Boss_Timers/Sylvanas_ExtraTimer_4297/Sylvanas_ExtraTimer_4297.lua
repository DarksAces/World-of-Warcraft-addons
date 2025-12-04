local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Sylvanas" then
        print("Timer started for Sylvanas")
        C_Timer.After(30, function() print("Sylvanas phase change soon!") end)
    end
end)
