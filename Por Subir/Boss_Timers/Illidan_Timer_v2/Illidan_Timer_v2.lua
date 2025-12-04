local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Illidan" then
        print("Timer started for Illidan")
        C_Timer.After(30, function() print("Illidan phase change soon!") end)
    end
end)
