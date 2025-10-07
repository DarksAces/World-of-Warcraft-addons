local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    -- Esperar a que todo cargue
    local bar = MainMenuBar

    if bar then
        -- Mover la barra más arriba
        bar:ClearAllPoints()
        bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 120)

        -- Cambiar escala (más pequeña)
        bar:SetScale(0.9)

        -- Mensaje de confirmación
        print("|cff00ff00[ActionBarTweaks]|r Barra movida correctamente.")
    else
        print("|cffff0000No se pudo encontrar la barra principal.|r")
    end
end)
