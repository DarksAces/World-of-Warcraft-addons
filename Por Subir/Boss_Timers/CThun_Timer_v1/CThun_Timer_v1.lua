local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "CThun" then
        print("Timer started for CThun")
        C_Timer.After(30, function() print("CThun phase change soon!") end)
    end
end)
