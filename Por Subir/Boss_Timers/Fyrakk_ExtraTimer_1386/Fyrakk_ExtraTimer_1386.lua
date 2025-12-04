local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "Fyrakk" then
        print("Timer started for Fyrakk")
        C_Timer.After(30, function() print("Fyrakk phase change soon!") end)
    end
end)
