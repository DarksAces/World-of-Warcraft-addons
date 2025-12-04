local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Onyxia" then
        print("Timer started for Onyxia")
        C_Timer.After(30, function() print("Onyxia phase change soon!") end)
    end
end)
