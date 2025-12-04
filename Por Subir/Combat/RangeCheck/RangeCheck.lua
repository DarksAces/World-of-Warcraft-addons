local frame = CreateFrame("Frame", "RangeCheckFrame", UIParent)
frame:SetSize(32, 32)
frame:SetPoint("CENTER", 0, -100)

local icon = frame:CreateTexture(nil, "OVERLAY")
icon:SetAllPoints(frame)
icon:SetTexture("Interface\\Icons\\Ability_Hunter_SniperShot")

C_Timer.NewTicker(0.1, function()
    if UnitExists("target") then
        frame:Show()
        if C_Spell.IsSpellInRange("Auto Attack", "target") == 1 then
            icon:SetVertexColor(1, 1, 1) -- In range
        else
            icon:SetVertexColor(1, 0, 0) -- Out of range
        end
    else
        frame:Hide()
    end
end)
