local frame = CreateFrame("Frame")
frame:RegisterEvent("MAIL_SHOW")

frame:SetScript("OnEvent", function()
    -- Check for COD mail
    print("COD Warning active.")
end)
