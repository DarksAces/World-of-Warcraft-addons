local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Mutanus" then
        print("Timer started for Mutanus")
        C_Timer.After(30, function() print("Mutanus phase change soon!") end)
    end
end)
