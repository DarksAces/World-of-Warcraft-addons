local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "VendorTracker" then
        if not VendorTrackerDB then VendorTrackerDB = {} end
    elseif event == "MERCHANT_SHOW" then
        local name = UnitName("npc")
        if name then
            local mapID = C_Map.GetBestMapForUnit("player")
            if mapID then
                local pos = C_Map.GetPlayerMapPosition(mapID, "player")
                if pos then
                    if not VendorTrackerDB[mapID] then VendorTrackerDB[mapID] = {} end
                    VendorTrackerDB[mapID][name] = { x = pos.x, y = pos.y }
                    print("|cff00ff00[VendorTracker]|r Recorded vendor: " .. name)
                end
            end
        end
    end
end)

SLASH_VENDORTRACKER1 = "/vendors"
SlashCmdList["VENDORTRACKER"] = function()
    print("--- Recorded Vendors ---")
    for mapID, vendors in pairs(VendorTrackerDB) do
        local mapInfo = C_Map.GetMapInfo(mapID)
        if mapInfo then
            print(mapInfo.name .. ":")
            for name, pos in pairs(vendors) do
                print(string.format(" - %s (%.1f, %.1f)", name, pos.x * 100, pos.y * 100))
            end
        end
    end
end
