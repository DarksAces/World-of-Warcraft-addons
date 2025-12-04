local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Nefarian" then
        print("Timer started for Nefarian")
        C_Timer.After(30, function() print("Nefarian phase change soon!") end)
    end
end)
