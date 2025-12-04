local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Ragnaros" then
        print("Timer started for Ragnaros")
        C_Timer.After(30, function() print("Ragnaros phase change soon!") end)
    end
end)
