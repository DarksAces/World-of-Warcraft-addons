local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Raszageth" then
        print("Timer started for Raszageth")
        C_Timer.After(30, function() print("Raszageth phase change soon!") end)
    end
end)
