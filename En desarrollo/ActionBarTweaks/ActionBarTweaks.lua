local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    C_Timer.After(1, function() -- Esperar un segundo para que todo cargue
        local bar = MainMenuBarArtFrame
        
        if bar then
            bar:ClearAllPoints()
            bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 120)
            bar:SetScale(0.9)
            
            -- También mover las barras de acción
            if MainMenuBar then
                MainMenuBar:ClearAllPoints()
                MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 120)
                MainMenuBar:SetScale(0.9)
            end
            
            print("|cff00ff00[ActionBarTweaks]|r Barra movida correctamente.")
        else
            print("|cffff0000No se pudo encontrar la barra principal.|r")
        end
    end)
end)