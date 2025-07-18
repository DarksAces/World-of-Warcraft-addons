local addonName = "EmoteOnTarget"
local frame = CreateFrame("Frame")

local cooldownSeconds = 5
local lastEmoteTime = 0

local emotes = {
    FRIENDLY_NPC = {
        "salute", "bow", "talk", "wave", "cheer", "thank", "nod", "blowkiss", "curtsey"
    },
    HOSTILE_PLAYER = {
        "rude", "chicken", "laugh", "roar", "flex", "scowl", "kick", "mock", "taunt"
    },
    FRIENDLY_PLAYER = {
        "wave", "cheer", "hug", "clap", "smile", "blowkiss", "dance", "highfive"
    },
    HOSTILE_NPC = {
        "roar", "threaten", "growl", "snarl", "shakefist", "point", "scowl"
    },
}

local showMessages = true

local function GetRandomEmote(emoteList)
    return emoteList[math.random(#emoteList)]
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        if UnitExists("target") then
            local currentTime = GetTime()
            if currentTime - lastEmoteTime < cooldownSeconds then
                -- En cooldown, no hacer emote
                return
            end
            lastEmoteTime = currentTime

            local targetName = UnitName("target")
            local reaction = UnitReaction("player", "target") or 5
            local isPlayer = UnitIsPlayer("target")
            local isFriend = UnitIsFriend("player", "target")

            if UnitIsDeadOrGhost("target") or UnitIsDead("target") or not UnitIsConnected("target") then
                if showMessages then
                    print(addonName .. ": Target is dead, ghost or disconnected, no emote.")
                end
                return
            end

            local emote
            if isPlayer then
                if isFriend then
                    emote = GetRandomEmote(emotes.FRIENDLY_PLAYER)
                    if showMessages then print(addonName .. ": Greeting " .. targetName .. " with " .. emote .. ".") end
                else
                    emote = GetRandomEmote(emotes.HOSTILE_PLAYER)
                    if showMessages then print(addonName .. ": Challenging " .. targetName .. " with " .. emote .. ".") end
                end
            else
                if reaction <= 4 then
                    emote = GetRandomEmote(emotes.HOSTILE_NPC)
                    if showMessages then print(addonName .. ": Challenging " .. targetName .. " with " .. emote .. ".") end
                else
                    emote = GetRandomEmote(emotes.FRIENDLY_NPC)
                    if showMessages then print(addonName .. ": Greeting " .. targetName .. " with " .. emote .. ".") end
                end
            end

            DoEmote(emote)
        else
            if showMessages then print(addonName .. ": No target selected.") end
        end
    elseif event == "PLAYER_LOGIN" then
        if showMessages then print(addonName .. " loaded. Select a target to see the emotes!") end
    end
end)

frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_LOGIN")
