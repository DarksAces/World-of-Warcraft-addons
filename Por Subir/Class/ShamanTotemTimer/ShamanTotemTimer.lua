local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TOTEM_UPDATE")

frame:SetScript("OnEvent", function(self, event, slot)
    local haveTotem, name, startTime, duration, icon = GetTotemInfo(slot)
    if haveTotem and duration > 0 then
        print("Totem " .. name .. " active.")
    end
end)
