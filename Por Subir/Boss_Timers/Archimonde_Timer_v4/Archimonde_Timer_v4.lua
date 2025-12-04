local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Archimonde" then
        print("Timer started for Archimonde")
        C_Timer.After(30, function() print("Archimonde phase change soon!") end)
    end
end)
