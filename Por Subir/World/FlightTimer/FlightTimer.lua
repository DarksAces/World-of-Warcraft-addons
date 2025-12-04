local frame = CreateFrame("Frame")
frame:RegisterEvent("TAXIMAP_OPENED")

frame:SetScript("OnEvent", function()
    -- Logic to estimate flight time
    print("Flight Timer ready (Mockup)")
end)
