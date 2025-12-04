local filters = {
    [LE_GAME_ERR_ABILITY_COOLDOWN] = true,
    [LE_GAME_ERR_SPELL_COOLDOWN] = true,
    [LE_GAME_ERR_OUT_OF_MANA] = true,
    [LE_GAME_ERR_OUT_OF_RAGE] = true,
    [LE_GAME_ERR_OUT_OF_ENERGY] = true,
    [LE_GAME_ERR_OUT_OF_FOCUS] = true,
    ["Ability is not ready yet."] = true,
    ["Not enough rage."] = true,
    ["Not enough energy."] = true,
    ["Not enough mana."] = true,
}

UIErrorsFrame:SetScript("OnEvent", function(self, event, msg, ...)
    if filters[msg] then return end
    -- Default behavior for other errors
    return self:GetScript("OnEvent")(self, event, msg, ...)
end)
