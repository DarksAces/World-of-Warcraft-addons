local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_HAPPINESS")

frame:SetScript("OnEvent", function(self, event, unit)
    if unit == "pet" then
        local happiness = GetPetHappiness()
        if happiness and happiness < 3 then
            print("Hunter: Feed your pet!")
        end
    end
end)
