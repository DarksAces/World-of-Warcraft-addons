local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Garrosh" then
        print("Timer started for Garrosh")
        C_Timer.After(30, function() print("Garrosh phase change soon!") end)
    end
end)
