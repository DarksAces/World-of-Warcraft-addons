local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Smite" then
        print("Timer started for Smite")
        C_Timer.After(30, function() print("Smite phase change soon!") end)
    end
end)
