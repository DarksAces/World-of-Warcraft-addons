local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Hogger" then
        print("Timer started for Hogger")
        C_Timer.After(30, function() print("Hogger phase change soon!") end)
    end
end)
