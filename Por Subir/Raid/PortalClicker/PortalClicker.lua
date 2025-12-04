local frame = CreateFrame("Frame")
frame:RegisterEvent("GOSSIP_SHOW")

frame:SetScript("OnEvent", function()
    -- SelectGossipOption(1) -- Auto select first option (often portal)
    print("Gossip opened (Portal Clicker active)")
end)
