local frame = CreateFrame("Frame")
frame:RegisterEvent("READY_CHECK")

frame:SetScript("OnEvent", function()
    PlaySound(11466) -- Ready check sound
end)
