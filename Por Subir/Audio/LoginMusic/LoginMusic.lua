local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function()
    -- PlayMusic("Interface\\AddOns\\LoginMusic\\login.mp3")
    print("Welcome back! Playing login music... (Mockup)")
end)
