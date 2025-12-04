local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Jailer" then
        print("Timer started for Jailer")
        C_Timer.After(30, function() print("Jailer phase change soon!") end)
    end
end)
