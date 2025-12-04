local frame = CreateFrame("Frame")
frame:RegisterEvent("AUCTION_HOUSE_SHOW")

frame:SetScript("OnEvent", function()
    -- C_AuctionHouse.SendSearchQuery()
    print("Auction Scanner ready (Mockup)")
end)
