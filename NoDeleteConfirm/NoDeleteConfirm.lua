-- Archivo: NoDeleteConfirm.lua
-- Addon que autocompleta el texto de confirmación de borrado

local f = CreateFrame("Frame")
f:RegisterEvent("DELETE_ITEM_CONFIRM")
f:SetScript("OnEvent", function(self, event, itemName)
    if StaticPopupDialogs["DELETE_ITEM"] then
        -- Autocompleta el texto requerido
        StaticPopup1EditBox:SetText(DELETE_ITEM_CONFIRM_STRING) -- Escribe "DELETE"
        StaticPopup1EditBox:HighlightText()
        StaticPopup1Button1:Enable() -- Activa el botón Aceptar
    end
end)
