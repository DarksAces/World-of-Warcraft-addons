local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

frame:SetScript("OnEvent", function()
    local _, class = UnitClass("player")
    if class == "DRUID" then
        -- Check for Mark
        print("Druid: Mark of the Wild?")
    end
end)
