local items = {
    "Wooden Chair",
    "Stone Table",
    "Red Rug",
    "Bookshelf",
    "Candle",
}

SLASH_FURNITURECATALOG1 = "/fc"
SlashCmdList["FURNITURECATALOG"] = function()
    print("--- Furniture Catalog ---")
    for _, item in ipairs(items) do
        print("- " .. item)
    end
end
