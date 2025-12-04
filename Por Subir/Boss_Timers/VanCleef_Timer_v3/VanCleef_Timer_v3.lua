local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "VanCleef" then
        print("Timer started for VanCleef")
        C_Timer.After(30, function() print("VanCleef phase change soon!") end)
    end
end)
