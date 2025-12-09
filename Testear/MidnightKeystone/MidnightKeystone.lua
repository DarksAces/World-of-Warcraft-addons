local frame = CreateFrame("Frame")
frame:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTACLE_OPEN")

frame:SetScript("OnEvent", function(self, event)
    if event == "CHALLENGE_MODE_KEYSTONE_RECEPTACLE_OPEN" then
        local bag, slot
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.itemID == 180653 then -- 180653 is Keystone item ID (Shadowlands+), might change in Midnight but good placeholder
                    C_Container.UseContainerItem(bag, slot)
                    print("|cFF00FF00MidnightKeystone:|r Auto slotted key.")
                    return
                end
            end
        end
        -- Fallback: check by name if ID fails or changes
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info then
                    local name = GetItemInfo(info.itemID)
                    if name and string.find(name, "Keystone") then
                         C_Container.UseContainerItem(bag, slot)
                         print("|cFF00FF00MidnightKeystone:|r Auto slotted key (by name).")
                         return
                    end
                end
            end
        end
    end
end)
