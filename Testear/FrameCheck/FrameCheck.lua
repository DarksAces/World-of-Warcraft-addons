local frame = CreateFrame("Frame", "FrameCheckFrame", UIParent)
frame:SetSize(60, 20)
frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 10)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("CENTER")

local timer = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer > 0.5 then
        timer = 0
        local fps = GetFramerate()
        text:SetText(string.format("FPS: %.0f", fps))
    end
end)
