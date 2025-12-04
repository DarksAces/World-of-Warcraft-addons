local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Greenskin" then
        print("Timer started for Greenskin")
        C_Timer.After(30, function() print("Greenskin phase change soon!") end)
    end
end)
