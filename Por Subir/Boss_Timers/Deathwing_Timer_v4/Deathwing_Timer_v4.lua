local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Deathwing" then
        print("Timer started for Deathwing")
        C_Timer.After(30, function() print("Deathwing phase change soon!") end)
    end
end)
