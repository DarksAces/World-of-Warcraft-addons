import os
import random

BASE_DIR = r"d:\GitHub\World-of-Warcraft-addons\Por Subir"
TOTAL_ADDONS = 1000

CATEGORIES = [
    "Class_SpellAlerts",
    "Boss_Timers",
    "Zone_Trackers",
    "Item_Tooltips",
    "Chat_Commands",
    "Sound_Packs",
    "UI_Tweaks",
    "Profession_Helpers",
    "Achievement_Helpers",
    "Fun_Emotes"
]

CLASSES = {
    "Warrior": ["Charge", "Execute", "ShieldSlam", "MortalStrike", "Whirlwind", "HeroicLeap", "Pummel", "SpellReflection", "Avatar", "Bladestorm"],
    "Mage": ["Fireball", "Frostbolt", "ArcaneBlast", "Blink", "Counterspell", "Polymorph", "IceBlock", "Combustion", "IcyVeins", "ArcanePower"],
    "Rogue": ["SinisterStrike", "Eviscerate", "Kick", "Sprint", "Stealth", "Vanish", "KidneyShot", "Blind", "ShadowDance", "AdrenalineRush"],
    "Priest": ["Smite", "Heal", "FlashHeal", "PowerWordShield", "ShadowWordPain", "Penance", "PsychicScream", "Dispersion", "GuardianSpirit", "VoidEruption"],
    "Hunter": ["AimedShot", "SteadyShot", "ArcaneShot", "MultiShot", "KillCommand", "BestialWrath", "FeignDeath", "Disengage", "FreezingTrap", "Aspect of the Turtle"],
    "Druid": ["Wrath", "Moonfire", "Regrowth", "Rejuvenation", "CatForm", "BearForm", "TravelForm", "Dash", "Prowl", "Barkskin"],
    "Shaman": ["LightningBolt", "ChainLightning", "HealingSurge", "Riptide", "EarthShock", "FlameShock", "GhostWolf", "AstralShift", "Hex", "Bloodlust"],
    "Paladin": ["CrusaderStrike", "Judgment", "FlashofLight", "WordofGlory", "DivineShield", "HammerofJustice", "AvengingWrath", "LayonHands", "BlessingofProtection", "DivineSteed"],
    "Warlock": ["ShadowBolt", "Immolate", "Corruption", "Agony", "Fear", "DrainLife", "Healthstone", "DemonicCircle", "ChaosBolt", "SummonDemon"],
    "Monk": ["TigerPalm", "BlackoutKick", "RisingSunKick", "KegSmash", "Vivify", "Roll", "LegSweep", "TouchofDeath", "FortifyingBrew", "ZenMeditation"],
    "DemonHunter": ["DemonsBite", "ChaosStrike", "BladeDance", "EyeBeam", "Metamorphosis", "FelRush", "VengefulRetreat", "ConsumeMagic", "ImmolationAura", "SpectralSight"],
    "DeathKnight": ["DeathStrike", "HeartStrike", "Obliterate", "HowlingBlast", "DeathGrip", "MindFreeze", "IceboundFortitude", "AntiMagicShell", "DeathandDecay", "RaiseDead"],
    "Evoker": ["LivingFlame", "AzureStrike", "Disintegrate", "Pyre", "DeepBreath", "Hover", "VerdantEmbrace", "EmeraldBlossom", "Rewind", "TimeDilation"]
}

BOSSES = ["Ragnaros", "Onyxia", "Nefarian", "CThun", "KelThuzad", "Illidan", "Arthas", "Deathwing", "Garrosh", "Archimonde", "Kiljaeden", "Sylvanas", "Jailer", "Raszageth", "Fyrakk", "Hogger", "VanCleef", "Mutanus", "Smite", "Greenskin"]
ZONES = ["Elwynn", "Durotar", "Westfall", "Barrens", "Stranglethorn", "Tanaris", "Nagrand", "GrizzlyHills", "JadeForest", "Suramar", "Drustvar", "Bastion", "Ohnahra", "Thaldraszus", "Silithus", "Winterspring", "Ashenvale", "Darkshore", "Mulgore", "Tirisfal"]
EMOTES = ["Dance", "Roar", "Cheer", "Cry", "Laugh", "Train", "Sleep", "Wave", "Bow", "Salute", "Rude", "Kiss", "Shy", "Flex", "Chicken", "Applaud", "Beg", "Eat", "Drink", "Talk"]

TOC_TEMPLATE = """## Interface: 110200
## Title: {name}
## Notes: {description}
## Author: Daniel
## Version: 1.0

{name}.lua
"""

LUA_ALERT_TEMPLATE = """local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function()
    local _, event, _, _, _, _, _, _, _, _, _, spellName = CombatLogGetCurrentEventInfo()
    if event == "SPELL_CAST_SUCCESS" and spellName == "{spell}" then
        print("{spell} cast detected!")
        PlaySound(12867)
    end
end)
"""

