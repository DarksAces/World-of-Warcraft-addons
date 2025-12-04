local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Kiljaeden" then
        print("Timer started for Kiljaeden")
        C_Timer.After(30, function() print("Kiljaeden phase change soon!") end)
    end
end)
