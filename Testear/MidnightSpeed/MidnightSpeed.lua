local frame = CreateFrame("Frame", "MidnightSpeedFrame", UIParent)
frame:SetSize(80, 20)
frame:SetPoint("TOP", UIParent, "TOP", 0, -45)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("CENTER")

local timer = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer > 0.1 then
        timer = 0
        local currentSpeed = GetUnitSpeed("player")
        if currentSpeed then
            local speedPct = (currentSpeed / 7) * 100
            text:SetText(string.format("%d%%", speedPct))
        else
            text:SetText("0%")
        end
    end
end)
