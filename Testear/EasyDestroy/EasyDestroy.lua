local function AutoFillDelete(popup, ...)
    if popup.editBox and popup.editBox:IsShown() then
        if popup.button1 and popup.button1:IsEnabled() == false then
            popup.editBox:SetText("DELETE")
        end
    end
end

hooksecurefunc("StaticPopup_Show", function(which)
    if which == "DELETE_ITEM" or which == "DELETE_GOOD_ITEM" or which == "DELETE_GOOD_QUEST_ITEM" or which == "DELETE_QUEST_ITEM" then
        -- Find the active popup
        for i = 1, STATICPOPUP_NUMDIALOGS do
            local popup = _G["StaticPopup" .. i]
            if popup and popup:IsShown() and popup.which == which then
                AutoFillDelete(popup)
                return
            end
        end
    end
end)
