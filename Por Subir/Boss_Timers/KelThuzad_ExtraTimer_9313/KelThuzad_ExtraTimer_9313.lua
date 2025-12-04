local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "KelThuzad" then
        print("Timer started for KelThuzad")
        C_Timer.After(30, function() print("KelThuzad phase change soon!") end)
    end
end)
