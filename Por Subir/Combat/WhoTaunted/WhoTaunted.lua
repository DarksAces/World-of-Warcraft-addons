local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local tauntSpells = {
    [355] = true, -- Taunt (Warrior)
    [62124] = true, -- Hand of Reckoning (Paladin)
    [56222] = true, -- Dark Command (DK)
    [49576] = true, -- Death Grip (DK)
    [6795] = true, -- Growl (Druid)
    [115546] = true, -- Provoke (Monk)
    [185245] = true, -- Torment (DH)
}

frame:SetScript("OnEvent", function()
    local _, event, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID = CombatLogGetCurrentEventInfo()
    if event == "SPELL_CAST_SUCCESS" and tauntSpells[spellID] then
        if destName then
            print("|cffff0000[Taunt]|r " .. sourceName .. " taunted " .. destName)
        end
    end
end)
