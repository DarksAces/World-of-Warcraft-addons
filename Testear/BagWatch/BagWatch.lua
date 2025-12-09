local frame = CreateFrame("Frame", "BagWatchFrame", UIParent)
frame:SetSize(80, 20)
frame:SetPoint("TOP", UIParent, "TOP", 0, -70)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("CENTER")

frame:RegisterEvent("BAG_UPDATE")

local function UpdateBagSpace()
    local free = 0
    for bag = 0, 4 do
        free = free + C_Container.GetContainerNumFreeSlots(bag)
    end
    text:SetText(string.format("Bag: %d", free))
end

frame:SetScript("OnEvent", UpdateBagSpace)
UpdateBagSpace() -- Initial update
