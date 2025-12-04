local frame = CreateFrame("Frame")
frame:RegisterEvent("BAG_UPDATE_COOLDOWN")

frame:SetScript("OnEvent", function()
    local start, duration = GetItemCooldown(6948) -- Hearthstone
    if duration > 0 then
        -- print("Hearthstone CD: " .. duration)
    end
end)
