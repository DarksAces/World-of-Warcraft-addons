local frame = CreateFrame("Frame")
frame:RegisterEvent("READY_CHECK")

frame:SetScript("OnEvent", function()
    -- Check for food/flask buff
    print("Checking consumables... (Mockup)")
end)
