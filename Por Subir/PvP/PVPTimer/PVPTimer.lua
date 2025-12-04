local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function()
    if C_PvP.IsPVPMap() then
        print("PvP Timer started.")
    end
end)
