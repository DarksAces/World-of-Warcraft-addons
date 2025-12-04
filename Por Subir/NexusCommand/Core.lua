NexusCommand = LibStub and LibStub("AceAddon-3.0"):NewAddon("NexusCommand", "AceConsole-3.0", "AceEvent-3.0") or CreateFrame("Frame")
NexusCommand.Modules = {}

-- Mock LibStub/Ace3 if not present (for standalone functionality without libs)
if not LibStub then
    NexusCommand = CreateFrame("Frame")
    NexusCommand:RegisterEvent("ADDON_LOADED")
    NexusCommand:RegisterEvent("PLAYER_LOGOUT")
    NexusCommand.Modules = {}
    
    function NexusCommand:Print(msg)
        print("|cff00ccff[NexusCommand]|r " .. tostring(msg))
    end
    
    NexusCommand:SetScript("OnEvent", function(self, event, arg1)
        if event == "ADDON_LOADED" and arg1 == "NexusCommand" then
            self:OnInitialize()
        elseif event == "PLAYER_LOGOUT" then
            -- Save DB
        end
    end)
end

function NexusCommand:OnInitialize()
    self.db = NexusDB or {
        profile = {
            modules = {
                ["Rotation"] = true,
                ["TacticalMap"] = true,
                ["Economy"] = true,
                ["Cooldowns"] = true,
            },
            economy = {
                history = {}
            }
        }
    }
    NexusDB = self.db
    
    self:Print("Core initialized. Loading modules...")
    
    for name, module in pairs(self.Modules) do
        if self.db.profile.modules[name] then
            if module.OnEnable then
                module:OnEnable()
            end
            self:Print("Module loaded: " .. name)
        end
    end
    
    self:RegisterChatCommand("nc", "SlashHandler")
end

function NexusCommand:SlashHandler(msg)
    local cmd, arg = strsplit(" ", msg, 2)
    if cmd == "rotation" then
        self:ToggleModule("Rotation")
    elseif cmd == "map" then
        self:ToggleModule("TacticalMap")
    elseif cmd == "gold" then
        self:ToggleModule("Economy")
    else
        self:Print("Usage: /nc [rotation|map|gold]")
    end
end

function NexusCommand:ToggleModule(name)
    if self.Modules[name] then
        -- Toggle logic would go here
        self:Print("Toggled module: " .. name)
    else
        self:Print("Module not found: " .. name)
    end
end

function NexusCommand:NewModule(name)
    local module = {}
    self.Modules[name] = module
    return module
end
