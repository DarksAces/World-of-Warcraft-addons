local frame = CreateFrame("Frame")
frame:RegisterEvent("CHALLENGE_MODE_START")

frame:SetScript("OnEvent", function()
    local affixes = C_MythicPlus.GetCurrentAffixes()
    if affixes then
        for _, affix in ipairs(affixes) do
            print("Affix: " .. affix.name)
        end
    end
end)
