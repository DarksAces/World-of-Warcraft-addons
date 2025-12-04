local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function()
    local _, event, _, sourceGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
    if event == "PARTY_KILL" and sourceGUID == UnitGUID("player") then
        if UnitIsPlayer(destGUID) then -- Check if target was a player (approximate)
             -- PlaySoundFile("Interface\\AddOns\\PVPSound\\humiliation.mp3") -- Mockup
             print("|cffff0000[PVP]|r HUMILIATION!")
        end
    end
end)