LUA_TIMER_TEMPLATE = """local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, id, name)
    if name == "{boss}" then
        print("Timer started for {boss}")
        C_Timer.After(30, function() print("{boss} phase change soon!") end)
    end
end)
"""

LUA_ZONE_TEMPLATE = """local frame = CreateFrame("Frame")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function()
    if GetZoneText() == "{zone}" then
        print("Welcome to {zone}! Watch out for dangers.")
    end
end)
"""

LUA_COMMAND_TEMPLATE = """SLASH_{upper_name}1 = "/{command}"
SlashCmdList["{upper_name}"] = function()
    DoEmote("{emote}")
    print("You performed {emote}!")
end
"""

generated_count = 0
created_names = set()

def create_addon(category, name, description, lua_content):
    if name in created_names:
        return False
    
    category_dir = os.path.join(BASE_DIR, category)
    addon_dir = os.path.join(category_dir, name)
    
    if not os.path.exists(addon_dir):
        os.makedirs(addon_dir)
    
    with open(os.path.join(addon_dir, f"{name}.toc"), "w") as f:
        f.write(TOC_TEMPLATE.format(name=name, description=description))
        
    with open(os.path.join(addon_dir, f"{name}.lua"), "w") as f:
        f.write(lua_content)
        
    created_names.add(name)
    return True

print("Starting generation of 1000 addons...")

# 1. Class Spell Alerts (Approx 13 classes * 10 spells = 130 addons)
for cls, spells in CLASSES.items():
    for spell in spells:
        name = f"{cls}_{spell}_Alert"
        desc = f"Alerts when {spell} is cast."
        lua = LUA_ALERT_TEMPLATE.format(spell=spell)
        if create_addon("Class_SpellAlerts", name, desc, lua):
            generated_count += 1

# 2. Boss Timers (Approx 20 bosses * 5 variations = 100 addons)
for boss in BOSSES:
    for i in range(1, 6):
        name = f"{boss}_Timer_v{i}"
        desc = f"Timer variation {i} for {boss}."
        lua = LUA_TIMER_TEMPLATE.format(boss=boss)
        if create_addon("Boss_Timers", name, desc, lua):
            generated_count += 1

# 3. Zone Trackers (Approx 20 zones * 5 variations = 100 addons)
for zone in ZONES:
    for i in range(1, 6):
        name = f"{zone}_Tracker_v{i}"
        desc = f"Tracker variation {i} for {zone}."
        lua = LUA_ZONE_TEMPLATE.format(zone=zone)
        if create_addon("Zone_Trackers", name, desc, lua):
            generated_count += 1

# 4. Chat Commands (Approx 20 emotes * 5 variations = 100 addons)
for emote in EMOTES:
    for i in range(1, 6):
        name = f"Auto{emote}_v{i}"
        desc = f"Auto {emote} command variation {i}."
        lua = LUA_COMMAND_TEMPLATE.format(upper_name=name.upper(), command=name.lower(), emote=emote.upper())
        if create_addon("Chat_Commands", name, desc, lua):
            generated_count += 1

# 5. Fill the rest with procedural generation
while generated_count < TOTAL_ADDONS:
    category = random.choice(CATEGORIES)
    suffix = random.randint(1000, 9999)
    
    if category == "Class_SpellAlerts":
        cls = random.choice(list(CLASSES.keys()))
        spell = random.choice(CLASSES[cls])
        name = f"{cls}_{spell}_Extra_{suffix}"
        desc = f"Extra alert for {spell}."
        lua = LUA_ALERT_TEMPLATE.format(spell=spell)
        
    elif category == "Boss_Timers":
        boss = random.choice(BOSSES)
        name = f"{boss}_ExtraTimer_{suffix}"
        desc = f"Extra timer for {boss}."
        lua = LUA_TIMER_TEMPLATE.format(boss=boss)
        
    elif category == "Zone_Trackers":
        zone = random.choice(ZONES)
        name = f"{zone}_ExtraTracker_{suffix}"
        desc = f"Extra tracker for {zone}."
        lua = LUA_ZONE_TEMPLATE.format(zone=zone)
        
    elif category == "Chat_Commands":
        emote = random.choice(EMOTES)
        name = f"Quick{emote}_{suffix}"
        desc = f"Quick command for {emote}."
        lua = LUA_COMMAND_TEMPLATE.format(upper_name=name.upper(), command=name.lower(), emote=emote.upper())
        
    else:
        # Generic filler for other categories
        name = f"{category}_Addon_{suffix}"
        desc = f"Generic addon for {category}."
        lua = f"print('{name} loaded.')"
    
    if create_addon(category, name, desc, lua):
        generated_count += 1

print(f"Successfully generated {generated_count} addons.")
