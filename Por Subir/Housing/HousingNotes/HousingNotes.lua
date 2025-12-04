local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "HousingNotes" then
        if not HousingNotesDB then HousingNotesDB = {} end
    end
end)

SLASH_HOUSINGNOTES1 = "/hnote"
SlashCmdList["HOUSINGNOTES"] = function(msg)
    if msg == "list" then
        print("--- Housing Notes ---")
        for i, note in ipairs(HousingNotesDB) do
            print(i .. ". " .. note)
        end
    elseif msg == "clear" then
        HousingNotesDB = {}
        print("Notes cleared.")
    else
        table.insert(HousingNotesDB, msg)
        print("Note saved.")
    end
end
