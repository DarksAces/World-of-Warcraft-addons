local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Enter combat
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local buffs = {
    PRIEST = 21562, -- Power Word: Fortitude
    MAGE = 1459, -- Arcane Intellect
    WARRIOR = 6673, -- Battle Shout
}

frame:SetScript("OnEvent", function()
    local _, class = UnitClass("player")
    local buffID = buffs[class]
    
    if buffID then
        local name = C_Spell.GetSpellName(buffID)
        if name then
            local aura = C_UnitAuras.GetPlayerAuraBySpellID(buffID)
            if not aura then
                print("|cffff0000[BuffReminder]|r MISSING BUFF: " .. name)
            end
        end
    end
end)
