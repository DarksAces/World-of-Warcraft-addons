MainMenuBar.EndCaps:Hide()
-- Hook to ensure they stay hidden if UI reloads or changes state
hooksecurefunc(MainMenuBar.EndCaps, "Show", function(self) self:Hide() end)
