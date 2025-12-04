local frame = CreateFrame("Frame", nil, UIParent)
frame:SetAllPoints(UIParent)
frame:Hide()

local texture = frame:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints(frame)
texture:SetColorTexture(1, 0, 0, 0.3)

local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_HEALTH")

f:SetScript("OnEvent", function(self, event, unit)
    if unit == "player" then
        local hp = UnitHealth("player")
        local max = UnitHealthMax("player")
        if (hp / max) < 0.3 and not UnitIsDeadOrGhost("player") then
            frame:Show()
        else
            frame:Hide()
        end
    end
end)
