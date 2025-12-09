SLASH_VOL1 = "/vol"
SlashCmdList["VOL"] = function(msg)
    local vol = tonumber(msg)
    if vol and vol >= 0 and vol <= 100 then
        SetCVar("Sound_MasterVolume", vol / 100)
        print("|cFF00FF00MidnightVolume:|r Master Volume set to " .. vol .. "%")
    else
        print("|cFFFF0000MidnightVolume:|r Usage: /vol <0-100>")
    end
end
