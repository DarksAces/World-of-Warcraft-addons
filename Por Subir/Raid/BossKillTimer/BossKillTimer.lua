local start = 0
local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("ENCOUNTER_END")

frame:SetScript("OnEvent", function(self, event, id, name, diff, size)
    if event == "ENCOUNTER_START" then
        start = GetTime()
        print("Boss " .. name .. " engaged.")
    elseif event == "ENCOUNTER_END" then
        print("Encounter ended. Time: " .. string.format("%.1fs", GetTime() - start))
    end
end)
