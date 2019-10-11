UIPanelWindows["CT_RaidTrackerFrame"] = { area = "left", pushable = 1, whileDead = 1 };
GuildLaunchCT_RaidTracker = AceLibrary("AceAddon-2.0"):new("AceDB-2.0", "FuBarPlugin-2.0")
GuildLaunchCT_RaidTracker.hasIcon = "Interface\\Addons\\GuildLaunchCT_RaidTrackerClassic\\rt_icon.tga"
GuildLaunchCT_RaidTracker.cannotDetachTooltip = true
GuildLaunchCT_RaidTracker.cannotHideText = false
CT_RaidTracker_Online = { };

local GPLib = LibStub("LibGearPoints-1.2")

CT_RaidTracker_Version = GetAddOnMetadata("GuildLaunchCT_RaidTrackerClassic", "Version");
CT_RaidTracker_FuBarOptions = { };
CT_RaidTracker_Events = { };
CT_RaidTracker_RaidLog = { };
CT_RaidTracker_WaitList = { };
CT_RaidTracker_GetCurrentRaid = nil;

GuildLaunchCT_RaidTracker:RegisterDB("CT_RaidTracker_FuBarOptions")

CT_RaidTracker_LastPage = { };

CT_RaidTracker_SortOptions = {
    ["method"] = "name",
    ["way"] = "asc",
    ["itemmethod"] = "looted",
    ["itemway"] = "asc",
    ["itemfilter"] = 1,
    ["playerraidway"] = "desc",
    ["playeritemfilter"] = 1,
    ["playeritemmethod"] = "name",
    ["playeritemway"] = "asc",
    ["itemhistorymethod"] = "name",
    ["itemhistoryway"] = "asc"
};

CT_RaidTracker_RarityTable = {
    ["ff9d9d9d"] = 1,
    ["ffffffff"] = 2,
    ["ff1eff00"] = 3,
    ["ff0070dd"] = 4,
    ["ffa335ee"] = 5,
    ["ffff8000"] = 6,
    ["ffe6cc80"] = 7,
};

CT_RaidTracker_ClassTable = {
    ["WARRIOR"] = 1,
    ["ROGUE"] = 2,
    ["HUNTER"] = 3,
    ["PALADIN"] = 4,
    ["SHAMAN"] = 5,
    ["DRUID"] = 6,
    ["WARLOCK"] = 7,
    ["MAGE"] = 8,
    ["PRIEST"] = 9,
    ["DEATHKNIGHT"] = 10,
    ["DEMONHUNTER"] = 11
}

CT_RaidTracker_RaceTable = {
    ["Gnome"] = 1,
    ["Human"] = 2,
    ["Dwarf"] = 3,
    ["NightElf"] = 4,
    ["Troll"] = 5,
    ["Scourge"] = 6, --Undead
    ["Orc"] = 7,
    ["Tauren"] = 8,
    ["Draenei"] = 9,
    ["BloodElf"] = 10,
    ["Goblin"] = 11,
    ["Worgen"] = 12,
    ["Pandaren"] = 13
}

CT_RaidTracker_Options = {
    ["MinQuality"] = 5,         -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
    ["AutoRaidCreation"] = true,   -- on/off
    ["GroupItems"] = 5,         -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
    ["GetDkpValue"] = 7,        -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
    ["AutoBoss"] = 2,           -- 0,1,2
    ["AutoBossBoss"] = "",      -- just the name of the boss
    ["AutoZone"] = true,           -- on/off
    ["AskCost"] = 7,            -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact, asks for cost for items with at least this rarity
    ["Timezone"] = 0,
    ["TimeSync"] = false,
    ["DebugFlag"] = nil,        -- on/off
    ["LogAttendees"] = 1,       -- 0:off, 1:for each looted item, 2:for each bosskill
    ["SaveExtendedPlayerInfo"] = true, -- on/off - save race, class and level
    ["SaveTooltips"] = false,             -- on/off - save tooltips of items
    ["24hFormat"] = true,                    -- on/off - Use 24h time format
    ["AutoBossChangeMinTime"] = 10,    -- how long should trash mob's ignored after a boss kill (minutes)?
    ["Wipe"] = false,                              -- ask if the group dies if it is a wipe, if all are dead it will not ask
    ["WipePercent"] = 0.5,            -- how many prozent of group must be dead to ask
    ["WipeCoolDown"] = 150,            -- how long should death be ignored after a wipe count (seconds)
    ["NextBoss"] = false,                   -- ask on boss kill whats the next boss is
    ["MaxLevel"] = 70,                    -- If player lvl is maxlevel it will not be exported to mldkp
    ["GuildSnapshot"] = false;            -- Snapshots the guildroster on bosskill
    ["ExportFormat"] = 3;                -- ExportFormat for the xml string
    ["NewRaidOnNewZone"] = true; -- Create a new raid if zone get switched
    ["MLdkp"] = 0;
    ["OldFormat"] = 0;
    ["AutoSetEPGPCost"] = false; --oberan added this toggle to auto populate the costs in the edit cost window
    ["NewRaidOnNewZone"] = false; -- Create a new raid if zone get switched
    ["DKPmonLoggingMode"] = false;
    ["LogGroup"] = false;
    ["ShowConfigHelp"] = 1;
    ["ListMeEnabled"] = true; -- indicates whether the listme functionality is enabled // can also be enabled/disabled by command line /rt listme enable|disable
    ["WaitlistAttendanceType"] = 1; -- indicates the style of waitlitst tracking. Current options are whether waitlisted players form the "listme" functionality are included in the boss kill or entered as a seperate "waitlist" event. 1 = include 2 = seperate
    ["BonusLoot"] = false;
};

CT_RaidTracker_Maidens_Yells = {
    ["My... blood..."]          = 1, -- Marak the Blooded
    ["It feels... so..."]       = 2, -- Enforcer Sorka
    ["Sisters, I... failed..."] = 4, -- Admiral Gar'an
};
CT_RaidTracker_Maidens_Status = 0;
CT_RaidTracker_Maidens_Dead = 7;

CT_RaidTracker_HellfireCouncil_Yells = {
	[CT_RaidTracker_lang_BossKills_HellfireCouncil_Gurtogg_Yell]		= 1, --Gurtogg Bloodboil
	[CT_RaidTracker_lang_BossKills_HellfireCouncil_Blademaster_Yell]	= 2, --Blademaster Jubei'thos
	[CT_RaidTracker_lang_BossKills_HellfireCouncil_Dia_Yell]			= 4, --Dia Darkwhisper
};
CT_RaidTracker_HellfireCouncil_Status = 0;
CT_RaidTracker_HellfireCouncil_Dead = 7;	

CT_RaidTracker_Klaxxi_Yells =
{
    ["The hunter... becomes... the hunted..."]                              = 1, -- Hisek the Swarmkeeper
    ["Perhaps I could have used... some enhancements... of my own..."]      = 2, -- Rik'kal the Dissector
    ["Avenge me, brothers!"]                                                = 4, -- Skeer the Bloodseeker
    ["Curse this chitinous shell, I was not fast enough!"]                  = 8, -- Ka'roz the Locust
    ["Return me to the amber..."]                                           = 16, -- Korven the Prime
    ["My calculations, incorrect? Perhaps another 800 years..."]            = 32, -- Iyyokuk the Lucid
    ["I never discovered... how to put a stopper... in death..."]           = 64, -- Xaril the Poisoned Mind
    ["Kovok... Come to me... I need..."]                                    = 128, -- Kaz'tik the Manipulator
    ["Well fought Wakener. We will meet again..."]                          = 256, -- Kaz'tik the Manipulator
};

CT_RaidTracker_Klaxxi_Status = 0;
CT_RaidTracker_Klaxxi_Dead = 511;

CT_RaidTracker_QuickLooter = {"disenchanted", "bank"};

CT_RaidTracker_ExpansionLevel = 3;
CT_RaidTracker_AutoBossChangedTime = 0;
CT_RaidTracker_LastWipe = 0;
CT_RaidTracker_TimeOffsetStatus = nil;
CT_RaidTracker_TimeOffset = 0;
CT_RaidTracker_CustomZoneTriggers = {};
CT_RaidTracker_ItemOptions = {};
CT_RaidTracker_Temp_Boss = {};

-- Ace Options table for the console commands & fubar menu
GuildLaunchCT_RaidTracker.Options = {}

-- Options table for the fubar menu
GuildLaunchCT_RaidTracker.Options.fubar = {
   type = 'group',
   args = {
      showui = {
     type = 'execute',
     name = "Show Raid Tracker Log",
     desc = "Shows the Raid Tracker Log",
     func = function() ShowUIPanel(CT_RaidTrackerFrame) end,
     order = 10
      },
    eventadditions = {
     type = 'group',
     name = "Add Event",
     desc = "This menu allows for manual event addition to the Raid Tracker log",
     args = {
              addevent = {
             type = 'execute',
             name = "Custom Event",
             desc = "Add a custom event to the Raid Tracker log",
             func = function() CT_RaidTracker_ShowAddEventFrame() end
              },
              addattendance = {
             type = 'execute',
             name = "Attendance Event",
             desc = "Adds an attendance event to the Raid Tracker log",
             func = function() CT_RaidTracker_AddAttendance() end
              },
              addwipe = {
             type = 'execute',
             name = "Wipe Event",
             desc = "Adds a wipe event to the Raid Tracker log",
             func = function() CT_RaidTracker_AddWipe() end
             },
        },
     order = 20
      },
    config = {
     type = 'group',
     name = "Configuration",
     desc = "Raid Tracker Configuration Options",
     args = {
         premade = {
         type = 'group',
         name = "Load Preset Configuration",
         desc = "Loads Recommended Configurations for different usage",
         args = {
                standalone = {
                     type = 'group',
                     name = "Standalone Configuration (Standard)",
                     desc = "Raid Tracker Configuration Options for when using Raid Tracker as a standalone mod",
                     args = {
                              standarddefault = {
                             type = 'execute',
                             name = "Load Default",
                             desc = "Loads Default Options - Most users will use this",
                             func = function() CT_RaidTrackerLoadDefaultOptions() end
                              },
                              standardepgp = {
                             type = 'execute',
                             name = "Load EPGP",
                             desc = "Loads Default EPGP Options",
                             func = function() CT_RaidTrackerLoadDefaultEPGPOptions() end
                              },
                        },
                     order = 10
                },
                config = {
                     type = 'group',
                     name = "DKPmon Logging Configuration (Advanced)",
                     desc = "Raid Tracker Configuration Option for when running the Raid Tracker with DKPmon",
                     args = {
                              showitemoptions = {
                             type = 'execute',
                             name = "Load Default",
                             desc = "Show the Raid Tracker item tracking options Screen",
                             func = function() CT_RaidTrackerLoadDefaultDKPmonOptions() end
                              },

                    },
                     order = 20
                  },
            },
         order = 10
          },
              showitemoptions = {
             type = 'execute',
             name = "Show Item Tracking Options",
             desc = "Show the Raid Tracker item tracking options Screen",
             func = function() CT_RaidTrackerItemOptionsFrame:Show() end
              },
              showoptions = {
             type = 'execute',
             name = "Show Current Configuration",
             desc = "Show the main Raid Tracker Options Screen",
             func = function() CT_RaidTrackerOptionsFrame:Show() end
              },
        },
     order = 30
      },
   }
}

function CT_RaidTrackerLoadDefaultOptions()
    CT_RaidTracker_Options =
    {
        ["MinQuality"] = 5,         -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
        ["AutoRaidCreation"] = true,   -- on/off
        ["GroupItems"] = 5,         -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
        ["GetDkpValue"] = 7,        -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
        ["AutoBoss"] = 2,           -- 0,1,2
        ["AutoBossBoss"] = "",      -- just the name of the boss
        ["AutoZone"] = true,           -- on/off
        ["AskCost"] = 7,            -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact, asks for cost for items with at least this rarity
        ["Timezone"] = 0,
        ["TimeSync"] = false,
        ["DebugFlag"] = nil,        -- on/off
        ["LogAttendees"] = 1,       -- 0:off, 1:for each looted item, 2:for each bosskill
        ["SaveExtendedPlayerInfo"] = 1, -- on/off - save race, class and level
        ["SaveTooltips"] = false,             -- on/off - save tooltips of items
        ["24hFormat"] = true,                    -- on/off - Use 24h time format
        ["AutoBossChangeMinTime"] = 10,    -- how long should trash mob's ignored after a boss kill (minutes)?
        ["Wipe"] = false,                              -- ask if the group dies if it is a wipe, if all are dead it will not ask
        ["WipePercent"] = 0.5,            -- how many prozent of group must be dead to ask
        ["WipeCoolDown"] = 150,            -- how long should death be ignored after a wipe count (seconds)
        ["NextBoss"] = false,                   -- ask on boss kill whats the next boss is
        ["MaxLevel"] = 70,                    -- If player lvl is maxlevel it will not be exported to mldkp
        ["GuildSnapshot"] = false;            -- Snapshots the guildroster on bosskill
        ["ExportFormat"] = 3;                -- ExportFormat for the xml string
        ["NewRaidOnNewZone"] = false; -- Create a new raid if zone get switched
        ["MLdkp"] = 0;
        ["OldFormat"] = 0;
        ["AutoSetEPGPCost"] = false; --oberan added this toggle to auto populate the costs in the edit cost window
        ["NewRaidOnNewZone"] = false; -- Create a new raid if zone get switched
        ["DKPmonLoggingMode"] = false; -- Create a new raid if zone get switched
        ["LogGroup"] = false;
        ["ListMeEnabled"] = true; -- indicates whether the listme functionality is enabled // can also be enabled/disabled by command line /rt listme enable|disable
        ["WaitlistAttendanceType"] = 1; -- indicates the style of waitlitst tracking. Current options are whether waitlisted players form the "listme" functionality are included in the boss kill or entered as a seperate "waitlist" event. 1 = include 2 = seperate        
        ["BonusLoot"] = false;
    };
    CT_RaidTrackerOptionsFrame:Show();
end

function CT_RaidTrackerLoadDefaultEPGPOptions()
    CT_RaidTracker_Options =
    {
        ["MinQuality"] = 5,         -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
        ["AutoRaidCreation"] = true,   -- on/off
        ["GroupItems"] = 5,         -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
        ["GetDkpValue"] = 7,        -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
        ["AutoBoss"] = 2,           -- 0,1,2
        ["AutoBossBoss"] = "",      -- just the name of the boss
        ["AutoZone"] = true,           -- on/off
        ["AskCost"] = 7,            -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact, asks for cost for items with at least this rarity
        ["Timezone"] = 0,
        ["TimeSync"] = false,
        ["DebugFlag"] = nil,        -- on/off
        ["LogAttendees"] = 1,       -- 0:off, 1:for each looted item, 2:for each bosskill
        ["SaveExtendedPlayerInfo"] = 1, -- on/off - save race, class and level
        ["SaveTooltips"] = true,             -- on/off - save tooltips of items
        ["24hFormat"] = true,                    -- on/off - Use 24h time format
        ["AutoBossChangeMinTime"] = 10,    -- how long should trash mob's ignored after a boss kill (minutes)?
        ["Wipe"] = false,                              -- ask if the group dies if it is a wipe, if all are dead it will not ask
        ["WipePercent"] = 0.5,            -- how many prozent of group must be dead to ask
        ["WipeCoolDown"] = 150,            -- how long should death be ignored after a wipe count (seconds)
        ["NextBoss"] = false,                   -- ask on boss kill whats the next boss is
        ["MaxLevel"] = 70,                    -- If player lvl is maxlevel it will not be exported to mldkp
        ["GuildSnapshot"] = false;            -- Snapshots the guildroster on bosskill
        ["ExportFormat"] = 3;                -- ExportFormat for the xml string
        ["NewRaidOnNewZone"] = false; -- Create a new raid if zone get switched
        ["MLdkp"] = 0;
        ["OldFormat"] = 0;
        ["AutoSetEPGPCost"] = true; --oberan added this toggle to auto populate the costs in the edit cost window
        ["NewRaidOnNewZone"] = false; -- Create a new raid if zone get switched
        ["DKPmonLoggingMode"] = true; -- Create a new raid if zone get switched
        ["LogGroup"] = false;
        ["ListMeEnabled"] = true; -- indicates whether the listme functionality is enabled // can also be enabled/disabled by command line /rt listme enable|disable
        ["WaitlistAttendanceType"] = 1; -- indicates the style of waitlitst tracking. Current options are whether waitlisted players form the "listme" functionality are included in the boss kill or entered as a seperate "waitlist" event. 1 = include 2 = seperate
        ["BonusLoot"] = false;
    };
    CT_RaidTrackerOptionsFrame:Show();
end

function CT_RaidTrackerLoadDefaultDKPmonOptions()
    CT_RaidTracker_Options =
    {
        ["MinQuality"] = 5,         -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
        ["AutoRaidCreation"] = true,   -- on/off
        ["GroupItems"] = 5,         -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
        ["GetDkpValue"] = 7,        -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact
        ["AutoBoss"] = 2,           -- 0,1,2
        ["AutoBossBoss"] = "",      -- just the name of the boss
        ["AutoZone"] = true,           -- on/off
        ["AskCost"] = 7,            -- 1:poor, 2:common, 3:uncommon, 4:rare, 5:epic, 6:legendary, 7:artifact, asks for cost for items with at least this rarity
        ["Timezone"] = 0,
        ["TimeSync"] = false,
        ["DebugFlag"] = nil,        -- on/off
        ["LogAttendees"] = 1,       -- 0:off, 1:for each looted item, 2:for each bosskill
        ["SaveExtendedPlayerInfo"] = 1, -- on/off - save race, class and level
        ["SaveTooltips"] = false,             -- on/off - save tooltips of items
        ["24hFormat"] = true,                    -- on/off - Use 24h time format
        ["AutoBossChangeMinTime"] = 10,    -- how long should trash mob's ignored after a boss kill (minutes)?
        ["Wipe"] = false,                              -- ask if the group dies if it is a wipe, if all are dead it will not ask
        ["WipePercent"] = 0.5,            -- how many prozent of group must be dead to ask
        ["WipeCoolDown"] = 150,            -- how long should death be ignored after a wipe count (seconds)
        ["NextBoss"] = false,                   -- ask on boss kill whats the next boss is
        ["MaxLevel"] = 70,                    -- If player lvl is maxlevel it will not be exported to mldkp
        ["GuildSnapshot"] = false;            -- Snapshots the guildroster on bosskill
        ["ExportFormat"] = 3;                -- ExportFormat for the xml string
        ["NewRaidOnNewZone"] = false; -- Create a new raid if zone get switched
        ["MLdkp"] = 0;
        ["OldFormat"] = 0;
        ["AutoSetEPGPCost"] = false; --oberan added this toggle to auto populate the costs in the edit cost window
        ["NewRaidOnNewZone"] = false; -- Create a new raid if zone get switched
        ["DKPmonLoggingMode"] = true; -- Create a new raid if zone get switched
        ["ListMeEnabled"] = true; -- indicates whether the listme functionality is enabled // can also be enabled/disabled by command line /rt listme enable|disable
        ["WaitlistAttendanceType"] = 1; -- indicates the style of waitlitst tracking. Current options are whether waitlisted players form the "listme" functionality are included in the boss kill or entered as a seperate "waitlist" event. 1 = include 2 = seperate
        ["LogGroup"] = false;
        ["BonusLoot"] = false;  --true tacks bonus loot false does not
    };
    CT_RaidTrackerOptionsFrame:Show();
end

function GuildLaunchCT_RaidTracker:OnInitialize()
       GuildLaunchCT_RaidTracker.OnMenuRequest = GuildLaunchCT_RaidTracker.Options.fubar
end

--[[
Called when icon is left-clicked
Shows raid tracker window
]]
function GuildLaunchCT_RaidTracker:OnClick()
    ShowUIPanel(CT_RaidTrackerFrame);
end

function CT_RaidTracker_RunVersionFix()
    local debugflagpre = CT_RaidTracker_Options["DebugFlag"];
    --CT_RaidTracker_Options["DebugFlag"] = 1;
    if(not CT_RaidTracker_VersionFix) then
        CT_RaidTracker_Debug("VersionFix", 1);
        for k, v in pairs(CT_RaidTracker_RaidLog) do
            if(not CT_RaidTracker_RaidLog[k]["PlayerInfos"]) then
                CT_RaidTracker_RaidLog[k]["PlayerInfos"] = { };
            end
            if ( v["Notes"] ) then
                for notesk, notesv in pairs(v["Notes"]) do
                    if(not CT_RaidTracker_RaidLog[k]["PlayerInfos"][notesk]) then
                        CT_RaidTracker_RaidLog[k]["PlayerInfos"][notesk] = { };
                    end
                    CT_RaidTracker_RaidLog[k]["PlayerInfos"][notesk]["note"] = notesv;
                    CT_RaidTracker_Debug("VersionFix", 1, "note", k, notesk, notesv);
                end
                CT_RaidTracker_RaidLog[k]["Notes"] = nil;
            end
        end
        CT_RaidTracker_VersionFix = 1;
    end
    if(CT_RaidTracker_VersionFix == 1) then
        CT_RaidTracker_Debug("VersionFix", 2);
        CT_RaidTracker_VersionFix = 2; -- Do not remove tooltips any longer
    end
    if(CT_RaidTracker_VersionFix == 2) then
        CT_RaidTracker_Debug("VersionFix", 3);
        if(CT_RaidTracker_MinQuality) then CT_RaidTracker_Options["MinQuality"] = CT_RaidTracker_MinQuality; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_MinQuality", CT_RaidTracker_MinQuality); end
        if(CT_RaidTracker_AutoRaidCreation) then CT_RaidTracker_Options["AutoRaidCreation"] = CT_RaidTracker_AutoRaidCreation; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_AutoRaidCreation", CT_RaidTracker_AutoRaidCreation); end
        if(CT_RaidTracker_GroupItems) then CT_RaidTracker_Options["GroupItems"] = CT_RaidTracker_GroupItems; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_GroupItems", CT_RaidTracker_GroupItems); end
        if(CT_RaidTracker_GetDkpValue) then CT_RaidTracker_Options["GetDkpValue"] = CT_RaidTracker_GetDkpValue; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_GetDkpValue", CT_RaidTracker_GetDkpValue); end
        if(CT_RaidTracker_OldFormat) then CT_RaidTracker_Options["OldFormat"] = CT_RaidTracker_OldFormat; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_OldFormat", CT_RaidTracker_OldFormat); end
        if(CT_RaidTracker_AutoBoss) then CT_RaidTracker_Options["AutoBoss"] = CT_RaidTracker_AutoBoss; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_AutoBoss", CT_RaidTracker_AutoBoss); end
        if(CT_RaidTracker_AutoBossBoss) then CT_RaidTracker_Options["AutoBossBoss"] = CT_RaidTracker_AutoBossBoss; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_AutoBossBoss", CT_RaidTracker_AutoBossBoss); end
        if(CT_RaidTracker_AutoZone) then CT_RaidTracker_Options["AutoZone"] = CT_RaidTracker_AutoZone; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_AutoZone", CT_RaidTracker_AutoZone); end
        if(CT_RaidTracker_AskCosts) then CT_RaidTracker_Options["AskCost"] = CT_RaidTracker_AskCosts; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_AskCosts", CT_RaidTracker_AskCosts); end
        if(CT_RaidTracker_Timezone) then CT_RaidTracker_Options["Timezone"] = CT_RaidTracker_Timezone; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_Timezone", CT_RaidTracker_Timezone); end
        if(CT_RaidTracker_TimeSync) then CT_RaidTracker_Options["TimeSync"] = CT_RaidTracker_TimeSync; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_TimeSync", CT_RaidTracker_TimeSync); end
        if(CT_RaidTracker_DebugFlag) then CT_RaidTracker_Options["DebugFlag"] = CT_RaidTracker_DebugFlag; CT_RaidTracker_Debug("VersionFix", 3, "CT_RaidTracker_DebugFlag", CT_RaidTracker_DebugFlag); end

        for k, v in pairs(CT_RaidTracker_RaidLog) do
            if(CT_RaidTracker_RaidLog[k]["BossKills"] and getn(CT_RaidTracker_RaidLog[k]["BossKills"]) >= 1 and not CT_RaidTracker_RaidLog[k]["BossKills"][1]) then
                local tempbosskills = {};
                for k2, v2 in pairs(CT_RaidTracker_RaidLog[k]["BossKills"]) do
                    tempbosskills[k2] = v2;
                end
                CT_RaidTracker_RaidLog[k]["BossKills"] = {};
                for k2, v2 in pairs(tempbosskills) do
                    tinsert(CT_RaidTracker_RaidLog[k]["BossKills"],
                        {
                            ["boss"] = k2,
                            ["time"] = v2,
                            ["attendees"] = {}
                        }
                    );
                    CT_RaidTracker_Debug("VersionFix", 3, "BossKills", k, k2);
                end
            end
        end
        CT_RaidTracker_VersionFix = 3;
    end
    if(CT_RaidTracker_VersionFix == 3) then
        CT_RaidTracker_Debug("VersionFix", 4);
        for k, v in pairs(CT_RaidTracker_RaidLog) do
            if(CT_RaidTracker_RaidLog[k]["BossKills"]) then
                for k2, v2 in pairs(CT_RaidTracker_RaidLog[k]["BossKills"]) do
                    if(type(v2["time"]) == "table") then
                        CT_RaidTracker_Debug("VersionFix", 4, "BossKills Fix", k, k2, v2["time"]["boss"], v2["time"]["time"]);
                        CT_RaidTracker_RaidLog[k]["BossKills"][k2]["boss"] = v2["time"]["boss"];
                        CT_RaidTracker_RaidLog[k]["BossKills"][k2]["attendees"] = v2["time"]["attendees"];
                        CT_RaidTracker_RaidLog[k]["BossKills"][k2]["time"] = v2["time"]["time"];
                    end
                end
            end
        end
        CT_RaidTracker_VersionFix = 4;
    end
    if(CT_RaidTracker_VersionFix == 4) then
        CT_RaidTracker_Options["Wipe"] = false;                              -- ask if the group dies if it is a wipe, if all are dead it will not ask
        CT_RaidTracker_Options["WipePercent"] = 0.5;            -- how many prozent of group must be dead to ask
    CT_RaidTracker_Options["WipeCoolDown"] = 150;            -- how long should death be ignored after a wipe count (seconds)
        CT_RaidTracker_Options["NextBoss"] = true;                  -- ask on boss kill whats the next boss is

        CT_RaidTracker_VersionFix = 5;
    end

    if (CT_RaidTracker_VersionFix == 5) then
        CT_RaidTracker_Options["MaxLevel"] = 70;  -- If player lvl is maxlevel it will not be exported to mldkp
        CT_RaidTracker_Options["MLdkp"] = 0;             -- Export für mldkp
        CT_RaidTracker_Options["GuildSnapshot"] = false; -- Snapshots the guildroster on bosskill

        CT_RaidTracker_VersionFix = 6;
    end;

    if (CT_RaidTracker_VersionFix == 6) then
        if (CT_RaidTracker_Options["MLdkp"] and CT_RaidTracker_Options["MLdkp"] == 1) then
            CT_RaidTracker_Options["ExportFormat"] = 2;
        else
            if (CT_RaidTracker_Options["OldFormat"] and CT_RaidTracker_Options["OldFormat"] == 1) then
                CT_RaidTracker_Options["ExportFormat"] = 0;
            else
                CT_RaidTracker_Options["ExportFormat"] = 3;
            end;
        end;
        CT_RaidTracker_Options["MLdkp"] = nil;
        CT_RaidTracker_Options["OldFormat"] = nil;
        CT_RaidTracker_VersionFix = 7;
        CT_RaidTrackerOptionsFrame:Show();
    end;

    if (CT_RaidTracker_VersionFix == 7) then
        CT_RaidTracker_Options["NewRaidOnNewZone"] = 0;
        CT_RaidTracker_Options["AutoBossChangeMinTime"] = 10;
        --,32227,32228,32229,32230,32231,32249
        for _,idtoadd in pairs({29434,22450,40752,40753,34057}) do
            local idfound = false;
            for key, val in pairs(CT_RaidTracker_ItemOptions) do
                if(val["id"] == idtoadd) then
                    idfound = true;
                end;
            end;
            if (idfound == false) then
                tinsert(CT_RaidTracker_ItemOptions,{
                ["id"] = idtoadd,
                ["name"] = GetItemInfo(idtoadd),
                ["status"] = false,
                ["quality"] = 4,
                });
            end;
        end;


        CT_RaidTracker_VersionFix = 8;
        CT_RaidTrackerOptionsFrame:Show();
    end;

    if (CT_RaidTracker_VersionFix == 8) then
        --adds Emblem of Heroism, Emblem of Valor and Abyss Crystal to ignore list
        for _,idtoadd in pairs({40752,40753,34057}) do
            local idfound = false;
            for key, val in pairs(CT_RaidTracker_ItemOptions) do
                if(val["id"] == idtoadd) then
                    idfound = true;
                end;
            end;
            if (idfound == false) then
                tinsert(CT_RaidTracker_ItemOptions,{
                ["id"] = idtoadd,
                ["name"] = GetItemInfo(idtoadd),
                ["status"] = false,
                ["quality"] = 4,
                });
            end;
        end;


        CT_RaidTracker_VersionFix = 9;
        CT_RaidTrackerOptionsFrame:Show();
    end;

    if (CT_RaidTracker_VersionFix == 9) then
        -- sets the export format to the guild launch format
        CT_RaidTracker_Options["ExportFormat"] = 3;
        CT_RaidTracker_Options["LogAttendees"] = 1;
        CT_RaidTracker_Options["TimeSync"] = 0;
            CT_RaidTracker_Options["Wipe"] = true;
        CT_RaidTracker_Options["NextBoss"] = false;

        CT_RaidTracker_VersionFix = 10;
        CT_RaidTrackerOptionsFrame:Show();
    end;

    if (CT_RaidTracker_VersionFix == 10) then
        -- sets DKPmonLoggingMode to the default value
        CT_RaidTracker_Options["DKPmonLoggingMode"] = true;

        CT_RaidTracker_VersionFix = 11;
        CT_RaidTrackerOptionsFrame:Show();
    end;

    if (CT_RaidTracker_VersionFix == 11) then
        -- sets the config help setting to the default value
        CT_RaidTracker_Options["ShowConfigHelp"] = 1;

        CT_RaidTracker_VersionFix = 12;
        CT_RaidTrackerOptionsFrame:Show();
    end;


    if (CT_RaidTracker_VersionFix == 12) then
        --adds Emblem of Heroism, Emblem of Valor and Abyss Crystal to ignore list
        for _,idtoadd in pairs({20725,30320,30317,30316,30312,30319,30318,30314,30313,30311}) do
            local idfound = false;
            for key, val in pairs(CT_RaidTracker_ItemOptions) do
                if(val["id"] == idtoadd) then
                    idfound = true;
                end;
            end;
            if (idfound == false) then
                tinsert(CT_RaidTracker_ItemOptions,{
                ["id"] = idtoadd,
                ["name"] = GetItemInfo(idtoadd),
                ["status"] = false,
                ["quality"] = 4,
                });
            end;
        end;


        CT_RaidTracker_VersionFix = 13;
        CT_RaidTrackerOptionsFrame:Show();
    end;
    
    if (CT_RaidTracker_VersionFix == 13) then
        CT_RaidTracker_Options["ListMeEnabled"] = true;
        --print ("version 14 fired")
        CT_RaidTracker_VersionFix = 14;
        CT_RaidTrackerOptionsFrame:Show();
    end;
    
    if (CT_RaidTracker_VersionFix == 14) then
        CT_RaidTracker_Options["WaitlistAttendanceType"] = 1;
        
        CT_RaidTracker_VersionFix = 15;
		--print ("version 15 fired")
        CT_RaidTrackerOptionsFrame:Show();
    end;    

    CT_RaidTracker_Options["DebugFlag"] = debugflagpre;
end

function ML_RaidTracker_LoadCustomOptions()
    if ( ML_RaidTracker_Custom_Options ~= nil ) then
        for key, val in pairs(ML_RaidTracker_Custom_Options) do
            CT_RaidTracker_Options[key] = val;
        end;
    end;
end;

function CT_RaidTracker_GetTime(dDate)
    if ( not dDate ) then
        return nil;
    end
    local _, _, mon, day, year, hr, min, sec = string.find(dDate, "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)");
    local table = date("*t", time());
    local timestamp;
    table["month"] = tonumber(mon);
    table["year"] = tonumber("20" .. year);
    table["day"] = tonumber(day);
    table["hour"] = tonumber(hr);
    table["min"] = tonumber(min);
    table["sec"] = tonumber(sec);
    timestamp = time(table);
    --[[
    table = date("*t", timestamp);
    if(table["isdst"]) then
        timestamp = timestamp - 3600;
    end
    ]]
    return timestamp;
end

function CT_RaidTracker_SortRaidTable()
    table.sort(
        CT_RaidTracker_RaidLog,
        function(a1, a2)
            if ( a1 and a2 ) then
                return CT_RaidTracker_GetTime(a1.key) > CT_RaidTracker_GetTime(a2.key);
            end
        end
    );
end

function CT_RaidTracker_GameTimeFrame_Update(self)
    CT_RaidTracker_GameTimeFrame_Update_Original(self);
    local hour, minute = GetGameTime();
    local time = ((hour * 60) + minute) * 60;
    if(not CT_RaidTracker_TimeOffsetStatus) then
        CT_RaidTracker_TimeOffsetStatus = time;
    elseif(CT_RaidTracker_TimeOffsetStatus ~= time) then
        local ltimea = date("*t");
        local ltime = (((ltimea["hour"] * 60) + ltimea["min"]) * 60 + ltimea["sec"]) + (CT_RaidTracker_Options["Timezone"] * 3600);
        local timediff;
        if(time > ltime) then
            timediff = time - ltime;
            if(timediff >= 43200) then
                CT_RaidTracker_TimeOffset = timediff - 86400;
            else
                CT_RaidTracker_TimeOffset = timediff;
            end
        elseif(time < ltime) then
            timediff = ltime - time;
            if(timediff >= 43200) then
                CT_RaidTracker_TimeOffset = 86400 - timediff;
            else
                CT_RaidTracker_TimeOffset = timediff * -1;
            end
        else
            CT_RaidTracker_TimeOffset = 0;
        end
        CT_RaidTracker_Debug("CT_RaidTracker_TimeOffset", CT_RaidTracker_TimeOffset);
        GameTimeFrame_Update = CT_RaidTracker_GameTimeFrame_Update_Original;
        CT_RaidTracker_TimeOffsetStatus = nil;
    end
end

function CT_RaidTracker_GetGameTimeOffset()
    if(CT_RaidTracker_TimeOffsetStatus) then
        return;
    end
    if(not CT_RaidTracker_GameTimeFrame_Update_Original) then
        CT_RaidTracker_GameTimeFrame_Update_Original = GameTimeFrame_Update;
    end
    GameTimeFrame_Update = CT_RaidTracker_GameTimeFrame_Update;
    return;
end

function CT_RaidTracker_GetRaidTitle(id, hideid, showzone, shortdate)
    local RaidTitle = "";
    if ( CT_RaidTracker_RaidLog[id] and CT_RaidTracker_RaidLog[id].key ) then
        local _, _, mon, day, year, hr, min, sec = string.find(CT_RaidTracker_RaidLog[id].key, "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)");
        if ( mon ) then
            local months = {
                "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
            };
            if ( not hideid ) then
                RaidTitle = RaidTitle .. "[" .. (getn(CT_RaidTracker_RaidLog)-id+1) .. "] ";
            end
            if ( not shortdate ) then
                RaidTitle = RaidTitle .. months[tonumber(mon)] .. " " .. day .. " '" .. year .. ", " .. hr .. ":" .. min;
            else
                RaidTitle = RaidTitle .. mon .. "/" .. day .. " " .. hr .. ":" .. min;
            end
            if ( showzone and CT_RaidTracker_RaidLog[id].zone) then
                RaidTitle = RaidTitle .. " " .. CT_RaidTracker_RaidLog[id].zone;
            end
            return RaidTitle;
        else
            return "";
        end
    end
    return "";
end

function CT_RaidTracker_GetLootId(raidid, sPlayer, sItem, sTime)
    CT_RaidTracker_Debug("CT_RaidTracker_GetLootId", raidid, sPlayer, sItem, sTime);
    local lootid = nil;
    for key, val in pairs(CT_RaidTracker_RaidLog[raidid]["Loot"]) do
        if(val["player"] == sPlayer and val["item"]["id"] == sItem and val["time"] == sTime) then
            lootid = key;
            break;
        end
    end
    return lootid;
end

function CT_RaidTracker_Update()
    if(CT_RaidTracker_GetCurrentRaid) then
      CT_RaidTrackerFrameEndRaidButton:Enable();
      CT_RaidTrackerFrameSnapshotButton:Enable();
    else
        CT_RaidTrackerFrameEndRaidButton:Disable();
        CT_RaidTrackerFrameSnapshotButton:Disable();
    end

    if(IsInRaid() == true) then
        CT_RaidTrackerFrameNewRaidButton:Enable();
    else
      if((GetNumGroupMembers() > 0) and (CT_RaidTracker_Options["LogGroup"] == true)) then
        CT_RaidTrackerFrameNewRaidButton:Enable();
      else
        CT_RaidTrackerFrameNewRaidButton:Disable();
      end;
    end;

    --[[
    if ( CT_RaidTrackerFrame.selected ) then
        CT_RaidTrackerFrameView2Button:Enable();
    else
        CT_RaidTrackerFrameView2Button:Disable();
    end
    ]]

    if ( getn(CT_RaidTracker_LastPage) > 0 ) then
        CT_RaidTrackerFrameBackButton:Enable();
    else
        CT_RaidTrackerFrameBackButton:Disable();
    end
    if ( getn(CT_RaidTracker_RaidLog) > 0 ) then
        if ( CT_RaidTrackerFrame.selected ) then
            local selected;
            if ( not CT_RaidTracker_RaidLog[CT_RaidTrackerFrame.selected] ) then
                while ( not selected ) do
                    if ( CT_RaidTrackerFrame.selected < 1 ) then
                        selected = 1;
                        CT_RaidTrackerFrame.selected = nil;
                    else
                        CT_RaidTrackerFrame.selected = CT_RaidTrackerFrame.selected - 1;
                        if ( CT_RaidTracker_RaidLog[CT_RaidTrackerFrame.selected] ) then
                            selected = 2;
                        end
                    end
                end
            end
            if ( not selected or selected == 2 ) then
                if ( not CT_RaidTracker_RaidLog[CT_RaidTrackerFrame.selected] or getn(CT_RaidTracker_RaidLog[CT_RaidTrackerFrame.selected]["Loot"]) == 0 ) then
                    CT_RaidTrackerFrame.type = "raids";
                    CT_RaidTrackerFrameViewButton:Disable();
                else
                    CT_RaidTrackerFrameViewButton:Enable();
                end
            end
        end

        CT_EmptyRaidTrackerFrame:Hide();
        CT_RaidTrackerFrameDeleteButton:Enable();

        local hasItem;
        for k, v in pairs(CT_RaidTracker_RaidLog) do
            for key, val in pairs(v["Loot"]) do
                if ( val["player"] == CT_RaidTrackerFrame.player ) then
                    hasItem = 1;
                    break;
                end
            end
            if ( hasItem ) then
                break;
            end
        end

        if ( CT_RaidTrackerFrame.type == "raids" or not CT_RaidTrackerFrame.type ) then
            CT_RaidTrackerFrameViewButton:SetText("View Items");
        elseif ( CT_RaidTrackerFrame.type == "items" ) then
            CT_RaidTrackerFrameViewButton:SetText("View Players");
        elseif ( CT_RaidTrackerFrame.type == "player" ) then
            if ( not hasItem ) then
                CT_RaidTrackerFrameViewButton:Disable();
            else
                CT_RaidTrackerFrameViewButton:Enable();
            end
            CT_RaidTrackerFrameViewButton:SetText("View Loot");
            CT_RaidTrackerFrameDeleteButton:Disable();
        elseif ( CT_RaidTrackerFrame.type == "playeritems" ) then
            CT_RaidTrackerFrameViewButton:SetText("View Raids");
            CT_RaidTrackerFrameDeleteButton:Disable();
            if ( not hasItem ) then
                CT_RaidTrackerFrame.type = "player";
                CT_RaidTracker_Update();
                CT_RaidTracker_UpdateView();
            end
        elseif ( CT_RaidTrackerFrame.type == "itemhistory" ) then
            CT_RaidTrackerFrameDeleteButton:Disable();
            CT_RaidTrackerFrameViewButton:Disable();
        elseif ( CT_RaidTrackerFrame.type == "events" ) then
            CT_RaidTrackerFrameDeleteButton:Disable();
            CT_RaidTrackerFrameViewButton:Disable();
        end
    else
        CT_EmptyRaidTrackerFrame:Show();
        CT_RaidTrackerDetailScrollFramePlayers:Hide();
        CT_RaidTrackerDetailScrollFrameItems:Hide();
        CT_RaidTrackerDetailScrollFramePlayer:Hide();
        CT_RaidTrackerDetailScrollFrameEvents:Hide();
        CT_RaidTrackerFrameDeleteButton:Disable();
        CT_RaidTrackerFrameViewButton:Disable();
    end

    local numRaids = getn(CT_RaidTracker_RaidLog);
    local numEntries = numRaids;

    -- ScrollFrame update
    FauxScrollFrame_Update(CT_RaidTrackerListScrollFrame, numEntries, 6, 16, nil, nil, nil, CT_RaidTrackerHighlightFrame, 293, 316 );

    CT_RaidTrackerHighlightFrame:Hide();
    for i=1, 6, 1 do
        local title = getglobal("CT_RaidTrackerTitle" .. i);
        local normaltext = getglobal("CT_RaidTrackerTitle" .. i .. "NormalText");
        local highlighttext = getglobal("CT_RaidTrackerTitle" .. i .. "HighlightText");
        local disabledtext = getglobal("CT_RaidTrackerTitle" .. i .. "DisabledText");
        local highlight = getglobal("CT_RaidTrackerTitle" .. i .. "Highlight");

        local index = i + FauxScrollFrame_GetOffset(CT_RaidTrackerListScrollFrame);
        if ( index <= numEntries ) then
            local raidTitle = CT_RaidTracker_GetRaidTitle(index, nil, 1, 1);
            local raidTag = CT_RaidTracker_RaidLog[index]["note"];
            if ( not raidTag ) then
                raidTag = "";
            else
                raidTag = " (" .. raidTag .. ")";
            end
            if ( raidTitle ) then
                title:SetText(raidTitle .. raidTag);
            else
                title:SetText("");
            end
            title:Show();
            -- Place the highlight and lock the highlight state
            if ( CT_RaidTrackerFrame.selected and CT_RaidTrackerFrame.selected == index ) then
                CT_RaidTrackerSkillHighlight:SetVertexColor(1, 1, 0);
                CT_RaidTrackerHighlightFrame:SetPoint("TOPLEFT", "CT_RaidTrackerTitle"..i, "TOPLEFT", 0, 0);
                CT_RaidTrackerHighlightFrame:Show();
                title:LockHighlight();
            else
                title:UnlockHighlight();
            end

        else
            title:Hide();
        end

    end
end

function CT_RaidTracker_SelectRaid(id)
    local raidid = id + FauxScrollFrame_GetOffset(CT_RaidTrackerListScrollFrame);
    CT_RaidTracker_GetPage();
    CT_RaidTrackerFrame.selected = raidid;
    --if ( getn(CT_RaidTracker_RaidLog[raidid]["Loot"]) == 0 or ( CT_RaidTrackerFrame.type and CT_RaidTrackerFrame.type ~= "items" ) ) then
        CT_RaidTrackerFrame.type = "raids";
    --end

    CT_RaidTracker_UpdateView();
    CT_RaidTracker_Update();
end

function CT_RaidTracker_ShowInfo(player)
    CT_RaidTracker_GetPage();

    CT_RaidTrackerFrame.type = "player";
    CT_RaidTrackerFrame.player = player;
    CT_RaidTrackerFrame.selected = nil;

    CT_RaidTracker_Update();
    CT_RaidTracker_UpdateView();
end

function CT_RaidTracker_Delete(self, id, delete_type, typeid)
    CT_RaidTracker_Debug("DELETE", delete_type, typeid);
    if ( delete_type == "raid" ) then
        table.remove(CT_RaidTracker_RaidLog, id);
        if ( id == CT_RaidTracker_GetCurrentRaid ) then
            CT_RaidTracker_GetCurrentRaid = nil;
        end
        if ( CT_RaidTrackerFrame.selected == id ) then
            CT_RaidTrackerFrame.selected = CT_RaidTrackerFrame.selected - 1;
            if ( CT_RaidTrackerFrame.selected < 1 ) then
                CT_RaidTrackerFrame.selected = 1;
            end
            CT_RaidTrackerFrame.type = "raids";
        end
    elseif ( delete_type == "item" ) then
        local itemplayer, itemitemid, itemtime;
        itemplayer = self:GetParent().itemplayer;
        itemitemid = self:GetParent().itemitemid;
        itemtime = self:GetParent().itemtime;
        local lootid = CT_RaidTracker_GetLootId(id, itemplayer, itemitemid, itemtime);
        table.remove(CT_RaidTracker_RaidLog[id]["Loot"], lootid);
    elseif ( delete_type == "player" ) then
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["Join"]) do
            if ( val["player"] == typeid ) then
                CT_RaidTracker_Debug("DELETE", "JOIN", "FOUND PLAYER", key, val["player"]);
                CT_RaidTracker_RaidLog[id]["Join"][key] = nil;
            end
        end
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["Leave"]) do
            if ( val["player"] == typeid ) then
                CT_RaidTracker_Debug("DELETE", "LEAVE", "FOUND PLAYER", key, val["player"]);
                CT_RaidTracker_RaidLog[id]["Leave"][key] = nil;
            end
        end
        if(id == CT_RaidTracker_GetCurrentRaid) then
            CT_RaidTracker_Online[typeid] = nil;
        end
        if(CT_RaidTracker_RaidLog[id]["PlayerInfos"]) then
            CT_RaidTracker_RaidLog[id]["PlayerInfos"][typeid] = nil;
        end
    end
    CT_RaidTracker_Update();
    CT_RaidTracker_UpdateView();
end

function CT_RaidTracker_Sort(tbl, method, way)
    if ( way == "asc" ) then
        table.sort(
            tbl,
            function(a1, a2)
                return a1[method] < a2[method];
            end
        );
    else
        table.sort(
            tbl,
            function(a1, a2)
                return a1[method] > a2[method];
            end
        );
    end
    return tbl;
end

function CT_RaidTracker_SortPlayerRaids(id)
    if ( CT_RaidTrackerFrame.type == "itemhistory" ) then
        local table = { "name", "looter" };

        if ( CT_RaidTracker_SortOptions["itemhistorymethod"] == table[id] ) then
            if ( CT_RaidTracker_SortOptions["itemhistoryway"] == "asc" ) then
                CT_RaidTracker_SortOptions["itemhistoryway"] = "desc";
            else
                CT_RaidTracker_SortOptions["itemhistoryway"] = "asc";
            end
        else
            CT_RaidTracker_SortOptions["itemhistoryway"] = "asc";
            CT_RaidTracker_SortOptions["itemhistorymethod"] = table[id];
        end
    else
        if ( CT_RaidTracker_SortOptions["playerraidway"] == "asc" ) then
            CT_RaidTracker_SortOptions["playerraidway"] = "desc";
        else
            CT_RaidTracker_SortOptions["playerraidway"] = "asc";
        end
    end
    CT_RaidTracker_UpdateView();
end

function CT_RaidTracker_CompareItems(a1, a2)
    -- This function could probably be better, but I can't think of any better way while still maintaining functionality

    local filter, method, way = CT_RaidTracker_SortOptions["itemfilter"], CT_RaidTracker_SortOptions["itemmethod"], CT_RaidTracker_SortOptions["itemway"];
    if ( CT_RaidTrackerFrame.type == "playeritems" ) then
        filter, method, way = CT_RaidTracker_SortOptions["playeritemfilter"], CT_RaidTracker_SortOptions["playeritemmethod"], CT_RaidTracker_SortOptions["playeritemway"];
    end

    -- Check to see if it matches the rarity requirements
    --CT_RaidTracker_Debug(a2["item"]["c"]);
    if ( CT_RaidTracker_RarityTable[a1["item"]["c"]] < filter ) then
        return false;
    elseif ( CT_RaidTracker_RarityTable[a2["item"]["c"]] < filter ) then
        return true;
    end

    if ( method == "name" ) then
        local c1, c2 = a1["item"]["name"], a2["item"]["name"];
        if ( c1 == c2 ) then
            c1, c2 = a1["player"], a2["player"];
        end
        if ( way == "asc" ) then
            return c1 < c2;
        else
            return c1 > c2;
        end
    elseif ( method == "looter" ) then
        local c1, c2 = a1["player"], a2["player"];
        if ( c1 == c2 ) then
            c1, c2 = CT_RaidTracker_RarityTable[a2["item"]["c"]], CT_RaidTracker_RarityTable[a1["item"]["c"]];
            if ( c1 == c2 ) then
                c1, c2 = a1["item"]["name"], a2["item"]["name"];
            end
        end
        if ( way == "asc" ) then
            return c1 < c2;
        else
            return c1 > c2;
        end
    elseif ( method == "looted" ) then
        if ( way == "asc" ) then
            return CT_RaidTracker_GetTime(a1["time"]) < CT_RaidTracker_GetTime(a2["time"]);
        else
            return CT_RaidTracker_GetTime(a1["time"]) > CT_RaidTracker_GetTime(a2["time"]);
        end
    else
        local c1, c2 = CT_RaidTracker_RarityTable[a1["item"]["c"]], CT_RaidTracker_RarityTable[a2["item"]["c"]];
        if ( c1 == c2 ) then
            c1, c2 = a1["item"]["name"], a2["item"]["name"];
            if ( c1 == c2 ) then
                c1, c2 = a1["player"], a2["player"];
            else
                return c1 < c2;
            end
        end
        if ( way == "asc" ) then
            return c1 < c2;
        else
            return c1 > c2;
        end
    end
end

function CT_RaidTracker_SortItem(tbl, method, way)
    table.sort(
        tbl,
        CT_RaidTracker_CompareItems
    );
    local newtable = {}
    for key, val in pairs(tbl) do
        newtable[key] = val;
    end
    return newtable;
end

function CT_RaidTracker_SortItemBy(id)
    local table = { "name", "looted", "looter", "rarity" };
    local prefix = "";
    if ( CT_RaidTrackerFrame.type == "playeritems" ) then
        prefix = "player";
    end
    if ( CT_RaidTracker_SortOptions[prefix.."itemmethod"] == table[id] ) then
        if ( CT_RaidTracker_SortOptions[prefix.."itemway"] == "asc" ) then
            CT_RaidTracker_SortOptions[prefix.."itemway"] = "desc";
        else
            CT_RaidTracker_SortOptions[prefix.."itemway"] = "asc";
        end
    else
        CT_RaidTracker_SortOptions[prefix.."itemmethod"] = table[id];
        CT_RaidTracker_SortOptions[prefix.."itemway"] = "asc";
    end
    CT_RaidTracker_UpdateView();
end

function CT_RaidTracker_SortBy(id)
    local table = { "name", "join", "leave" };
    if ( CT_RaidTracker_SortOptions["method"] == table[id] ) then
        if ( CT_RaidTracker_SortOptions["way"] == "asc" ) then
            CT_RaidTracker_SortOptions["way"] = "desc";
        else
            CT_RaidTracker_SortOptions["way"] = "asc";
        end
    else
        CT_RaidTracker_SortOptions["method"] = table[id];
        if ( table[id] ~= "leave" ) then
            CT_RaidTracker_SortOptions["way"] = "asc";
        else
            CT_RaidTracker_SortOptions["way"] = "desc";
        end
    end
    CT_RaidTracker_UpdateView();
end

function CT_RaidTracker_UpdateView()
    if ( CT_EmptyRaidTrackerFrame:IsVisible() ) then
        return;
    end
    local raidid = CT_RaidTrackerFrame.selected;

    if (CT_RaidTracker_RaidLog[raidid] == nil) then
        raidid = nil;
    end;

    if(CT_RaidTrackerFrame.type == "events") then
        CT_RaidTrackerFrameView2Button:SetText("View Raid");
  else
      CT_RaidTrackerFrameView2Button:SetText("View Events");
      if(not raidid or ((not CT_RaidTracker_RaidLog[raidid]["BossKills"] or getn(CT_RaidTracker_RaidLog[raidid]["BossKills"]) == 0) and (not CT_RaidTracker_RaidLog[raidid]["Events"] or getn(CT_RaidTracker_RaidLog[raidid]["Events"]) == 0))) then
          CT_RaidTrackerFrameView2Button:Disable();
      else
          CT_RaidTrackerFrameView2Button:Enable();
      end
  end
    if ( CT_RaidTrackerFrame.type == "raids" or not CT_RaidTrackerFrame.type ) then
        CT_RaidTrackerDetailScrollFramePlayers:Show();
        CT_RaidTrackerDetailScrollFramePlayer:Hide();
        CT_RaidTrackerDetailScrollFrameItems:Hide();
        CT_RaidTrackerDetailScrollFrameEvents:Hide();
        local players = { };
        if ( CT_RaidTracker_RaidLog[raidid] ) then

            local playerIndexes = { };
            for key, val in pairs(CT_RaidTracker_RaidLog[raidid]["Join"]) do
                if ( val["player"] ) then
                    local id = playerIndexes[val["player"]];
                    local time = CT_RaidTracker_GetTime(val["time"]);
                    if ( not id or time < players[id]["join"] ) then
                        if ( playerIndexes[val["player"]] ) then
                            players[id] = {
                                ["join"] = time,
                                ["name"] = val["player"]
                            };
                        else
                            tinsert(players, {
                                ["join"] = time,
                                ["name"] = val["player"]
                            });
                            playerIndexes[val["player"]] = getn(players);
                        end
                    end
                    id = playerIndexes[val["player"]];
                    if ( not players[id]["lastjoin"] or players[id]["lastjoin"] < time ) then
                        players[id]["lastjoin"] = time;
                    end
                end
            end
            for key, val in pairs(CT_RaidTracker_RaidLog[raidid]["Leave"]) do
                local id = playerIndexes[val["player"]];
                local time = CT_RaidTracker_GetTime(val["time"]);
                if ( id ) then
                    if ( ( not players[id]["leave"] or time > players[id]["leave"] ) and time >= players[id]["lastjoin"] ) then
                        players[id]["leave"] = time;
                    end
                end
            end
            for k, v in pairs(players) do
                if ( not v["leave"] ) then
                    -- Very ugly hack, I know :(
                    players[k]["leave"] = 99999999999;
                end
            end
            players = CT_RaidTracker_Sort(players, CT_RaidTracker_SortOptions["method"], CT_RaidTracker_SortOptions["way"]);
            getglobal("CT_RaidTrackerDetailScrollFramePlayers").raidid = raidid;
            getglobal("CT_RaidTrackerDetailScrollFramePlayers").players = players;
            CT_RaidTracker_DetailScrollFramePlayers_Update();
        end
        CT_RaidTrackerParticipantsText:SetText("Participants (" .. getn(players) .. ")");
        CT_RaidTrackerDetailScrollFramePlayers:Show();
    elseif ( CT_RaidTrackerFrame.type == "items" ) then
        CT_RaidTrackerDetailScrollFramePlayers:Hide();
        CT_RaidTrackerDetailScrollFramePlayer:Hide();
        CT_RaidTrackerDetailScrollFrameItems:Show();
        CT_RaidTrackerDetailScrollFrameEvents:Hide();
        local numItems, numHidden = 0, 0;
        if ( CT_RaidTracker_RaidLog[raidid] ) then
            local keystoremove = {};
            local loot = CT_RaidTracker_SortItem(CT_RaidTracker_RaidLog[raidid]["Loot"], CT_RaidTracker_SortOptions["itemmethod"], CT_RaidTracker_SortOptions["itemway"]);
            for key, val in pairs(loot) do
                val["thisitemid"] = tonumber(key);
                if((not val["item"]["tooltip"] or getn(val["item"]["tooltip"]) == 0) and CT_RaidTracker_Options["SaveTooltips"] == true and GetItemInfo(val["item"]["id"])) then
                    val["item"]["tooltip"] = CT_RaidTracker_GetItemTooltip(val["item"]["id"]);
                    CT_RaidTracker_Debug("TooltipGet", val["item"]["name"]);
                end
                if ( CT_RaidTracker_RarityTable[val["item"]["c"]] >= CT_RaidTracker_SortOptions["itemfilter"] ) then
                    numItems = numItems + 1;
                else
                    tinsert(keystoremove, key);
                    numHidden = numHidden + 1;
                end
            end
            for key, val in pairs(keystoremove) do
                table.remove(loot, val);
            end
            getglobal("CT_RaidTrackerDetailScrollFrameItems").raidid = raidid;
            getglobal("CT_RaidTrackerDetailScrollFrameItems").loot = loot;
            CT_RaidTracker_DetailScrollFrameItems_Update();
            CT_RaidTrackerDetailScrollFrameItems:Show();
        end
        if ( numHidden == 0 ) then
            CT_RaidTrackerItemsText:SetText("Items (" .. numItems .. "):");
        else
            CT_RaidTrackerItemsText:SetText("Items (" .. numItems .. "/" .. numHidden + numItems .. ")");
        end
        UIDropDownMenu_SetSelectedID(CT_RaidTrackerRarityDropDown, CT_RaidTracker_SortOptions["itemfilter"]);
        local colors = {
            "|c009d9d9dPoor|r",
            "|c00ffffffCommon|r",
            "|c001eff00Uncommon|r",
            "|c000070ddRare|r",
            "|c00a335eeEpic|r",
            "|c00ff8000Legendary|r",
            "|c00e6cc80Artifact",
        };

        CT_RaidTrackerRarityDropDownText:SetText(colors[CT_RaidTracker_SortOptions["itemfilter"]]);
    elseif ( CT_RaidTrackerFrame.type == "player" ) then
        CT_RaidTrackerDetailScrollFramePlayers:Hide();
        CT_RaidTrackerDetailScrollFramePlayer:Show();
        CT_RaidTrackerDetailScrollFrameItems:Hide();
        CT_RaidTrackerDetailScrollFrameEvents:Hide();
        CT_RaidTrackerPlayerRaidTabLooter:Hide();
        CT_RaidTrackerPlayerRaidTab1:SetWidth(300);
        CT_RaidTrackerPlayerRaidTab1Middle:SetWidth(290);
        local name = CT_RaidTrackerFrame.player;

        local raids = { };
        for k, v in pairs(CT_RaidTracker_RaidLog) do
            local isInRaid;
            for key, val in pairs(v["Join"]) do
                if ( val["player"] == name ) then
                    tinsert(raids, { k, v });
                    break;
                end
            end
        end

        table.sort(
            raids,
            function(a1, a2)
                if ( CT_RaidTracker_SortOptions["playerraidway"] == "asc" ) then
                    return CT_RaidTracker_GetTime(a1[2]["key"]) < CT_RaidTracker_GetTime(a2[2]["key"]);
                else
                    return CT_RaidTracker_GetTime(a1[2]["key"]) > CT_RaidTracker_GetTime(a2[2]["key"]);
                end
            end
        );
        getglobal("CT_RaidTrackerDetailScrollFramePlayer").data = raids;
        getglobal("CT_RaidTrackerDetailScrollFramePlayer").name = name;
        getglobal("CT_RaidTrackerDetailScrollFramePlayer").maxlines = getn(raids);
        CT_RaidTracker_DetailScrollFramePlayer_Update();
        CT_RaidTrackerDetailScrollFramePlayer:Show();

        CT_RaidTrackerPlayerText:SetText(name .. "'s Raids (" .. getn(raids) .. "):");
    elseif ( CT_RaidTrackerFrame.type == "itemhistory" ) then
        CT_RaidTrackerDetailScrollFramePlayers:Hide();
        CT_RaidTrackerDetailScrollFramePlayer:Show();
        CT_RaidTrackerDetailScrollFrameItems:Hide();
        CT_RaidTrackerDetailScrollFrameEvents:Hide();
        CT_RaidTrackerPlayerRaidTabLooter:Show();
        CT_RaidTrackerPlayerRaidTab1:SetWidth(163);
        CT_RaidTrackerPlayerRaidTab1Middle:SetWidth(155);

        local name, totalItems = CT_RaidTrackerFrame.itemname, 0;

        local items = { };
        for k, v in pairs(CT_RaidTracker_RaidLog) do
            for key, val in pairs(v["Loot"]) do
                if ( val["item"]["name"] == name ) then
                    tinsert(items, { k, v, val });
                    if ( val["item"]["count"] ) then
                        totalItems = totalItems + val["item"]["count"];
                    else
                        totalItems = totalItems + 1;
                    end
                end
            end
        end

        table.sort(
            items,
            function(a1, a2)
                if ( CT_RaidTracker_SortOptions["itemhistorymethod"] == "looter" ) then
                    if ( CT_RaidTracker_SortOptions["itemhistoryway"] == "asc" ) then
                        return a1[3]["player"] < a2[3]["player"];
                    else
                        return a1[3]["player"] > a2[3]["player"];
                    end
                else
                    if ( CT_RaidTracker_SortOptions["itemhistoryway"] == "asc" ) then
                        return CT_RaidTracker_GetTime(a1[2]["key"]) < CT_RaidTracker_GetTime(a2[2]["key"]);
                    else
                        return CT_RaidTracker_GetTime(a1[2]["key"]) > CT_RaidTracker_GetTime(a2[2]["key"]);
                    end
                end
            end
        );

        getglobal("CT_RaidTrackerDetailScrollFramePlayer").data = items;
        getglobal("CT_RaidTrackerDetailScrollFramePlayer").name = name;
        getglobal("CT_RaidTrackerDetailScrollFramePlayer").maxlines = getn(items);
        CT_RaidTracker_DetailScrollFramePlayer_Update();
        CT_RaidTrackerDetailScrollFramePlayer:Show();
        CT_RaidTrackerPlayerText:SetText(name .. " (" .. getn(items) .. "/" .. totalItems .. "):");
    elseif ( CT_RaidTrackerFrame.type == "events" ) then
        CT_RaidTrackerDetailScrollFramePlayers:Hide();
        CT_RaidTrackerDetailScrollFramePlayer:Hide();
        CT_RaidTrackerDetailScrollFrameEvents:Show();
        CT_RaidTrackerDetailScrollFrameItems:Hide();
        CT_RaidTrackerPlayerBossesTabBoss:Show();
        CT_RaidTrackerPlayerBossesTab1:SetWidth(163);
        CT_RaidTrackerPlayerBossesTab1Middle:SetWidth(155);

        local events = {};
        if ( CT_RaidTracker_RaidLog[raidid] and CT_RaidTracker_RaidLog[raidid]["BossKills"] ) then
            for key, val in pairs(CT_RaidTracker_RaidLog[raidid]["BossKills"]) do
                tinsert(events, val);
            end
        end
        getglobal("CT_RaidTrackerDetailScrollFrameEvents").raidid = raidid;
        getglobal("CT_RaidTrackerDetailScrollFrameEvents").events = events;

        CT_RaidTrackerEventsText:SetText("Events");
        CT_RaidTracker_DetailScrollFrameBoss_Update();
        CT_RaidTrackerDetailScrollFrameEvents:Show();
    elseif ( CT_RaidTrackerFrame.type == "playeritems" ) then
        CT_RaidTrackerDetailScrollFramePlayers:Hide();
        CT_RaidTrackerDetailScrollFramePlayer:Hide();
        CT_RaidTrackerDetailScrollFrameItems:Show();
        CT_RaidTrackerDetailScrollFrameEvents:Hide();
        local name = CT_RaidTrackerFrame.player;

        local loot = { };
        for k, v in pairs(CT_RaidTracker_RaidLog) do
            for key, val in pairs(v["Loot"]) do
                if ( val["player"] == name ) then
                    tinsert(
                        loot,
                        {
                            ["note"] = val["note"],
                            ["player"] = val["player"],
                            ["time"] = val["time"],
                            ["item"] = val["item"],
                            ["ids"] = { k, key }
                        }
                    );
                end
            end
        end

        local numItems, numHidden = 0, 0;
        local keystoremove = {};
        loot = CT_RaidTracker_SortItem(loot, CT_RaidTracker_SortOptions["playeritemmethod"], CT_RaidTracker_SortOptions["playeritemway"]);
        for key, val in pairs(loot) do
            if ( CT_RaidTracker_RarityTable[val["item"]["c"]] >= CT_RaidTracker_SortOptions["playeritemfilter"] ) then
                numItems = numItems + 1;
            else
                tinsert(keystoremove, key);
                numHidden = numHidden + 1;
            end
        end
        for key, val in pairs(keystoremove) do
            table.remove(loot, val);
        end
        getglobal("CT_RaidTrackerDetailScrollFrameItems").raidid = raidid;
        getglobal("CT_RaidTrackerDetailScrollFrameItems").loot = loot;
        CT_RaidTracker_DetailScrollFrameItems_Update();
        if ( numHidden == 0 ) then
            CT_RaidTrackerItemsText:SetText(name .. "'s Loot (" .. numItems .. "):");
        else
            CT_RaidTrackerItemsText:SetText(name .. "'s Loot (" .. numItems .. "/" .. numHidden + numItems .. "):");
        end

        UIDropDownMenu_SetSelectedID(CT_RaidTrackerRarityDropDown, CT_RaidTracker_SortOptions["playeritemfilter"]);
        local colors = {
            "|c009d9d9dPoor|r",
            "|c00ffffffCommon|r",
            "|c001eff00Uncommon|r",
            "|c000070ddRare|r",
            "|c00a335eeEpic|r",
            "|c00ff8000Legendary|r",
            "|c00e6cc80Artifact",
        };

        CT_RaidTrackerRarityDropDownText:SetText(colors[CT_RaidTracker_SortOptions["playeritemfilter"]]);
    end
end

function CT_RaidTracker_DetailScrollFramePlayers_Update()
    local raidid = getglobal("CT_RaidTrackerDetailScrollFramePlayers").raidid;
    local players = getglobal("CT_RaidTrackerDetailScrollFramePlayers").players;
    local maxlines = getn(players);
    local line;
    local lineplusoffset;
    FauxScrollFrame_Update(CT_RaidTrackerDetailScrollFramePlayers, maxlines, 11, 18);
    for line=1, 11 do
        lineplusoffset = line+FauxScrollFrame_GetOffset(CT_RaidTrackerDetailScrollFramePlayers);
        if (lineplusoffset <= maxlines) then
            val = players[lineplusoffset];
            getglobal("CT_RaidTrackerPlayerLine" .. line).raidid = raidid;
            getglobal("CT_RaidTrackerPlayerLine" .. line).raidtitle = CT_RaidTracker_GetRaidTitle(raidid, 1);
            getglobal("CT_RaidTrackerPlayerLine" .. line).playername = val["name"];
            local name = getglobal("CT_RaidTrackerPlayerLine" .. line .. "Name");
            local number = getglobal("CT_RaidTrackerPlayerLine" .. line .. "Number");
            local join = getglobal("CT_RaidTrackerPlayerLine" .. line .. "Join");
            local leave = getglobal("CT_RaidTrackerPlayerLine" .. line .. "Leave");
            if ( name ) then
                name:SetFont("Fonts\\FRIZQT__.TTF", 11);
                name:SetText(val["name"]);
                local iNumber = lineplusoffset;
                if ( iNumber < 10 ) then
                    iNumber = "  " .. iNumber;
                end
                number:SetFont("Fonts\\FRIZQT__.TTF", 11);
                number:SetText("|cFFFFFF00" .. iNumber);
                if(CT_RaidTracker_Options["24hFormat"] == true) then
                    join:SetFont("Fonts\\FRIZQT__.TTF", 11);
                    join:SetText("|cFFFFFF00" .. date("%H:%M", val["join"]));
                else
                    join:SetFont("Fonts\\FRIZQT__.TTF", 11);
                    join:SetText("|cFFFFFF00" .. date("%I:%M%p", val["join"]));
                end
                if ( val["leave"] == 99999999999 ) then
                    leave:SetFont("Fonts\\FRIZQT__.TTF", 11);
                    leave:SetText("");
                else
                    if(CT_RaidTracker_Options["24hFormat"] == true) then
                        leave:SetFont("Fonts\\FRIZQT__.TTF", 11);
                        leave:SetText("|cFFFFFF00" .. date("%H:%M", val["leave"]));
                    else
                        leave:SetFont("Fonts\\FRIZQT__.TTF", 11);
                        leave:SetText("|cFFFFFF00" .. date("%I:%M%p", val["leave"]));
                    end
                end
                if ( CT_RaidTracker_RaidLog[raidid]["PlayerInfos"][val["name"]] and CT_RaidTracker_RaidLog[raidid]["PlayerInfos"][val["name"]]["note"] ) then
                    getglobal("CT_RaidTrackerPlayerLine" .. line .. "NoteButtonNormalTexture"):SetVertexColor(1, 1, 1);
                else
                    getglobal("CT_RaidTrackerPlayerLine" .. line .. "NoteButtonNormalTexture"):SetVertexColor(0.5, 0.5, 0.5);
                end
                getglobal("CT_RaidTrackerPlayerLine" .. line .. "NoteButton"):Show();
                getglobal("CT_RaidTrackerPlayerLine" .. line .. "DeleteButton"):Show();
                getglobal("CT_RaidTrackerPlayerLine" .. line):Show();
            end
        else
            getglobal("CT_RaidTrackerPlayerLine" .. line):Hide();
        end
    end
    CT_RaidTrackerDetailScrollFramePlayers:Show();
end

function CT_RaidTracker_DetailScrollFrameItems_Update()
    local raidid = getglobal("CT_RaidTrackerDetailScrollFrameItems").raidid;
    local loot = getglobal("CT_RaidTrackerDetailScrollFrameItems").loot;
    local maxlines = getn(loot);
    local line;
    local lineplusoffset;
    FauxScrollFrame_Update(CT_RaidTrackerDetailScrollFrameItems, maxlines, 5, 41);
    for line=1, 5 do
        lineplusoffset = line+FauxScrollFrame_GetOffset(CT_RaidTrackerDetailScrollFrameItems);
        if (lineplusoffset <= maxlines) then
            local val = loot[lineplusoffset];
            if ( CT_RaidTrackerFrame.type == "items" ) then
                getglobal("CT_RaidTrackerItem" .. line).raidid = raidid;
                getglobal("CT_RaidTrackerItem" .. line).itemid = val["thisitemid"];
                getglobal("CT_RaidTrackerItem" .. line).itemname = val["item"]["name"];
                if ( val["item"]["count"] and val["item"]["count"] > 1 ) then
                    getglobal("CT_RaidTrackerItem" .. line .. "Count"):Show();
                    getglobal("CT_RaidTrackerItem" .. line .. "Count"):SetFont("Fonts\\FRIZQT__.TTF", 11);
                    getglobal("CT_RaidTrackerItem" .. line .. "Count"):SetText("|cFFFFFF00" .. val["item"]["count"]);
                else
                    getglobal("CT_RaidTrackerItem" .. line .. "Count"):Hide();
                end
                if ( val["item"]["icon"] ) then
                    getglobal("CT_RaidTrackerItem" .. line .. "IconTexture"):SetTexture(val["item"]["icon"]);
                else
                    getglobal("CT_RaidTrackerItem" .. line .. "IconTexture"):SetTexture("Interface\\Icons\\INV_Misc_Gear_08");
                end
                local color = val["item"]["c"];
                if ( color == "ff1eff00" ) then
                    color = "ff005D00";
                end
                getglobal("CT_RaidTrackerItem" .. line .. "Description"):SetFont("Fonts\\FRIZQT__.TTF", 11);
                getglobal("CT_RaidTrackerItem" .. line .. "Description"):SetText("|c" .. color .. val["item"]["name"]);
                getglobal("CT_RaidTrackerItem" .. line .. "Looted"):SetFont("Fonts\\FRIZQT__.TTF", 11);
                getglobal("CT_RaidTrackerItem" .. line .. "Looted"):SetText("Looted by: |cFFFFFFFF" .. val["player"]);

                if ( val["note"] ) then
                    getglobal("CT_RaidTrackerItem" .. line .. "NoteNormalTexture"):SetVertexColor(1, 1, 1);
                else
                    getglobal("CT_RaidTrackerItem" .. line .. "NoteNormalTexture"):SetVertexColor(0.5, 0.5, 0.5);
                end
            elseif ( CT_RaidTrackerFrame.type == "playeritems" ) then
                getglobal("CT_RaidTrackerItem" .. line).raidid = val["ids"][1];
                getglobal("CT_RaidTrackerItem" .. line).itemid = val["ids"][2];
                getglobal("CT_RaidTrackerItem" .. line).itemname = val["item"]["name"];

                if ( val["item"]["count"] and val["item"]["count"] > 1 ) then
                    getglobal("CT_RaidTrackerItem" .. line .. "Count"):Show();
                    getglobal("CT_RaidTrackerItem" .. line .. "Count"):SetFont("Fonts\\FRIZQT__.TTF", 11);
                    getglobal("CT_RaidTrackerItem" .. line .. "Count"):SetText("|cFFFFFF00" .. val["item"]["count"]);
                else
                    getglobal("CT_RaidTrackerItem" .. line .. "Count"):Hide();
                end
                if ( val["item"]["icon"] ) then
                    getglobal("CT_RaidTrackerItem" .. line .. "IconTexture"):SetTexture(val["item"]["icon"]);
                else
                    getglobal("CT_RaidTrackerItem" .. line .. "IconTexture"):SetTexture("Interface\\Icons\\INV_Misc_Gear_08");
                end
                local color = val["item"]["c"];
                if ( color == "ff1eff00" ) then
                    color = "ff005D00";
                end
                getglobal("CT_RaidTrackerItem" .. line .. "Description"):SetFont("Fonts\\FRIZQT__.TTF", 11);
                getglobal("CT_RaidTrackerItem" .. line .. "Description"):SetText("|c" .. color .. val["item"]["name"]);
                getglobal("CT_RaidTrackerItem" .. line .. "Looted"):SetFont("Fonts\\FRIZQT__.TTF", 11);
                getglobal("CT_RaidTrackerItem" .. line .. "Looted"):SetText("Looted " .. CT_RaidTracker_GetRaidTitle(val["ids"][1], 1));

                if ( val["note"] ) then
                    getglobal("CT_RaidTrackerItem" .. line .. "NoteNormalTexture"):SetVertexColor(1, 1, 1);
                else
                    getglobal("CT_RaidTrackerItem" .. line .. "NoteNormalTexture"):SetVertexColor(0.5, 0.5, 0.5);
                end
            end
            getglobal("CT_RaidTrackerItem" .. line):Show();
        else
            getglobal("CT_RaidTrackerItem" .. line):Hide();
        end
    end
    CT_RaidTrackerDetailScrollFrameItems:Show();
end

function CT_RaidTracker_DetailScrollFramePlayer_Update()
    local data = getglobal("CT_RaidTrackerDetailScrollFramePlayer").data;
    local name = getglobal("CT_RaidTrackerDetailScrollFramePlayer").name;
    local maxlines = getglobal("CT_RaidTrackerDetailScrollFramePlayer").maxlines;
    local line;
    local lineplusoffset;
    FauxScrollFrame_Update(CT_RaidTrackerDetailScrollFramePlayer, maxlines, 11, 18);
    for line=1, 11 do
        lineplusoffset = line+FauxScrollFrame_GetOffset(CT_RaidTrackerDetailScrollFramePlayer);
        if (lineplusoffset <= maxlines) then
            val = data[lineplusoffset];
            if ( CT_RaidTrackerFrame.type == "player" ) then
                getglobal("CT_RaidTrackerPlayerRaid" .. line).raidid = val[1];
                getglobal("CT_RaidTrackerPlayerRaid" .. line).playername = name;
                getglobal("CT_RaidTrackerPlayerRaid" .. line).raidtitle = CT_RaidTracker_GetRaidTitle(val[1], 1);
                local number = getglobal("CT_RaidTrackerPlayerLine" .. line .. "Number");
                local iNumber = getn(CT_RaidTracker_RaidLog)-val[1]+1;
                if ( iNumber < 10 ) then
                    iNumber = "  " .. iNumber;
                end

                number:SetFont("Fonts\\FRIZQT__.TTF", 11);
                number:SetText(iNumber);

                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "MouseOverLeft"):Hide();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "MouseOverRight"):Hide();

                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "HitAreaLeft"):Hide();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "HitAreaRight"):Hide();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "HitArea"):Show();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Note"):Hide();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "NoteButton"):Show();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "DeleteButton"):Show();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "DeleteText"):Show();

                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Number"):SetFont("Fonts\\FRIZQT__.TTF", 11);
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Number"):SetText("|cFFFFFF00" .. iNumber);
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Name"):SetWidth(200);
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Name"):SetFont("Fonts\\FRIZQT__.TTF", 11);
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Name"):SetText("|cFFFFFF00" .. CT_RaidTracker_GetRaidTitle(val[1], 1));

                if ( val[2]["PlayerInfos"][name] and val[2]["PlayerInfos"][name]["note"] ) then
                    getglobal("CT_RaidTrackerPlayerRaid" .. line .. "NoteButtonNormalTexture"):SetVertexColor(1, 1, 1);
                else
                    getglobal("CT_RaidTrackerPlayerRaid" .. line .. "NoteButtonNormalTexture"):SetVertexColor(0.5, 0.5, 0.5);
                end
            elseif ( CT_RaidTrackerFrame.type == "itemhistory" ) then
                getglobal("CT_RaidTrackerPlayerRaid" .. line).raidid = val[1];

                local iNumber = getn(CT_RaidTracker_RaidLog)-val[1]+1;
                if ( iNumber < 10 ) then
                    iNumber = "  " .. iNumber;
                end
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "MouseOver"):Hide();

                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "HitAreaLeft"):Show();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "HitAreaRight"):Show();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "HitArea"):Hide();

                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "NoteButton"):Hide();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Note"):Show();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "DeleteButton"):Hide();
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "DeleteText"):Hide();

                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Number"):SetFont("Fonts\\FRIZQT__.TTF", 11);
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Number"):SetText("|cFFFFFF00" .. iNumber);
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Name"):SetWidth(130);
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Name"):SetFont("Fonts\\FRIZQT__.TTF", 11);
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Name"):SetText("|cFFFFFF00" .. CT_RaidTracker_GetRaidTitle(val[1], 1));
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Note"):SetFont("Fonts\\FRIZQT__.TTF", 11);
                getglobal("CT_RaidTrackerPlayerRaid" .. line .. "Note"):SetText("|cFFFFFF00" .. val[3]["player"]);
            end
            getglobal("CT_RaidTrackerPlayerRaid" .. line):Show();
        else
            getglobal("CT_RaidTrackerPlayerRaid" .. line):Hide();
        end
    end
    CT_RaidTrackerDetailScrollFramePlayer:Show();
end

function CT_RaidTracker_DetailScrollFrameBoss_Update()
    local events = getglobal("CT_RaidTrackerDetailScrollFrameEvents").events;
    local maxlines = getn(events);
    local line;
    local lineplusoffset;
    FauxScrollFrame_Update(CT_RaidTrackerDetailScrollFrameEvents, maxlines, 11, 18);
    for line=1, 11 do
        lineplusoffset = line+FauxScrollFrame_GetOffset(CT_RaidTrackerDetailScrollFrameEvents);
        if (lineplusoffset <= maxlines) then
            val = events[lineplusoffset];
            getglobal("CT_RaidTrackerBosses" .. line .. "MouseOver"):Hide();
            getglobal("CT_RaidTrackerBosses" .. line .. "HitArea"):Show();
            getglobal("CT_RaidTrackerBosses" .. line .. "Boss"):SetFont("Fonts\\FRIZQT__.TTF", 11);
            getglobal("CT_RaidTrackerBosses" .. line .. "Boss"):SetText("|cFFFFFF00" .. val["boss"]);
            getglobal("CT_RaidTrackerBosses" .. line .. "Time"):SetFont("Fonts\\FRIZQT__.TTF", 11);
            getglobal("CT_RaidTrackerBosses" .. line .. "Time"):SetText("|cFFFFFF00" .. val["time"]);
            getglobal("CT_RaidTrackerBosses" .. line):Show();
        else
            getglobal("CT_RaidTrackerBosses" .. line):Hide();
        end
    end
    CT_RaidTrackerDetailScrollFrameEvents:Show();
end

function CT_RaidTracker_ColorToRGB(str)
    str = strlower(strsub(str, 3));
    local tbl = { };
    tbl[1], tbl[2], tbl[3], tbl[4], tbl[5], tbl[6] = strsub(str, 1, 1), strsub(str, 2, 2), strsub(str, 3, 3), strsub(str, 4, 4), strsub(str, 5, 5), strsub(str, 6, 6);

    local highvals = { ["a"] = 10, ["b"] = 11, ["c"] = 12, ["d"] = 13, ["e"] = 14, ["f"] = 15 };
    for k, v in pairs(tbl) do
        if ( highvals[v] ) then
            tbl[k] = highvals[v];
        elseif ( tonumber(v) ) then
            tbl[k] = tonumber(v);
        end
    end
    local r, g, b = (tbl[1]*16+tbl[2])/255, (tbl[3]*16+tbl[4])/255, (tbl[5]*16+tbl[6])/255;
    if ( not r or r > 1 or r < 0 ) then
        r = 1;
    end
    if ( not g or g > 1 or g < 0 ) then
        g = 1;
    end
    if ( not b or b > 1 or b < 0 ) then
        b = 1;
    end
    return r, g, b;
end
function CT_RaidTrackerItem_SetHyperlink(this)
    local raidid = this.raidid;
    local lootid = this.itemid;
    if ( CT_RaidTracker_RaidLog[raidid] and CT_RaidTracker_RaidLog[raidid]["Loot"][lootid] ) then
        local item = CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["item"];
        local itemid = strsplit(":",item["id"]);
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
        if (GetItemInfo(itemid)) then
            _, link = GetItemInfo(itemid);
            GameTooltip:SetHyperlink(link);
        else
            rl, gl, bl = CT_RaidTracker_ColorToRGB(item["c"]);
            GameTooltip:AddLine(item["name"], rl, gl, bl);
            GameTooltip:AddLine("This item is not in your cache, you can try to get the information by rightclicking the item (This may result in a disconnect!)", 1, 1, 1);
        end

        GameTooltip:AddLine("Time: "..CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["time"], 1, 1, 0);
        if(CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["zone"]) then
            GameTooltip:AddLine("Zone: "..CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["zone"], 1, 1, 0);
        end
        if(CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["boss"]) then
            GameTooltip:AddLine("Boss: "..CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["boss"], 1, 1, 0);
        end
        if(CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["costs"]) then
            GameTooltip:AddLine("Costs: "..CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["costs"], 1, 1, 0);
        end
        if(CT_RaidTracker_Options["DebugFlag"]) then
            if(CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["item"]["class"]) then
                GameTooltip:AddLine("Class: "..CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["item"]["class"], 1, 1, 0);
            end
            if(CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["item"]["subclass"]) then
                GameTooltip:AddLine("SubClass: "..CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["item"]["subclass"], 1, 1, 0);
            end
        end

        GameTooltip:Show();
        return;
    end
end

function CT_RaidTrackerItem_GetChatHyperlink(this)
    local raidid = this.raidid;
    local lootid = this.itemid;
    if ( IsShiftKeyDown() and ( type(WIM_API_InsertText) == "function" ) and CT_RaidTracker_RaidLog[raidid] and CT_RaidTracker_RaidLog[raidid]["Loot"][lootid] ) then
        local item = CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["item"];
        WIM_API_InsertText( "|c" .. item.c .. "|Hitem:" .. item.id .. "|h[" .. item.name .. "]|h|r" );
    end
    if ( IsShiftKeyDown() and ChatFrame1EditBox:IsVisible() and CT_RaidTracker_RaidLog[raidid] and CT_RaidTracker_RaidLog[raidid]["Loot"][lootid] ) then
        local item = CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["item"];
        ChatFrame1EditBox:Insert("|c" .. item.c .. "|Hitem:" .. item.id .. "|h[" .. item.name .. "]|h|r");
    end
end

function CT_RaidTracker_GetItemTooltip(sItem)
    local tTooltip = { };
    --CT_RTTooltip:SetOwner(this, "ANCHOR_NONE");
    CT_RTTooltip:ClearLines()
    CT_RTTooltip:SetHyperlink("item:" .. sItem);
    --CT_RTTooltip:Hide();
    CT_RTTooltip.id = sItem;
    for i = 1, CT_RTTooltip:NumLines(), 1 do
        local tl, tr;
        tl = getglobal("CT_RTTooltipTextLeft" .. i):GetText();
        tr = getglobal("CT_RTTooltipTextRight" .. i):GetText();
        tinsert(tTooltip, { ["left"] = tl, ["right"] = tr });
    end
    return tTooltip;
end

-- Debug function(s)

function CT_RaidTracker_Debug(...)
    --local a = ...;
    if ( CT_RaidTracker_Options["DebugFlag"] ) then
        local sDebug = "#";
        for i = 1, select("#", ...) , 1 do
            if ( select(i, ...) ) then
                sDebug = sDebug .. tostring(select(i, ...) ) .. "#";
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage(sDebug, 1, 0.5, 0);
    end
end


-- OnFoo functions

function CT_RaidTracker_OnLoad(this)
    CT_RaidTrackerTitleText:SetText("GL CT_RaidTracker " .. CT_RaidTracker_Version);
    -- Register events
    this:RegisterEvent("CHAT_MSG_LOOT");
    this:RegisterEvent("CHAT_MSG_SYSTEM");
    this:RegisterEvent("GROUP_ROSTER_UPDATE");
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
    this:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    this:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    this:RegisterEvent("CHAT_MSG_MONSTER_YELL");
    this:RegisterEvent("CHAT_MSG_MONSTER_EMOTE");
    this:RegisterEvent("PLAYER_ENTERING_WORLD");
    --this:RegisterEvent("PARTY_MEMBERS_CHANGED");
    this:RegisterEvent("UNIT_HEALTH");
    this:RegisterEvent("UPDATE_INSTANCE_INFO");
    --Oberan: register for the whisper event
    this:RegisterEvent("CHAT_MSG_WHISPER");
end

function CT_RaidTracker_OnEvent(this, event, arg1)
--if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then
--	if event ~= "UNIT_HEALTH" then
--		if event ~= "UPDATE_MOUSEOVER_UNIT" then 
--		CT_RaidTracker_Debug("event fired", event);
--	end
--	end
--	end
        local _, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, _, _, _, _, _, _, _ = CombatLogGetCurrentEventInfo()
        local CT_RaidTracker_RealBossChangeTime = CT_RaidTracker_Options["AutoBossChangeMinTime"]*60;

    --Oberan
    -- this code will take a whisper of "listme" while in a raid and auto /rt join that raider to the currently selected raid if one is selected.
    if(event == "CHAT_MSG_WHISPER") then
        if(arg1 ~= nil and strlower(arg1) == "listme") then
            local author = arg2;

            -- am i in a raid?
            if(IsInRaid() == false)then
                SendChatMessage( "I am not in a raid at this time.", "WHISPER", nil, author);
                return;
            end

            if (CT_RaidTracker_Options["ListMeEnabled"] == false) then
                SendChatMessage( "The listme functionality is currently disabled.", "WHISPER", nil, author);
                return;
            end
            -- Oberan: the frame has to have a raid selected.... this should only happen when the recorder
            -- logs on, and they have not opened the tracker window. Sigh, not my 1st choice on how this would/should work.
            if(CT_RaidTrackerFrame.selected) then
                local jointime = CT_RaidTracker_Date();
                if(CT_RaidTracker_JoinLeaveSaveEx(author, "Wait listed " .. jointime, jointime, CT_RaidTracker_GetCurrentRaid, "Join") == 1)then
                    -- add to waitlist
                    CT_RaidTracker_WaitList[author] = 1;
                    SendChatMessage( author .. " was added to the raid at: " .. jointime, "WHISPER", nil, author);
                else
                    SendChatMessage( "Failed to add you to the raid.", "WHISPER", nil, author);
                end
            else
                SendChatMessage("There was no raid selected, please try again in a minute. I have to select a raid...", "WHISPER", nil, author);
                CT_RaidTracker_Print("Join: There is no raid selected", 1, 1, 0);
            end

        end

        -- dump out for the rest of this code, as this is the only whisper code
        return;
    end

    local julianne_died = false;
    if ( CT_RaidTracker_UpdateFrame.time and CT_RaidTracker_UpdateFrame.time <= 2 ) then
        tinsert(CT_RaidTracker_Events, event);
        return;
    end

    if ( CT_RaidTracker_Options["LogBattlefield"] == 0 and ((GetNumBattlefieldScores() > 0) or (IsActiveBattlefieldArena() == 1))) then
        if ( CT_RaidTracker_GetCurrentRaid ) then
            CT_RaidTracker_Delete(this, CT_RaidTracker_GetCurrentRaid, "raid", 0 );
            CT_RaidTracker_Debug("Battlegroup detected, removing raid entry from list.");
            return;
        else
            CT_RaidTracker_Debug("Battlegroup detected, skipped event.");
            return;
        end;
    end;
    if ( event == "" and arg7 == CT_RaidTracker_lang_BossKills_Julianne_BossName) then

    end;
    if ( event == "CHAT_MSG_MONSTER_YELL" 
            or event == "CHAT_MSG_MONSTER_EMOTE") then
        CT_RaidTracker_Debug("Boss Yell "..arg1)
        -- Cata Yells
        if(arg1 == CT_RaidTracker_lang_BossKills_Conclave_of_Wind_Yell) then
            CT_RaidTracker_Debug("Conclave of Wind has Been Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Conclave_of_Wind_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Omnotron_Yell) then
            CT_RaidTracker_Debug("Omnotron Defense System has Been Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Omnotron_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_NewRagnaros_Yell or arg1 == CT_RaidTracker_lang_BossKills_NewRagnaros_Yell2) then
            CT_RaidTracker_Debug("New Ragnaros Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_NewRagnaros_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_DeathwingFinal_Yell) then
            CT_RaidTracker_Debug("New Deathwing Final Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_DeathwingFinal_BossName;                
        elseif(arg1 == CT_RaidTracker_lang_BossKills_WillOfTheEmperor_Yell) then
            CT_RaidTracker_Debug("New Will of Emperor Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_WillOfTheEmperor_BossName; 
        elseif(arg1 == CT_RaidTracker_lang_BossKills_SpiritKings_Yell) then
            CT_RaidTracker_Debug("New Spirit Kings Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_SpiritKings_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_LeiShi_Yell) then
            CT_RaidTracker_Debug("New Lei Shi Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_LeiShi_BossName;                                                       
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Tsulong_Yell) then
            CT_RaidTracker_Debug("New Tsulong Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Tsulong_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Spoils_Yell) then
            CT_RaidTracker_Debug("New Pandarian Spoils Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Spoils_BossName;             
        elseif(arg1 == CT_RaidTracker_lang_BossKills_FallenProtectors_Yell) then
            CT_RaidTracker_Debug("New Fallen Protectors Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_FallenProtectors_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Immerseus_Yell) then
            CT_RaidTracker_Debug("New Immerseus Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Immerseus_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Immerseus_Yell2) then
            CT_RaidTracker_Debug("New Immerseus2 Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Immerseus_BossName2;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Immerseus_Yell3) then
            CT_RaidTracker_Debug("New Immerseus3 Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Immerseus_BossName3;                       
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Immerseus_Yell4) then
            CT_RaidTracker_Debug("New Immerseus4 Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Immerseus_BossName4;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Spoils_Yell) then
            CT_RaidTracker_Debug("New Spoils of Pandaria Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Spoils_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_TrialofValor_Odyn_Yell) then
            CT_RaidTracker_Debug("New Spoils of Pandaria Defeated");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_TrialofValor_Odyn_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Uldir_MOTHER_Yell) then
            CT_RaidTracker_Debug("New MOTHER Defeated")                                                                         ;
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Uldir_MOTHER_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Dazar_Jaina_Yell) then
            CT_RaidTracker_Debug("New Jaina Defeated")                                                                         ;
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Dazar_Jaina_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Dazar_Rastakhan_Yell) then
            CT_RaidTracker_Debug("New King Rastakhan Defeated")                                                                         ;
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Dazar_Rastakhan_BossName;
        elseif(arg1 == CT_RaidTracker_lang_BossKills_Majordomo_Yell) then
            CT_RaidTracker_Debug("Majordomo Executus Defeated");
            event = "COMABT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg9 = CT_RaidTracker_lang_BossKills_Majordomo_BossName;
        end

        if (CT_RaidTracker_Klaxxi_Yells[arg1]) then            
            CT_RaidTracker_Klaxxi_Status = CT_RaidTracker_Klaxxi_Status + CT_RaidTracker_Klaxxi_Yells[arg1];    
            CT_RaidTracker_Debug("Got one of the Klaxxi " .. CT_RaidTracker_Klaxxi_Status);
            if (CT_RaidTracker_Klaxxi_Status == CT_RaidTracker_Klaxxi_Dead) then
                CT_RaidTracker_Debug("Got ALL of the Klaxxi");
                event   = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2    = "UNIT_DIED";
                arg9    = CT_RaidTracker_lang_BossKills_Paragons_BossName;   
                CT_RaidTracker_Klaxxi_Status = 0; 
            end            
        end
        if (CT_RaidTracker_Maidens_Yells[arg1]) then            
            CT_RaidTracker_Maidens_Status = CT_RaidTracker_Maidens_Status + CT_RaidTracker_Maidens_Yells[arg1];    
            CT_RaidTracker_Debug("Got one of the Maidens " .. CT_RaidTracker_Maidens_Status);
            if (CT_RaidTracker_Maidens_Status == CT_RaidTracker_Maidens_Dead) then
                CT_RaidTracker_Debug("Got ALL of the Maidens");
                event   = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2    = "UNIT_DIED";
                arg9    = CT_RaidTracker_lang_BossKills_Maidens_BossName;   
                CT_RaidTracker_Maidens_Status = 0; 
            end            
        end
		if (CT_RaidTracker_HellfireCouncil_Yells[arg1]) then            
            CT_RaidTrackerHellfireCouncil_Status = CT_RaidTracker_HellfireCouncil_Status + CT_RaidTracker_HellfireCouncil_Yells[arg1];    
            CT_RaidTracker_Debug("Got one of the Council " .. CT_RaidTracker_HellfireCouncil_Status);
            if (CT_RaidTracker_HellfireCouncil_Status == CT_RaidTracker_HellfireCouncil_Dead) then
                CT_RaidTracker_Debug("Got ALL of the Council");
                event   = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2    = "UNIT_DIED";
                arg9    = CT_RaidTracker_lang_BossKills_HellfireCouncil_BossName;   
                CT_RaidTracker_HellfireCouncil_Status = 0; 
            end            
        end
        --[[
        -- yell sample
        if(arg1 == CT_RaidTracker_lang_BossKills_Majordomo_Yell) then
            CT_RaidTracker_Debug("It's domo!");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2="UNIT_DIED";
            arg7 =CT_RaidTracker_lang_BossKills_Majordomo_BossName;
        elseif(arg1 == CT_RaidTracker_lang_bossKills_HalionHardmode) then
            CT_RaidTracker_Debug("Halion - Hardmode");
            event = "COMBAT_LOG_EVENT_UNFILTERED";
            arg2 = "UNIT_DIED";
            arg7 = CT_RaidTracker_lang_bossKills_HalionHardmode_BossName;                                                
        end
        --]]
        -- these are old boss yells
        if (CT_RaidTracker_ExpansionLevel <= 3) then
            if(arg1 == CT_RaidTracker_lang_BossKills_Majordomo_Yell) then
                CT_RaidTracker_Debug("It's domo!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2="UNIT_DIED";
                arg9 =CT_RaidTracker_lang_BossKills_Majordomo_BossName;
            elseif(arg2 == "Karazhan - Chess, Victory Controller") then
                CT_RaidTracker_Print("Plz contact Eris at www.mldkp.net that Chess event logging is working (incl language)");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2="UNIT_DIED";
                arg9 = CT_RaidTracker_lang_BossKills_Chess_Event_BossName;
            elseif(arg1 == CT_RaidTracker_lang_BossKills_Chess_Event_Yell) then
                CT_RaidTracker_Debug("Chess event");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2="UNIT_DIED";
                arg9 = CT_RaidTracker_lang_BossKills_Chess_Event_BossName;
            elseif(arg1 == CT_RaidTracker_lang_BossKills_Julianne_Die_Yell) then
                CT_RaidTracker_Debug("Romulo und Julianne");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2="UNIT_DIED";
                arg9 = CT_RaidTracker_lang_BossKills_Julianne_BossName;
                julianne_died = true;
            elseif(arg1 == CT_RaidTracker_lang_BossKills_Sathrovarr_Yell) then
                CT_RaidTracker_Debug("Sathrovarr!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_BossKills_Sathrovarr_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Mimiron_Yell) then
                CT_RaidTracker_Debug("Mimoron!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Mimiron_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Thorim_Yell_1) then
                CT_RaidTracker_Debug("Thorim Regular!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Thorim_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Thorim_Yell_2) then
                CT_RaidTracker_Debug("Thorim Regular!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Thorim_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Thorim_Yell_3) then
                CT_RaidTracker_Debug("Thorim Regular!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Thorim_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Thorim_Yell_h1) then
                CT_RaidTracker_Debug("Thorim Hard!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Thorim_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Thorim_Yell_h2) then
                CT_RaidTracker_Debug("Thorim Hard!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Thorim_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Thorim_Yell_h3) then
                CT_RaidTracker_Debug("Thorim Hard!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Thorim_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Hodir_Yell) then
                CT_RaidTracker_Debug("Hodir!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Hodir_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Freya_Yell) then
                CT_RaidTracker_Debug("Freya!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Freya_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Assembly_of_Iron_Yell_1) then
                CT_RaidTracker_Debug("The Assembly of Iron!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Assembly_of_Iron_Yell_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Assembly_of_Iron_Yell_2) then
                CT_RaidTracker_Debug("The Assembly of Iron!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Assembly_of_Iron_Yell_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Assembly_of_Iron_Yell_3) then
                CT_RaidTracker_Debug("The Assembly of Iron!");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Assembly_of_Iron_Yell_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_TwinValkyr) then
                CT_RaidTracker_Debug("Twin Val'kyr");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_TwinValkyr_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_Anubarak) then
                CT_RaidTracker_Debug("Anubarak");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_Anubarak_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_FactionChampsAlliance) then
                CT_RaidTracker_Debug("Faction Champs Alliance");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_FactionChampsAlliance_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_FactionChampsHorde) then
                CT_RaidTracker_Debug("Faction Champs Horde");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_FactionChampsHorde_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_FactionChamps) then
                CT_RaidTracker_Debug("Faction Champs");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_FactionChamps_BossName;                        
            elseif(arg1 == CT_RaidTracker_lang_bossKills_GunshipBattleOne) then
                CT_RaidTracker_Debug("Gunship Battle");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_GunshipBattle_BossName;                        
            elseif(arg1 == CT_RaidTracker_lang_bossKills_GunshipBattleTwo) then
                CT_RaidTracker_Debug("Gunship Battle");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_GunshipBattle_BossName;                        
            elseif(arg1 == CT_RaidTracker_lang_bossKills_DeathbringerSaurfang) then
                CT_RaidTracker_Debug("Deathbringer Saurfang");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_DeathbringerSaurfang_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_BloodPrinceCouncil) then
                CT_RaidTracker_Debug("Blood Prince Council");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_BloodPrinceCouncil_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_ValithriaDreamwalker) then
                CT_RaidTracker_Debug("Valithria Dreamwalker");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_ValithriaDreamwalker_BossName;
            elseif(arg1 == CT_RaidTracker_lang_bossKills_HalionHardmode) then
                CT_RaidTracker_Debug("Halion - Hardmode");
                event = "COMBAT_LOG_EVENT_UNFILTERED";
                arg2 = "UNIT_DIED";
                arg9 = CT_RaidTracker_lang_bossKills_HalionHardmode_BossName;                                                
            end
        end
    end
    if ( event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD") then
        if ( GetNumGroupMembers() == 0 and event == "GROUP_ROSTER_UPDATE" and CT_RaidTracker_GetCurrentRaid) then
            local raidendtime = CT_RaidTracker_Date();
            for k, v in pairs(CT_RaidTracker_Online) do
                CT_RaidTracker_Debug("ADDING LEAVE", k, raidendtime);
                tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                    {
                        ["player"] = k,
                        ["time"] = raidendtime,
                    }
                );
            end
            if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["End"]) then
                CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["End"] = raidendtime;
            end
            CT_RaidTracker_GetCurrentRaid = nil;
            CT_RaidTracker_Debug("Left raid.","GetNumGroupMembers() == 0");
            CT_RaidTracker_Offline = { };
            CT_RaidTracker_UpdateView();
            CT_RaidTracker_Update();
        elseif ( not CT_RaidTracker_GetCurrentRaid and GetNumGroupMembers() > 0 and IsInRaid() and event == "GROUP_ROSTER_UPDATE" and CT_RaidTracker_Options["AutoRaidCreation"] == true) then
            CT_RaidTrackerCreateNewRaid();
        end
        if ( not CT_RaidTracker_GetCurrentRaid ) then
            return;
        end
        local updated;
        for i = 1, GetNumGroupMembers(), 1 do
                local name = GetFixedUpUnitName("raid" .. i, true)
                local online = UnitIsConnected("raid" .. i);
                if ( name and name ~= UKNOWNBEING and name ~= UNKNOWN ) then
                    local _, race = UnitRace("raid" .. i);
                    local _, class = UnitClass("raid" .. i);
                    local sex = UnitSex("raid" .. i);
                    local level = UnitLevel("raid" .. i);
                    local guild = GetGuildInfo("raid" .. i);

                    if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"]) then
                        CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"] = { };
                    end
                    if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]) then
                        CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name] = { };
                    end
                    if(CT_RaidTracker_Options["SaveExtendedPlayerInfo"] == 1) then
                        if(race) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["race"] = race; end
                        if(class) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["class"] = class; end
                        if(sex) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["sex"] = sex; end
                        if(level > 0) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["level"] = level; end
                        if(guild) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["guild"] = guild; end
                    end
                    if ( online ~= CT_RaidTracker_Online[name] ) then
                        -- Status isn't updated
                        CT_RaidTracker_Debug("Status isn't updated", name, online);
                        if ( not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid] and CT_RaidTracker_Options["AutoRaidCreation"] == true) then
                            CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid] = {
                                ["Loot"] = { },
                                ["Join"] = { },
                                ["Leave"] = { },
                                ["PlayerInfos"] = { },
                                ["BossKills"] = { },
                            };
                        end
                        if( CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid] ) then
                            if ( not online ) then
                                if ( online ~= CT_RaidTracker_Online[name] ) then
                                    tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                                        {
                                            ["player"] = name,
                                            ["time"] = CT_RaidTracker_Date()
                                        }
                                    );
                                    CT_RaidTracker_Debug("OFFLINE", name, CT_RaidTracker_Date());
                                end
                            else
                                tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Join"],
                                    {
                                        ["player"] = name,
                                        --["race"] = race,
                                        --["class"] = class,
                                        --["level"] = level,
                                        ["time"] = CT_RaidTracker_Date()
                                    }
                                    );
                                CT_RaidTracker_Debug("ONLINE", name, CT_RaidTracker_Date());
                            end
                            updated = 1;
                        end
                    CT_RaidTracker_Online[name] = online;
                end
            end
        end
        if ( updated ) then
            CT_RaidTracker_Update();
            CT_RaidTracker_UpdateView();
        end

    -- Party code added thx to Gof
    elseif ( GetNumGroupMembers() == 0 and (event == "PARTY_MEMBERS_CHANGED" or event == "PLAYER_ENTERING_WORLD")) then
        if ( GetNumGroupMembers() == 0 and event == "PARTY_MEMBERS_CHANGED" and CT_RaidTracker_GetCurrentRaid) then
            local raidendtime = CT_RaidTracker_Date();
            for k, v in pairs(CT_RaidTracker_Online) do
             CT_RaidTracker_Debug("ADDING LEAVE", k, raidendtime);
                tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                    {
                        ["player"] = k,
                        ["time"] = raidendtime,
                    }
                );
            end
            if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["End"]) then
                CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["End"] = raidendtime;
            end
            CT_RaidTracker_GetCurrentRaid = nil;
            CT_RaidTracker_Debug("Left raid.","GetNumGroupMembers() == 0");
            CT_RaidTracker_Offline = { };
            CT_RaidTracker_UpdateView();
            CT_RaidTracker_Update();
        elseif ( not CT_RaidTracker_GetCurrentRaid and GetNumGroupMembers() > 0 and event == "PARTY_MEMBERS_CHANGED" and CT_RaidTracker_Options["AutoGroup"] == 1) then
            CT_RaidTrackerCreateNewRaid();
        end
        if ( not CT_RaidTracker_GetCurrentRaid ) then
            return;
        end
        local updated;
        for i = 1, GetNumGroupMembers(), 1 do
            local name, online = GetFixedUpUnitName("party" .. i, true), UnitIsConnected("party" .. i);
            if ( name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                local _, race = UnitRace("party" .. i);
                local _, class = UnitClass("party" .. i);
                local level = UnitLevel("party" .. i);
                local guild = GetGuildInfo("party" .. i);

                if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"]) then
                    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"] = { };
                end
                if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]) then
                    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name] = { };
                end
                if(CT_RaidTracker_Options["SaveExtendedPlayerInfo"] == 1) then
                    if(race) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["race"] = race; end
                    if(class) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["class"] = class; end
                    if(level > 0) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["level"] = level; end
                    if(guild) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["guild"] = guild; end
                end
                if ( online ~= CT_RaidTracker_Online[name] ) then
                    -- Status isn't updated
                    CT_RaidTracker_Debug("Status isn't updated", name, online);
                    if ( not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid] and CT_RaidTracker_Options["AutoRaidCreation"] == true) then
                        CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid] = {
                            ["Loot"] = { },
                            ["Join"] = { },
                            ["Leave"] = { },
                            ["PlayerInfos"] = { },
                            ["BossKills"] = { },
                        };
                    end
                    if( CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid] ) then
                        if ( not online ) then
                            if ( online ~= CT_RaidTracker_Online[name] ) then
                                tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                                    {
                                        ["player"] = name,
                                        ["time"] = CT_RaidTracker_Date()
                                    }
                                );
                                CT_RaidTracker_Debug("OFFLINE", name, CT_RaidTracker_Date());
                            end
                        else
                            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Join"],
                                {
                                    ["player"] = name,
                                    --["race"] = race,
                                    --["class"] = class,
                                    --["level"] = level,
                                    ["time"] = CT_RaidTracker_Date()
                                }
                                );
                            CT_RaidTracker_Debug("ONLINE", name, CT_RaidTracker_Date());
                        end
                        updated = 1;
                    end
                end
                CT_RaidTracker_Online[name] = online;
            end
        end

        --Party dosent include player himself, so add him

        local name, online = GetFixedUpUnitName("player", true), UnitIsConnected("player");
        if ( name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
            local _, race = UnitRace("player");
            local _, class = UnitClass("player");
            local level = UnitLevel("player");
            local guild = GetGuildInfo("player");

            if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"]) then
                CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"] = { };
            end
            if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]) then
                CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name] = { };
            end
            if(CT_RaidTracker_Options["SaveExtendedPlayerInfo"] == 1) then
                if(race) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["race"] = race; end
                if(class) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["class"] = class; end
                if(level > 0) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["level"] = level; end
                if(guild) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["guild"] = guild; end
            end
            if ( online ~= CT_RaidTracker_Online[name] ) then
                -- Status isn't updated
                CT_RaidTracker_Debug("Status isn't updated", name, online);
                if ( not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid] and CT_RaidTracker_Options["AutoRaidCreation"] == true) then
                    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid] = {
                        ["Loot"] = { },
                        ["Join"] = { },
                        ["Leave"] = { },
                        ["PlayerInfos"] = { },
                        ["BossKills"] = { },
                    };
                end
                if( CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid] ) then
                    if ( not online ) then
                        if ( online ~= CT_RaidTracker_Online[name] ) then
                            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                                {
                                    ["player"] = name,
                                    ["time"] = CT_RaidTracker_Date()
                                }
                            );
                            CT_RaidTracker_Debug("OFFLINE", name, CT_RaidTracker_Date());
                        end
                    else
                        tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Join"],
                            {
                                ["player"] = name,
                                --["race"] = race,
                                --["class"] = class,
                                --["level"] = level,
                                ["time"] = CT_RaidTracker_Date()
                            }
                            );
                        CT_RaidTracker_Debug("ONLINE", name, CT_RaidTracker_Date());
                    end
                    updated = 1;
                end
            end
            CT_RaidTracker_Online[name] = online;
        end
        if ( updated ) then
            CT_RaidTracker_Update();
            CT_RaidTracker_UpdateView();
        end
    -- Party code end
    elseif ( event == "CHAT_MSG_LOOT" and CT_RaidTracker_GetCurrentRaid  and CT_RaidTracker_Options["DKPmonLoggingMode"] == false) then
        if(not testo) then
            testo = {};
        end
        tinsert(testo, arg1);
        local sPlayer, sLink, sPlayerName, sItem, iCount;
        CT_RaidTracker_Debug("item award arg1", arg1);
        CT_RaidTracker_Debug(string.sub(arg1,1,-2));
        CT_RaidTracker_Debug(string.sub(arg1,1,-5));
        
        CT_RaidTracker_Debug("Loot Type",CT_RaidTracker_lang_ReceivesLoot2);
        
        if(string.find(arg1, CT_RaidTracker_lang_ReceivesLoot1)) then
            CT_RaidTracker_Debug("CT_RaidTracker_lang_ReceivesLoot1");
            iStart, iEnd, sPlayerName, sItem = string.find(arg1, CT_RaidTracker_lang_ReceivesLoot1);
            iCount = 1;
            CT_RaidTracker_Debug("itemdropped1", "format", 1, sPlayerName, sItem, iCount);
        elseif(string.find(arg1, CT_RaidTracker_lang_ReceivesLoot2)) then
            CT_RaidTracker_Debug("CT_RaidTracker_lang_ReceivesLoot2");
            iStart, iEnd, sItem = string.find(arg1, CT_RaidTracker_lang_ReceivesLoot2);
            iCount = 1;
            sPlayerName = YOU;
            CT_RaidTracker_Debug("itemdropped2", "format", 2, sPlayerName, sItem, iCount);
        elseif(string.find(arg1, CT_RaidTracker_lang_ReceivesLoot3)) then
            CT_RaidTracker_Debug("CT_RaidTracker_lang_ReceivesLoot3");
            iStart, iEnd, sPlayerName, sItem, iCount = string.find(arg1, CT_RaidTracker_lang_ReceivesLoot3);
            CT_RaidTracker_Debug("itemdropped3", "format", 3, sPlayerName, sItem, iCount);
        elseif(string.find(arg1, CT_RaidTracker_lang_ReceivesLoot4)) then
            CT_RaidTracker_Debug("CT_RaidTracker_lang_ReceivesLoot4");
            iStart, iEnd, sItem, iCount = string.find(arg1, CT_RaidTracker_lang_ReceivesLoot4);
            sPlayerName = YOU;
            CT_RaidTracker_Debug("itemdropped4", "format", 4, sPlayerName, sItem, iCount);
        elseif(CT_RaidTracker_Options["BonusLoot"] == true) then
            if(string.find(arg1, CT_RaidTracker_lang_ReceivesLoot5)) then
                CT_RaidTracker_Debug("CT_RaidTracker_lang_ReceivesLoot5");
                iStart, iEnd, sPlayerName, sItem, iCount = string.find(arg1, CT_RaidTracker_lang_ReceivesLoot5);
                CT_RaidTracker_Debug("itemdropped5", "format", 5, sPlayerName, sItem, iCount);
            elseif(string.find(arg1, CT_RaidTracker_lang_ReceivesLoot6)) then
                CT_RaidTracker_Debug("CT_RaidTracker_lang_ReceivesLoot6");
                iStart, iEnd, sPlayerName, sItem, iCount = string.find(arg1, CT_RaidTracker_lang_ReceivesLoot6);
                sPlayerName = YOU;
                CT_RaidTracker_Debug("itemdropped6", "format", 6, sPlayerName, sItem, iCount);
            end
        end
        CT_RaidTracker_Debug("itemdropped", "link", sItem);
        if ( sPlayerName ) then
            if(sPlayerName == YOU) then
                CT_RaidTracker_Debug("itemdropped", "It's me");
                sPlayer = GetFixedUpUnitName("player", true);
            else
                CT_RaidTracker_Debug("itemdropped", "It's sombody else");
                sPlayer = GetFixedUpUnitName(sPlayerName);
            end
            sLink = sItem;
        end
        iCount = tonumber(iCount);
        if(not iCount) then
            iCount = 1;
        end
        CT_RaidTracker_Debug("itemdropped", sPlayer, sLink, iCount);
        -- Make sure there is a link
        if ( sLink and sPlayer ) then
            CT_RaidTracker_Debug("itemdropped-slink", sLink);
            CT_RaidTracker_Debug("itemdropped-splayer", sPlayer);
            local sColor, sItem, sName = CT_RaidTracker_GetItemInfo(sLink);
            local itemoptions;
            for key, val in pairs(CT_RaidTracker_ItemOptions) do
                compare, _ = string.find(sItem, val["id"], 1, true);
                if(compare == 1) then
                    itemoptions = val;
                    CT_RaidTracker_Debug("ItemOptions", "FoundItem", key);
                end
            end
            local iotrack, iogroup, iocostsgrabbing, ioaskcosts
            --CT_RaidTracker_Debug("itemdropped-status", tostring(itemoptions["status"]));
            if ( (itemoptions and itemoptions["status"] and itemoptions["status"] == true) or ((sColor and sItem and sName and CT_RaidTracker_RarityTable[sColor] >= CT_RaidTracker_Options["MinQuality"]) and (not itemoptions or not itemoptions["status"]))) then
                CT_RaidTracker_Debug("itemdropped", "item has status");
                -- Insert into table
                if ( not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid] and CT_RaidTracker_Options["AutoRaidCreation"] == true) then
                    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid] = {
                        ["Loot"] = { },
                        ["Join"] = { },
                        ["Leave"] = { },
                        ["PlayerInfos"] = { },
                        ["BossKills"] = { },
                    };
                end
                local found = nil;
                if( CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]) then
                    if( (itemoptions and itemoptions["group"] and itemoptions["group"] == true) or ((CT_RaidTracker_Options["GroupItems"] ~= false and CT_RaidTracker_RarityTable[sColor] <= CT_RaidTracker_Options["GroupItems"]) and (not itemoptions or not itemoptions["group"])) ) then
                        CT_RaidTracker_Debug("Trying to group", sName, sPlayer);
                        for k, v in pairs(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Loot"]) do
                            if ( v["item"]["name"] == sName and v["player"] == sPlayer ) then
                                if ( v["item"]["count"] ) then
                                    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Loot"][k]["item"]["count"] = v["item"]["count"]+iCount;
                                else
                                    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Loot"][k]["item"]["count"] = iCount;
                                end
                                found = 1;
                                CT_RaidTracker_Debug("Grouped", sName, sPlayer, CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Loot"][k]["item"]["count"]);
                                break;
                            end
                        end
                    end
                    if ( not found ) then
                        local nameGIF, linkGIF, qualityGIF, iLevelGIF, minLevelGIF, classGIF, subclassGIF, maxStackGIF, invtypeGIV, iconGIF = GetItemInfo("item:"..sItem);
                        --_, _, iconGIF = string.find(iconGIF, "^.*\\(.*)$");
                        local splitted = { [0] = 0, [1] = 0, [2] = 0, [3] = 0 };
                        local trimed;
                        local i = 0;
                        local sNote, sCosts, sBoss;

                        for item in string.gmatch(string.gsub(sItem, "^%s*(.-)%s*$", "%1") .. ":", "([^:]*):?") do
                            trimed = string.gsub(item, "^%s*(.-)%s*$", "%1");
                            if(string.len(trimed) >= 1) then
                                splitted[i] = trimed;
                                i = i + 1;
                            end
                        end

                        if( (itemoptions and itemoptions["costsgrabbing"] and itemoptions["costsgrabbing"] == true) or ((CT_RaidTracker_Options["GetDkpValue"] ~= 0 and CT_RaidTracker_RarityTable[sColor] >= CT_RaidTracker_Options["GetDkpValue"]) and (not itemoptions or not itemoptions["costsgrabbing"]))) then
                            if(DKPValues and DKPValues[tostring(splitted[0])]) then -- AdvancedItemTooltip
                                sCosts = tonumber(DKPValues[tostring(splitted[0])]);
                            elseif(HDKP_GetDKP) then -- HoB_DKP
                                sCosts = tonumber(HDKP_GetDKP(splitted[0], splitted[1], splitted[2], splitted[3]));
                            end
                            CT_RaidTracker_Debug("Splitted", splitted[0], splitted[1], splitted[2], splitted[3]);
                            if(sCosts == 0) then
                                sCosts = nil;
                            end
                        end

                        if(CT_RaidTracker_Options["AutoBoss"] >= 1) then
                            sBoss = CT_RaidTracker_Options["AutoBossBoss"];
                        end

                        local tAttendees = { };
                        if(CT_RaidTracker_Options["LogAttendees"] == 2) then
                            if((IsInRaid() == true) and (GetNumGroupMembers() > 0)) then
                                for i = 1, GetNumGroupMembers() do
                                    local rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
                                    local name = GetFixedUpUnitName("raid" .. i, true);
                                    if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                                        tinsert(tAttendees, name);
                                    end
                                end
                            elseif( (GetNumGroupMembers() > 0) and (CT_RaidTracker_Options["LogGroup"] == true)) then
                                for i = 1, GetNumGroupMembers() do
                                    local online = UnitIsConnected("party" .. i);
                                    local name = GetFixedUpUnitName("party" .. i, true);
                                    if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                                        tinsert(tAttendees, name);
                                    end
                                end
                                --Party dosent include player, so add individual
                                local online = UnitIsConnected("player");
                                local name = GetFixedUpUnitName("player", true);
                                if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                                    tinsert(tAttendees, name);
                                end
                            end
                            for k,v in pairs(CT_RaidTracker_WaitList) do
                                tinsert(tAttendees, k);
                            end
                        end

                        local tTooltip = { };
                        if(CT_RaidTracker_Options["SaveTooltips"] == true) then
                            tTooltip = CT_RaidTracker_GetItemTooltip(sItem);
                        end

                        local sTime = CT_RaidTracker_Date();
                        local foundValue = "|c" .. sColor .. "|Hitem:" .. sItem .. "|h[" .. sName .. "]|h|r";
                        --sNote = "0 DKP";
                        --GDKP_Output("foundValue = " .. foundValue,"lokal");
                        --if (bidWinnerHistory ~= nil) then
                        --    local foundValue;
                        --    for i=1,table.getn(bidWinnerHistory) do
                        --        foundValue = "|c" .. sColor .. "|Hitem:" .. sItem .. "|h[" .. sName .. "]|h|r";
                        --        --GDKP_Output(foundValue,"lokal");
                        --        if (bidWinnerHistory[i][3] == foundValue) then
                        --            if (bidWinnerHistory[i][1] == sPlayer) then
                        --                sNote = bidWinnerHistory[i][2] .. " DKP";
                        --                --table.remove(bidWinnerHistory, i);
                        --                break;
                        --            end
                        --        end
                        --    end
                        --end

                        -- if we are in DKPmon logging mode then we turn off the auto logging
                        CT_RaidTracker_Debug("itemdropped-logging mode", tostring(CT_RaidTracker_Options["DKPmonLoggingMode"]));
                        if (CT_RaidTracker_Options["DKPmonLoggingMode"] == false) then
                            CT_RaidTracker_Debug("itemdropped-logging mode", "rt");
                            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Loot"], 1,
                                {
                                    ["player"] = sPlayer,
                                    ["item"] = {
                                        ["c"] = sColor,
                                        ["id"] = sItem,
                                        ["tooltip"] = tTooltip,
                                        ["name"] = sName,
                                        ["icon"] = iconGIF,
                                        ["count"] = iCount,
                                        ["class"] = classGIF,
                                        ["subclass"] = subclassGIF,
                                        ["subclass"] = subclassGIF,
                                    },
                                    ["zone"] = GetRealZoneText(),
                                    ["costs"] = sCosts,
                                    ["boss"] = sBoss,
                                    ["time"] = sTime,
                                    ["note"] = sNote,
                                    ["attendees"] = tAttendees,
                                    ["event_source"] = "Raid Tracker",
                                }
                            );
                            CT_RaidTracker_Debug("itemdropped-ask costs", tostring(CT_RaidTracker_Options["AskCost"]));
                            CT_RaidTracker_Debug("itemdropped-ask costs", tostring(CT_RaidTracker_RarityTable[sColor]));

                            if ( (itemoptions and itemoptions["askcosts"] and itemoptions["askcosts"] == true) or ((CT_RaidTracker_Options["AskCost"] ~= 0 and CT_RaidTracker_RarityTable[sColor] >= CT_RaidTracker_Options["AskCost"]) and (not itemoptions or not itemoptions["askcosts"])) ) then -- code and idea from tlund
                                if(CT_RaidTracker_Options["AutoSetEPGPCost"] == true)then
                                    sCosts = GPLib:GetValue(sLink);
                                    CT_RaidTracker_Debug("itemitemid:", itemitemid, "cost:", scosts);
                                    CT_RaidTracker_EditCostsEx(CT_RaidTracker_GetCurrentRaid, 1, sCosts);
                                else
                                    CT_RaidTracker_EditCosts(CT_RaidTracker_GetCurrentRaid, 1);
                                end
                            end
                        elseif (CT_RaidTracker_Options["DKPmonLoggingMode"] == true) then
                            CT_RaidTracker_Debug("itemdropped-logging mode", "dkpmon");
                            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Loot"], 1,
                                {
                                    ["player"] = sPlayer,
                                    ["item"] = {
                                        ["c"] = sColor,
                                        ["id"] = sItem,
                                        ["tooltip"] = tTooltip,
                                        ["name"] = sName,
                                        ["icon"] = iconGIF,
                                        ["count"] = iCount,
                                        ["class"] = classGIF,
                                        ["subclass"] = subclassGIF,
                                        ["subclass"] = subclassGIF,
                                    },
                                    ["zone"] = GetRealZoneText(),
                                    ["costs"] = sCosts,
                                    ["boss"] = sBoss,
                                    ["time"] = sTime,
                                    ["note"] = sNote,
                                    ["attendees"] = tAttendees,
                                    ["event_source"] = "DKPmon",
                                }
                            );
                            CT_RaidTracker_Debug("itemdropped-ask costs", tostring(itemoptions["askcosts"]));
                            CT_RaidTracker_Debug("itemdropped-ask costs", tostring(CT_RaidTracker_Options["AskCost"]));
                            CT_RaidTracker_Debug("itemdropped-ask costs", tostring(CT_RaidTracker_RarityTable[sColor]));

                            if ( (itemoptions and itemoptions["askcosts"] and itemoptions["askcosts"] == true) or ((CT_RaidTracker_Options["AskCost"] ~= 0 and CT_RaidTracker_RarityTable[sColor] >= CT_RaidTracker_Options["AskCost"]) and (not itemoptions or not itemoptions["askcosts"])) ) then -- code and idea from tlund
                                if(CT_RaidTracker_Options["AutoSetEPGPCost"] == true)then
                                    sCosts = GPLib:GetValue(sLink);
                                    CT_RaidTracker_Debug("itemitemid:", itemitemid, "cost:", scosts);
                                    CT_RaidTracker_EditCostsEx(CT_RaidTracker_GetCurrentRaid, 1, sCosts);
                                else
                                    CT_RaidTracker_EditCosts(CT_RaidTracker_GetCurrentRaid, 1);
                                end
                            end
                        end
                    end
                end

                CT_RaidTracker_Debug(sPlayer, sColor, sItem, sName);
                CT_RaidTracker_Update();
                CT_RaidTracker_UpdateView();
            end
        end

    elseif ( event == "CHAT_MSG_SYSTEM" and GetFixedUpUnitName("player") and GetFixedUpUnitName("player") ~= UKNOWNBEING and GetFixedUpUnitName("player") ~= UNKNOWN and CT_RaidTracker_GetCurrentRaid ) then
        local sDate = CT_RaidTracker_Date();
        local iStart, iEnd, sPlayer = string.find(arg1, CT_RaidTracker_lang_LeftGroup);
        if ( sPlayer and sPlayer ~= GetFixedUpUnitName("player") and sPlayer ~= UKNOWNBEING and sPlayer ~= UNKNOWN and CT_RaidTracker_Online[sPlayer]) then
            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                {
                    ["player"] = sPlayer,
                    ["time"] = sDate
                }
            );
            CT_RaidTracker_Online[sPlayer] = nil;
            CT_RaidTracker_Debug(sPlayer, "LEFT", sDate);
        end
        --[[
        local race, lass, level;
        local iStart, iEnd, sPlayer = string.find(arg1, CT_RaidTracker_lang_JoinedGroup);
        if ( sPlayer and sPlayer ~= UnitName("player") and sPlayer ~= UKNOWNBEING and sPlayer ~= UNKNOWN) then
            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Join"],
                {
                    ["player"] = sPlayer,
                    ["time"] = sDate
                }
            );
            CT_RaidTracker_Debug(sPlayer, "JOIN", sDate);
        end
        ]]

        CT_RaidTracker_UpdateView();
        CT_RaidTracker_Update();

    elseif ( event == "VARIABLES_LOADED" ) then
        CT_RaidTrackerFrame:CreateTitleRegion()
        CT_RaidTrackerFrame:GetTitleRegion():SetAllPoints()
        CT_RaidTracker_RunVersionFix();
        ML_RaidTracker_LoadCustomOptions();
        CT_RaidTracker_GetGameTimeOffset();
    elseif ( event == "UPDATE_MOUSEOVER_UNIT" ) then
        if(CT_RaidTracker_Options["AutoBoss"] == 1) then
            local autoboss_unitname = GetFixedUpUnitName("mouseover");
            local autoboss_newboss;
            if(not UnitIsFriend("mouseover", "player") and not UnitInRaid("mouseover") and not UnitInParty("mouseover")) then
                --CT_RaidTracker_Debug("possible mouseover unit update", autoboss_unitname);
                if(CT_RaidTracker_BossUnitTriggers[autoboss_unitname]) then
                    if(CT_RaidTracker_BossUnitTriggers[autoboss_unitname] ~= "IGNORE") then
                        autoboss_newboss = CT_RaidTracker_BossUnitTriggers[autoboss_unitname];
                        CT_RaidTracker_AutoBossChangedTime = GetTime();
                        CT_RaidTracker_Debug("AutoBossChangedTime set to ", CT_RaidTracker_AutoBossChangedTime,"mouseover");
                    end
                elseif(CT_RaidTracker_BossUnitTriggers["DEFAULTBOSS"] and (CT_RaidTracker_RealBossChangeTime == 0 or (GetTime() > (CT_RaidTracker_AutoBossChangedTime + CT_RaidTracker_RealBossChangeTime)))) then
                    autoboss_newboss = CT_RaidTracker_BossUnitTriggers["DEFAULTBOSS"];
                    CT_RaidTracker_Debug("AutoBossChangedTime expired ", CT_RaidTracker_AutoBossChangedTime,"mouseover");
                else
                    autoboss_newboss = nil
                    CT_RaidTracker_Debug("AutoBossChangedTime expires in ", (CT_RaidTracker_AutoBossChangedTime + CT_RaidTracker_RealBossChangeTime)-GetTime(),"mouseover");
                end
                if(autoboss_newboss and CT_RaidTracker_Options["AutoBossBoss"] ~= autoboss_newboss) then
                    CT_RaidTracker_Options["AutoBossBoss"] = autoboss_newboss;
                    CT_RaidTracker_Print("CT_RaidTracker AutoBoss Update: "..autoboss_newboss, 1, 1, 0);
                end
            end
        end
    elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
        CT_RaidTracker_Debug("Zone Changed", CT_RaidTracker_Options["AutoZone"]);
        if(CT_RaidTracker_Options["AutoZone"] == true) then
            CT_RaidTracker_DoZoneCheck();
            CT_RaidTracker_DoRaidIdCheck();
        end
    elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED" and arg2 == "UNIT_DIED" ) then
        CT_RaidTracker_BossKill(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
        
    elseif ( event == "UNIT_HEALTH" ) then
        -- check for wipe count
        if (CT_RaidTracker_Options["Wipe"] == false) then
            return -- wipecounting is disabled
        end;
        if (InCombatLockdown()) then
            return -- we are in combat and don't want to ask if this is a wipe if one of this members died and he tried to heal him ;-)
        end;
        if (not CT_RaidTracker_GetCurrentRaid) then
            return -- no raid tracking
        end;
        if (GetTime() < CT_RaidTracker_LastWipe) then
            return -- wipe cooldown
        end;
        local membercount = 0;
        local unitprefix = 0;
        local memberdead = 0;
        if ((IsInRaid() == true) and (GetNumGroupMembers() > 0)) then -- in raid and active
            membercount = GetNumGroupMembers();
            unitprefix = "raid";
        elseif ( GetNumGroupMembers() > 0) then -- in group and active
            membercount = GetNumGroupMembers()+1;
            unitprefix = "party";
            if (UnitIsDeadOrGhost("player")) then
                memberdead = memberdead + 1;
            end;
        else
            return -- not in group
        end;
        for i = 1, membercount, 1 do
            if (UnitIsDeadOrGhost(unitprefix..i)) then
                memberdead = memberdead + 1;
            end;
        end;
        if (memberdead == membercount) then
            CT_RaidTracker_AddWipe();
            CT_RaidTrackerAcceptWipeFrame:Hide();
            return;
        end;
        if ((memberdead / membercount) > CT_RaidTracker_Options["WipePercent"]) then
            CT_RaidTrackerAcceptWipeFrame:Show();

        end;
    elseif ( event == "UPDATE_INSTANCE_INFO" ) then
        CT_RaidTracker_Debug("UPDATE_INSTANCE_INFO");
        CT_RaidTracker_DoRaidIdCheck();
    end
end

function CT_RaidTracker_BossKill(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
        local CT_RaidTracker_RealBossChangeTime = CT_RaidTracker_Options["AutoBossChangeMinTime"]*60;

        local bosskilled, autoboss_newboss;
        local sDate = CT_RaidTracker_Date();
        CT_RaidTracker_Debug('1',arg1);
        CT_RaidTracker_Debug('2',arg2);
        CT_RaidTracker_Debug("3",arg3);
        CT_RaidTracker_Debug('4',arg4);
        CT_RaidTracker_Debug('5',arg5);
        CT_RaidTracker_Debug('6',arg6);
        CT_RaidTracker_Debug('7',arg7);
        CT_RaidTracker_Debug('8',arg8);
        CT_RaidTracker_Debug('9',arg9);        
        CT_RaidTracker_Debug("COMBAT_LOG_EVENT_UNFILTERED","The mob you just killed is"..arg9);
        local unit = arg9
--        for unit in string.gmatch(arg9, CT_RaidTracker_ConvertGlobalString(UNITDIESOTHER)) do

            CT_RaidTracker_Debug("COMBAT_LOG_EVENT_UNFILTERED","unit", unit);
            if(CT_RaidTracker_Options["AutoBoss"] == 2 and CT_RaidTracker_GetCurrentRaid) then
                if(not CT_RaidTracker_Online[unit]) then
                    if(CT_RaidTracker_BossUnitTriggers[unit]) then
                        if(CT_RaidTracker_BossUnitTriggers[unit] ~= "IGNORE") then
                            autoboss_newboss = CT_RaidTracker_BossUnitTriggers[unit];
                            CT_RaidTracker_AutoBossChangedTime = GetTime();
                            CT_RaidTracker_Debug("AutoBossChangedTime set to ", CT_RaidTracker_AutoBossChangedTime,"kill");
                        end
                    elseif(CT_RaidTracker_BossUnitTriggers["DEFAULTBOSS"] and (CT_RaidTracker_RealBossChangeTime == 0 or (GetTime() > (CT_RaidTracker_AutoBossChangedTime + CT_RaidTracker_RealBossChangeTime)))) then
                        autoboss_newboss = CT_RaidTracker_BossUnitTriggers["DEFAULTBOSS"];
                        CT_RaidTracker_Debug("AutoBossChangedTime expired ", CT_RaidTracker_AutoBossChangedTime,"kill");
                    else
                        autoboss_newboss = nil
                        CT_RaidTracker_Debug("AutoBossChangedTime expires in ", (CT_RaidTracker_AutoBossChangedTime + CT_RaidTracker_RealBossChangeTime)-GetTime(),"kill");
                    end
                    if(autoboss_newboss and CT_RaidTracker_Options["AutoBossBoss"] ~= autoboss_newboss) then
                        CT_RaidTracker_Options["AutoBossBoss"] = autoboss_newboss;
                        CT_RaidTracker_Print("CT_RaidTracker AutoBoss Update: "..autoboss_newboss.." ("..unit..")", 1, 1, 0);
                    end
                end
            end

            if(CT_RaidTracker_GetCurrentRaid and CT_RaidTracker_BossUnitTriggers[unit] and CT_RaidTracker_BossUnitTriggers[unit] ~= "IGNORE") then
                local newboss = 1;
                -- Romulo and Julianne Hack
                if (CT_RaidTracker_BossUnitTriggers[unit] == "Romulo and Julianne") then
                    if (julianne_died == false) then
                        return;
                    end;
                end
                -- Romulo and Julianne Hack
                bosskilled = CT_RaidTracker_BossUnitTriggers[unit];
                if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"]) then
                    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"] = { };
                end
                -- is the boss already killed?
                for key, val in pairs(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"]) do
                    if(val["boss"] == bosskilled) then
                        newboss = 0;
                    end
                end
                if (newboss == 1) then
                    local tAttendees = { };
                    local tAttendeesWaitlist = { };
                    if( (CT_RaidTracker_Options["LogAttendees"] == 1) or (CT_RaidTracker_Options["LogAttendees"] == 3)) then
                        if( GetNumGroupMembers() > 0 ) then
                            for i = 1, GetNumGroupMembers() do
                                local rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
                                local name = GetFixedUpUnitName("raid" .. i, true);
                                if (name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                                    if (CT_RaidTracker_Options["LogAttendees"] == 3)then
                                        if (zone==GetRealZoneText()) then
                                            tinsert(tAttendees, name);
                                        end;
                                    else
                                        tinsert(tAttendees, name);
                                    end;
                                end
                            end
                        elseif( (GetNumGroupMembers() > 0) and (CT_RaidTracker_Options["LogGroup"] == true) ) then
                            for i = 1, GetNumGroupMembers() do
                                local name = GetFixedUpUnitName("party" .. i, true);
                                if (name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                                    tinsert(tAttendees, name);
                                end
                            end
                            --Party dosent include player, so add individual
                            local name = GetFixedUpUnitName("player", true);
                            if (name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                                tinsert(tAttendees, name);
                            end
                        end
                        
                        if (CT_RaidTracker_Options["WaitlistAttendanceType"] == 1) then                        
                            for k,v in pairs(CT_RaidTracker_WaitList) do
                                tinsert(tAttendees, k);
                            end
                        elseif (CT_RaidTracker_Options["WaitlistAttendanceType"] == 2) then
                            for k,v in pairs(CT_RaidTracker_WaitList) do
                                tinsert(tAttendeesWaitlist, k);
                            end                        
                        else
                            for k,v in pairs(CT_RaidTracker_WaitList) do
                                tinsert(tAttendees, k);
                            end    
                        end
                    end

                    -- BOSS KILL TRACKING
                    
                    if (CT_RaidTracker_Options["DKPmonLoggingMode"] == false) then
                        tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"],
                            {
                                ["boss"] = bosskilled,
                                ["time"] = sDate,
                                ["attendees"] = tAttendees,
                                ["event_source"] = "Raid Tracker",
                            }
                        );
                    elseif (CT_RaidTracker_Options["DKPmonLoggingMode"] == true) then
                        tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"],
                            {
                                ["boss"] = bosskilled,
                                ["time"] = sDate,
                                ["attendees"] = tAttendees,
                                ["event_source"] = "DKPmon",
                            }
                        );
                        -- add wait listers if there are any
                        if (#(tAttendeesWaitlist) > 0) then                                                    
                            if (CT_RaidTracker_Options["WaitlistAttendanceType"] == 2) then
                                tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"],
                                    {
                                    ["boss"] = bosskilled .. " - Waitlist",
                                    ["time"] = sDate,
                                    ["attendees"] = tAttendeesWaitlist,
                                    ["event_source"] = "Raid Tracker",
                                    }
                                );                    
                            end
                        end
                     end
                  CT_RaidTracker_Print("CT_RaidTracker Boss Kills: Set kill time for \""..bosskilled.."\" to "..sDate, 1, 1, 0);
                  if (CT_RaidTracker_Options["NextBoss"] == true) then
                      CT_RaidTrackerNextBossFrame:Show();
                  end;
                    if( CT_RaidTracker_Options["GuildSnapshot"] == true) then
                        CT_RaidTrackerAddGuild();
                end;

                end

                --if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"][bosskilled]) then
                --    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"][bosskilled] = sDate;
                --    CT_RaidTracker_Print("CT_RaidTracker Boss Kills: Set kill time for \""..bosskilled.."\" to "..sDate, 1, 1, 0);
                --end
            end
--        end
end

function CT_RaidTracker_AddWipe()
    CT_RaidTracker_Debug("WIPED");

    -- check for a raid
    if (CT_RaidTracker_GetCurrentRaid == nil) then
        CT_RaidTracker_Print("You must have started a raid to use this function. Type '/rt' and then click 'New' to start a raid.", 1, 1, 0);
        return false;
    end;

    CT_RaidTracker_LastWipe = GetTime()+CT_RaidTracker_Options["WipeCoolDown"]; -- wait for 120 seconds
    if (CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["wipes"] == nil) then
        CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["wipes"] = {};
    end;

    local tAttendees = { };
    if(CT_RaidTracker_Options["LogAttendees"] ~= 0) then
        if((IsInRaid() == true) and (GetNumGroupMembers() > 0)) then
            for i = 1, GetNumGroupMembers() do
                local rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
                local name = GetFixedUpUnitName("raid" .. i, true);
                if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                    tinsert(tAttendees, name);
                end
            end
        elseif( (GetNumGroupMembers() > 0) and (CT_RaidTracker_Options["LogGroup"] == true) ) then
            for i = 1, GetNumGroupMembers() do
                local online = UnitIsConnected("party" .. i);
                local name = GetFixedUpUnitName("party" .. i, true);
                if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                    tinsert(tAttendees, name);
                end
            end
            --Party dosent include player, so add individual
            local online = UnitIsConnected("player");
            local name = GetFixedUpUnitName("player", true);
            if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                tinsert(tAttendees, name);
            end
        end
        for k,v in pairs(CT_RaidTracker_WaitList) do
            tinsert(tAttendees, k);
        end
    end

    tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["wipes"],
                        {
                            ["time"] = CT_RaidTracker_Date(),
                            ["attendees"] = tAttendees
                        }
                        );

    CT_RaidTracker_Klaxxi_Status = 0;
    CT_RaidTracker_Maidens_Status = 0;

    CT_RaidTracker_Print("Wipe has been recorded!", 1, 1, 0);
end;

function CT_RaidTracker_AddAttendance()
    CT_RaidTracker_Debug("ATTENDANCE");

    -- check for a raid
    if (CT_RaidTracker_GetCurrentRaid == nil) then
        CT_RaidTracker_Print("You must have started a raid to use this function. Type '/rt' and then click 'New' to start a raid.", 1, 1, 0);
        return false;
    end;

    if (CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["attendances"] == nil) then
        CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["attendances"] = {};
    end;

    local tAttendees = { };
    if(CT_RaidTracker_Options["LogAttendees"] ~= 0) then
        if((IsInRaid() == true) and (GetNumGroupMembers() > 0)) then
            for i = 1, GetNumGroupMembers() do
                local rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
                local name = GetFixedUpUnitName("raid" .. i, true);
                --print(name);
                if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                    tinsert(tAttendees, name);
                end
            end
        elseif( (GetNumGroupMembers() > 0) and (CT_RaidTracker_Options["LogGroup"] == true) ) then
            for i = 1, GetNumGroupMembers() do
                local online = UnitIsConnected("party" .. i);
                local name = GetFixedUpUnitName("party" .. i, true);
                --print(name);
                if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                    tinsert(tAttendees, name);
                end
            end
            --Party dosent include player, so add individual
            local online = UnitIsConnected("player");
            local name = GetFixedUpUnitName("player", true);
            --print(name);
            if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                tinsert(tAttendees, name);
            end
        end
        for k,v in pairs(CT_RaidTracker_WaitList) do
            tinsert(tAttendees, k);
        end
    end

    tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["attendances"],
                        {
                            ["time"] = CT_RaidTracker_Date(),
                            ["attendees"] = tAttendees
                        }
                        );

    CT_RaidTracker_Print("Attendance has been recorded!", 1, 1, 0);
end;

function CT_RaidTackes_NextBoss(name)
    CT_RaidTracker_Debug("NEXTBOSS",name);
    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["nextboss"] = name;
end;

function CT_RaidTracker_DoZoneCheck()
    CT_RaidTracker_Debug("New Zone Check",1);
    if(not CT_RaidTracker_GetCurrentRaid) then
        return;
    end
    CT_RaidTracker_Debug("New Zone Check",2);
    local newzone = GetRealZoneText();
    CT_RaidTracker_Debug("Current Zone",newzone);
    local checkednewzone = "";
    for k, v in pairs(CT_RaidTracker_ZoneTriggers) do
        if(newzone == k) then
            CT_RaidTracker_Debug("Zone is Instance",v);
            checkednewzone = v;
            break;
        end
    end
    CT_RaidTracker_Debug("New Zone Check",3);
    for k, v in pairs(CT_RaidTracker_CustomZoneTriggers) do
        if(newzone == k) then
            CT_RaidTracker_Debug("Zone is Custom Instance",v);
            checkednewzone = v;
            break;
        end
    end

      if (checkednewzone == "") then
          return false;
    end;

    CT_RaidTracker_Debug("New Zone Check",4);
    if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["zone"]) then
        CT_RaidTracker_Debug("Set new Zone",checkednewzone);
            CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["zone"] = checkednewzone;
    else
        if (CT_RaidTracker_Options["NewRaidOnNewZone"]==1) then
            if (checkednewzone ~= "") then
                if (CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["zone"] ~= checkednewzone) then
                    CT_RaidTracker_Debug("Create new Raid while zoning",CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["zone"],newzone,checkednewzone);
                    CT_RaidTracker_Print("Autocreating new Raid cause of zoning.");
                    CT_RaidTrackerCreateNewRaid();
                end
            end
        end
    end

    CT_RaidTracker_Update();
    CT_RaidTracker_UpdateView();

    return true;
end

function CT_RaidTracker_DoRaidIdCheck()
    if(not CT_RaidTracker_GetCurrentRaid) then
        return;
    end
    local savedInstances = GetNumSavedInstances();
    local instanceName, instanceID, instanceReset;
    if ( savedInstances > 0 ) then
        for i=1, MAX_RAID_INFOS do
            if ( i <=  savedInstances) then
                instanceName, instanceID, instanceReset = GetSavedInstanceInfo(i);
                if (CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["zone"] == instanceName) then
                    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["instanceid"] = instanceID;
                    --CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["instancereset"] = instanceReset;
                end;
            end

        end
    end
end;


-- Item functions
function CT_RaidTracker_GetItemInfo(sItem)
    local sStart, sEnde, sColor, sItemName, sName = string.find(sItem, "|c(%x+)|Hitem:([-%d:]+)|h%[(.-)%]|h|r");
  CT_RaidTracker_Debug("sColor:", sColor,"sItemName:", sItemName,"sName:", sName);
    return sColor, sItemName, sName, sStart, sEnde;
end

SlashCmdList["RAIDTRACKER"] = function(msg)
    local _, _, command, args = string.find(msg, "(%w+)%s?(.*)");
    if(command) then
        command = strlower(command);
    end

    if(command == "debug") then
        if(args == "1") then
            CT_RaidTracker_Options["DebugFlag"] = 1;
            CT_RaidTracker_Print("Enabled Debug Output", 1, 1, 0);
        elseif(args == "0") then
            CT_RaidTracker_Options["DebugFlag"] = nil;
            CT_RaidTracker_Print("Disabled Debug Output", 1, 1, 0);
        else
            if(CT_RaidTracker_Options["DebugFlag"] == 1) then
                CT_RaidTracker_Print("Debug Output: Enabled", 1, 1, 0);
            else
                CT_RaidTracker_Print("Debug Output: Disabled", 1, 1, 0);
            end
        end
    elseif(command == "addwipe") then
        CT_RaidTracker_AddWipe();
    elseif(command == "addattendance") then
        CT_RaidTracker_AddAttendance();
    elseif(command == "deleteall") then
        CT_RaidTracker_Print("Deleted "..getn(CT_RaidTracker_RaidLog).." Raids", 1, 1, 0);
        CT_RaidTracker_RaidLog = { };
        CT_RaidTracker_GetCurrentRaid = nil;
        CT_RaidTracker_UpdateView();
        CT_RaidTracker_Update();
    elseif(command == "additem") then
        if(args and args ~= "") then
            local sColor, sItem, sName, sStart, sEnde = CT_RaidTracker_GetItemInfo(args);
            if(sItem and sItem) then
                if (string.len(args) > sEnde+2) then
                    sLooter = string.sub(args,sEnde+2);
                    CT_RaidTracker_Debug("Looter",sLooter);
                    --print (sLooter)
                else
                    CT_RaidTracker_Debug("Kein Looter",sLooter);
                    sLooter = "";
                end;
                if(CT_RaidTrackerFrame.selected) then
                    local nameGIF, linkGIF, qualityGIF, iLevelGIF, minLevelGIF, classGIF, subclassGIF, maxStackGIF, invtypeGIV, iconGIF = GetItemInfo("item:"..sItem);

                    local tAttendees = { };
                    if(CT_RaidTracker_Options["LogAttendees"] == 2) then
                        if((IsInRaid() == true) and (GetNumGroupMembers() > 0)) then
                            for i = 1, GetNumGroupMembers() do
                                local rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
                                local name = GetFixedUpUnitName("raid" .. i, true);
                                if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                                    tinsert(tAttendees, name);
                                end
                            end
                        elseif( (GetNumGroupMembers() > 0) and (CT_RaidTracker_Options["LogGroup"] == true) ) then
                            for i = 1, GetNumGroupMembers() do
                                local online = UnitIsConnected("party" .. i);
                                local name = GetFixedUpUnitName("party" .. i, true);
                                if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                                    tinsert(tAttendees, name);
                                end
                            end
                            --Party dosent include player, so add individual
                            local online = UnitIsConnected("player");
                            local name = GetFixedUpUnitName("player", true);
                            if (name and online and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                                tinsert(tAttendees, name);
                            end
                        end
                        for k,v in pairs(CT_RaidTracker_WaitList) do
                            tinsert(tAttendees, k);
                        end
                    end


                    local tTooltip = { };
                    if(CT_RaidTracker_Options["SaveTooltips"] == true) then
                        tTooltip = CT_RaidTracker_GetItemTooltip(sItem);
                    end

                    local sTime = CT_RaidTracker_Date();
                    tinsert(CT_RaidTracker_RaidLog[CT_RaidTrackerFrame.selected]["Loot"], 1,
                        {
                            ["player"] = sLooter,
                            ["item"] = {
                                ["c"] = sColor,
                                ["id"] = sItem,
                                ["tooltip"] = tTooltip,
                                ["name"] = sName,
                                ["icon"] = iconGIF,
                                ["count"] = 1,
                                ["class"] = classGIF,
                                ["subclass"] = subclassGIF,
                            },
                            ["zone"] = GetRealZoneText(),
                            ["time"] = sTime,
                            ["attendees"] = tAttendees,
                        }
                    );
                    CT_RaidTracker_Print("Add item: Added "..sName, 1, 1, 0);
                    CT_RaidTracker_UpdateView();
                    CT_RaidTracker_Update();
                else
                    CT_RaidTracker_Print("Add item: There is no raid selected", 1, 1, 0);
                end
            else
                CT_RaidTracker_Print("Add item: Invalid Item Link given", 1, 1, 0);
            end
        else
            CT_RaidTracker_Print("Add item: No Item Link given", 1, 1, 0);
        end
    elseif(command == "io") then
        local idfound;
        for idtoadd in string.gmatch(args, "item:(%d+):") do
            idfound = nil;
            idtoadd = tonumber(idtoadd);
            for key, val in pairs(CT_RaidTracker_ItemOptions) do
                if(val["id"] == idtoadd) then
                    idfound = true;
                    break;
                end
            end
            if(idfound) then
                CT_RaidTracker_Print(idtoadd.." is already in the Item Options list", 1, 1, 0);
            else
                tinsert(CT_RaidTracker_ItemOptions, {["id"] = idtoadd});
                CT_RaidTracker_Print("Added "..idtoadd.." to the Item Options list", 1, 1, 0);
                idfound = true;
            end
        end
        if(not idfound) then
            for idtoadd in string.gmatch(args, "(%d+)%s?") do
                idfound = nil;
                idtoadd = tonumber(idtoadd);
                CT_RaidTracker_Debug("idtoadd", idtoadd);
                for key, val in pairs(CT_RaidTracker_ItemOptions) do
                    if(val["id"] == idtoadd) then
                        idfound = true;
                        break;
                    end
                end
                if(idfound) then
                    CT_RaidTracker_Print(idtoadd.." is already in the Item Options list", 1, 1, 0);
                else
                    tinsert(CT_RaidTracker_ItemOptions, {["id"] = idtoadd});
                    CT_RaidTracker_Print("Added "..idtoadd.." to the Item Options list", 1, 1, 0);
                end
            end
        end
        CT_RaidTracker_ItemOptions_ScrollBar_Update();
        CT_RaidTrackerItemOptionsFrame:Show();
    elseif(command == "gptest") then
        CT_RaidTracker_Print(args.." is worth "..GPLib:GetValue(args).." GP", 1, 1, 0);
    elseif(command == "options") then
        CT_RaidTrackerOptionsFrame:Show();
    elseif(command == "o") then
        CT_RaidTrackerOptionsFrame:Show();
    elseif(command == "join") then
        if(CT_RaidTrackerFrame.selected) then
            if(args and strlen(args) > 0) then
                CT_RaidTrackerJoinLeaveFrameNameEB:SetText(args);
            end
            CT_RaidTrackerJoinLeaveFrameTitle = "Join";
            CT_RaidTrackerJoinLeaveFrame.type = "Join";
            CT_RaidTrackerJoinLeaveFrame.raidid = CT_RaidTrackerFrame.selected;
            CT_RaidTrackerJoinLeaveFrame:Show();
        else
            CT_RaidTracker_Print("Join: There is no raid selected", 1, 1, 0);
        end
    elseif(command == "leave") then
        if(CT_RaidTrackerFrame.selected) then
            if(args and strlen(args) > 0) then
                CT_RaidTrackerJoinLeaveFrameNameEB:SetText(args);
            end
            CT_RaidTrackerJoinLeaveFrameTitle = "Leave";
            CT_RaidTrackerJoinLeaveFrame.type = "Leave";
            CT_RaidTrackerJoinLeaveFrame.raidid = CT_RaidTrackerFrame.selected;
            CT_RaidTrackerJoinLeaveFrame:Show();
        else
            CT_RaidTracker_Print("Join: There is no raid selected", 1, 1, 0);
        end
    elseif(command == "waitlist") then
        if (CT_RaidTracker_GetCurrentRaid == nil) then
            CT_RaidTracker_Print("You must have started a raid to use this function. Type '/rt' and then click 'New' to start a raid.", 1, 1, 0);
            return false;
        else
            if(CT_RaidTrackerFrame.selected) then
                if(args and args ~= "") then
                    -- add to joins
                    CT_RaidTrackerJoinLeaveFrameNameEB:SetText(args);
                    CT_RaidTrackerJoinLeaveFrameTitle = "Join";
                    CT_RaidTrackerJoinLeaveFrame.type = "Join";
                    CT_RaidTrackerJoinLeaveFrame.raidid = CT_RaidTrackerFrame.selected;
                    CT_RaidTrackerJoinLeaveFrame:Show();

                    -- add to waitlist
                    CT_RaidTracker_WaitList[args] = 1;
                    CT_RaidTracker_Print(args.." has been added to the waitlist.", 1, 1, 0);
                else
                    CT_RaidTracker_Print("A character name is required.", 1, 1, 0);
                    return false;
                end
            else
                CT_RaidTracker_Print("WaitList: There is no raid selected. Type '/rt' and select a raid before adding players to the waitlist.", 1, 1, 0);
                return false;
            end
        end
    elseif(command == "addevent") then
        CT_RaidTracker_ShowAddEventFrame()
    elseif(command == "toggleminimap") then
        if (GuildLaunchCT_RaidTracker.miniminimapFrame) then
            if (GuildLaunchCT_RaidTracker.minimapFrame:IsVisible()) then
                GuildLaunchCT_RaidTracker:Hide()
            else
                GuildLaunchCT_RaidTracker:Show()
            end
        else
            GuildLaunchCT_RaidTracker.OnMenuRequest = GuildLaunchCT_RaidTracker.Options.fubar
            GuildLaunchCT_RaidTracker:Show()
        end
    elseif(command == "showautoboss") then
        sBoss = CT_RaidTracker_Options["AutoBossBoss"];
        CT_RaidTracker_Print(sBoss.."<--", 1, 1, 0);
    elseif(command == "removewaitlist") then
        if (CT_RaidTracker_GetCurrentRaid == nil) then
            CT_RaidTracker_Print("You must have started a raid to use this function. Type '/rt' and then click 'New' to start a raid.", 1, 1, 0);
            return false;
        else
            if(CT_RaidTrackerFrame.selected) then
                if(args and strlen(args) > 0) then
                    -- add to leaves
                    CT_RaidTrackerJoinLeaveFrameNameEB:SetText(args);
                    CT_RaidTrackerJoinLeaveFrameTitle = "Leave";
                    CT_RaidTrackerJoinLeaveFrame.type = "Leave";
                    CT_RaidTrackerJoinLeaveFrame.raidid = CT_RaidTrackerFrame.selected;
                    CT_RaidTrackerJoinLeaveFrame:Show();

                    -- remove from waitlist
                    CT_RaidTracker_WaitList[args] = nil;
                    CT_RaidTracker_Print(args.." has been removed from the waitlist.", 1, 1, 0);
                else
                    CT_RaidTracker_Print("A character name is required.", 1, 1, 0);
                    return false;
                end
            else
                CT_RaidTracker_Print("Join: There is no raid selected", 1, 1, 0);
                return false;
            end
        end
    elseif(command == "showwaitlist") then
        if (CT_RaidTracker_tcount(CT_RaidTracker_WaitList) == 0) then
            CT_RaidTracker_Print("No players are currently waitlisted.", 1, 1, 0);
        else
            for k,v in pairs(CT_RaidTracker_WaitList) do
                CT_RaidTracker_Print(k);
            end
        end
    elseif(command == "clearwaitlist") then
        CT_RaidTracker_WaitList = {}
        CT_RaidTracker_Print("The waitlist has been cleared.", 1, 1, 0);
    elseif(command == "listme") then
        if (args == "enable") then
            CT_RaidTracker_Options["ListMeEnabled"] = true    
            CT_RaidTracker_Print("Waitlist functionality is now enabled.", 1, 1, 0);        
        elseif(args == "disable") then
            CT_RaidTracker_Options["ListMeEnabled"] = false
            CT_RaidTracker_Print("Waitlist functionality is now disabled.", 1, 1, 0);
        elseif(args == "status") then
            if (CT_RaidTracker_Options["ListMeEnabled"] == false) then
                CT_RaidTracker_Print("Waitlist functionality is currently disabled.", 1, 1, 0);                    
            else
                CT_RaidTracker_Print("Waitlist functionality is currently enabled.", 1, 1, 0);                    
            end
        end
   -- elseif(command == "guids") then
       -- local guid = UnitGUID(1202);
        --print (guid);
        --print ("Oregorger");
    elseif(command == 'killazshara') then
        CT_RaidTracker_Debug("Queen Azshara has Been Defeated");
        CT_RaidTracker_BossKill(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,"Queen Azshara");
    elseif(command) then
        CT_RaidTracker_Print("|cff40bbff/rt|r - Shows the Control Panel", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt options|r - Options", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt io|r - Shows the Item Options Panel", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt io [ITEMLINK(S)/ITEMID(S)]|r - This will add the given item(s) to the Item Options list", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt additem [ITEMLINK] [Looter]|r - This will add the given item to the loot of your selected raid", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt join [PLAYER]|r - Manual player join", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt leave [PLAYER]|r - Manual player leave", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt deleteall|r - Deletes all raids", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt debug 0/1|r - Enables/Disables debug output", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt addwipe|r - Adds a Wipe with the current timestamp", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt addattendance|r - Adds an Attendance event with the current timestamp", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt waitlist [PLAYER]|r - Add A Player To The Waitlist", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt removewaitlist [PLAYER]|r - Removes A Player From The Waitlist", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt showwaitlist|r - Shows the Current Waitlist", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt clearwaitlist|r - Clears the Current Waitlist", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt toggleminimap|r - Toggles the display of the icon on minimap. Will also show the icon on the minimap if it is not displaying anywhere currently. If another Addon such as FuBar is displaying the icon on a bar then this option will have no effect.", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt listme enable|disable|status|r - The Enable and disable commands toggle the listme functionality on and off. The Status command will show you the current state.", 1, 1, 0);        
        CT_RaidTracker_Print("|cff40bbff/rt gptest [ITEMLINK]|r - Will return the GP value for the item using the internal EPGP formula", 1, 1, 0);
        CT_RaidTracker_Print("|cff40bbff/rt killazshara|r - Will trigger a kill event of Queen Azshara.", 1, 1, 0);
    else
        ShowUIPanel(CT_RaidTrackerFrame);
    end
end

function CT_RaidTracker_tcount(tab)
   local n=0;
   for _ in pairs(tab) do
     n=n+1;
   end
   return n;
 end

SLASH_RAIDTRACKER1 = "/raidtracker";
SLASH_RAIDTRACKER2 = "/rt";

function CT_RaidTracker_Print(msg, r, g, b)
    if ( CT_Print ) then
        CT_Print(msg, r, g, b);
    else
        DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b);
    end
end

function CT_RaidTracker_RarityDropDown_OnLoad(this)
    UIDropDownMenu_Initialize(this, CT_RaidTracker_RarityDropDown_Initialize);
    --UIDropDownMenu_SetWidth(130);
    UIDropDownMenu_SetSelectedID(CT_RaidTrackerRarityDropDown, 1);
end

-- Grey = 9d9d9d
-- White = ffffff
-- Green = 1eff00
-- Blue = 0070dd
-- Purple = a335ee
-- Orange = ff8000
-- Red e6cc80

function CT_RaidTracker_RarityDropDown_Initialize()
    local info = {};
    info.text = "|c009d9d9dPoor|r";
    info.func = CT_RaidTracker_RarityDropDown_OnClick;
    UIDropDownMenu_AddButton(info);

    local info = {};
    info.text = "|c00ffffffCommon|r";
    info.func = CT_RaidTracker_RarityDropDown_OnClick;
    UIDropDownMenu_AddButton(info);

    local info = {};
    info.text = "|c001eff00Uncommon|r";
    info.func = CT_RaidTracker_RarityDropDown_OnClick;
    UIDropDownMenu_AddButton(info);

    info = {};
    info.text = "|c000070ddRare|r";
    info.func = CT_RaidTracker_RarityDropDown_OnClick;
    UIDropDownMenu_AddButton(info);

    info = {};
    info.text = "|c00a335eeEpic|r";
    info.func = CT_RaidTracker_RarityDropDown_OnClick;
    UIDropDownMenu_AddButton(info);

    info = {};
    info.text = "|c00ff8000Legendary|r";
    info.func = CT_RaidTracker_RarityDropDown_OnClick;
    UIDropDownMenu_AddButton(info);

    info = {};
    info.text = "|c00e6cc80Artifact|r";
    info.func = CT_RaidTracker_RarityDropDown_OnClick;
    UIDropDownMenu_AddButton(info);
end


function CT_RaidTracker_RarityDropDown_OnClick(self)
    UIDropDownMenu_SetSelectedID(CT_RaidTrackerRarityDropDown, self:GetID());
    if ( CT_RaidTrackerFrame.type == "items" ) then
        CT_RaidTracker_SortOptions["itemfilter"] = self:GetID();
    else
        CT_RaidTracker_SortOptions["playeritemfilter"] = self:GetID();
    end
    CT_RaidTracker_UpdateView();
end

function CT_RaidTracker_SelectItem(name)
    CT_RaidTracker_GetPage();
    CT_RaidTrackerFrame.type = "itemhistory";
    CT_RaidTrackerFrame.itemname = name;
    CT_RaidTrackerFrame.selected = nil;
    CT_RaidTracker_Update();
    CT_RaidTracker_UpdateView();
end

function CT_RaidTracker_GetPage()
    if ( CT_RaidTrackerFrame.type or CT_RaidTrackerFrame.itemname or CT_RaidTrackerFrame.selected or CT_RaidTrackerFrame.player ) then

        tinsert(CT_RaidTracker_LastPage,
            {
                ["type"] = CT_RaidTrackerFrame.type,
                ["itemname"] = CT_RaidTrackerFrame.itemname,
                ["selected"] = CT_RaidTrackerFrame.selected,
                ["player"] = CT_RaidTrackerFrame.player
            }
        );
    end

    if ( getn(CT_RaidTracker_LastPage) > 0 ) then
        CT_RaidTrackerFrameBackButton:Enable();
    else
        CT_RaidTrackerFrameBackButton:Disable();
    end
end

function CT_RaidTracker_GoBack()
    local t = table.remove(CT_RaidTracker_LastPage);

    if ( t ) then
        CT_RaidTrackerFrame.type = t["type"];
        CT_RaidTrackerFrame.itemname = t["itemname"];
        CT_RaidTrackerFrame.selected = t["selected"];
        CT_RaidTrackerFrame.player = t["player"];
        CT_RaidTracker_Update();
        CT_RaidTracker_UpdateView();
    end
    if ( getn(CT_RaidTracker_LastPage) > 0 ) then
        CT_RaidTrackerFrameBackButton:Enable();
    else
        CT_RaidTrackerFrameBackButton:Disable();
    end
end

if ( CT_RegisterMod ) then
    CT_RaidTracker_DisplayWindow = function()
        ShowUIPanel(CT_RaidTrackerFrame);
    end
    CT_RegisterMod("Raid Tracker", "Display window", 5, "Interface\\Icons\\INV_Chest_Chain_05", "Displays the Raid Tracker window, which tracks raid loot & attendance.", "switch", "", CT_RaidTracker_DisplayWindow);
else
    --CT_RaidTracker_Print("<CTMod> CT_RaidTracker loaded. Type /rt to show the RaidTracker window.", 1, 1, 0);
end

function CT_RaidTracker_FixZero(num)
    if ( num < 10 ) then
        return "0" .. num;
    else
        return num;
    end
end

function CT_RaidTracker_AdjustTimeStamp(target_time)
    local timestamp;
    if(CT_RaidTracker_Options["TimeSync"] == 1) then
        timestamp = target_time+CT_RaidTracker_TimeOffset+(CT_RaidTracker_Options["Timezone"]*3600);
    else
        timestamp = target_time+(CT_RaidTracker_Options["Timezone"]*3600);
    end
    return timestamp;
end

function CT_RaidTracker_Date()
    local timestamp;
    timestamp = CT_RaidTracker_AdjustTimeStamp(time());
    local t = date("*t", timestamp);
    return CT_RaidTracker_FixZero(t.month) .. "/" .. CT_RaidTracker_FixZero(t.day) .. "/" .. strsub(t.year, 3) .. " " .. CT_RaidTracker_FixZero(t.hour) .. ":" .. CT_RaidTracker_FixZero(t.min) .. ":" .. CT_RaidTracker_FixZero(t.sec);
end

function CT_RaidTrackerUpdateFrame_OnUpdate(this, elapsed)
    if ( this.time ) then
        this.time = this.time + elapsed;
        if ( this.time > 2 ) then
            this.time = nil;
            for k, v in pairs(CT_RaidTracker_Events) do
                CT_RaidTracker_OnEvent(v);
            end
        end
    end
end

function CT_RaidTrackerCreateNewRaid()
    CT_RaidTracker_GetGameTimeOffset();
    local sDate = CT_RaidTracker_Date();
    if(CT_RaidTracker_GetCurrentRaid) then
        for k, v in pairs(CT_RaidTracker_Online) do
            CT_RaidTracker_Debug("ADDING LEAVE", k, sDate);
            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                {
                    ["player"] = GetFixedUpUnitName(k, true),
                    ["time"] = sDate,
                }
            );
        end
        if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["End"]) then
            CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["End"] = sDate;
        end
    end
    CT_RaidTracker_Online = { };
    CT_RaidTracker_Offline = { };
    tinsert(CT_RaidTracker_RaidLog, 1, {
        ["Loot"] = { },
        ["Join"] = { },
        ["Leave"] = { },
        ["PlayerInfos"] = { },
        ["BossKills"] = { },
        ["key"] = sDate,
        ["Realm"] = GetRealmName(),
    });
    CT_RaidTracker_SortRaidTable();
    CT_RaidTracker_GetCurrentRaid = 1;
    if((IsInRaid() == true) and (GetNumGroupMembers() > 0)) then
        for i = 1, GetNumGroupMembers(), 1 do
            local sPlayer = GetFixedUpUnitName("raid" .. i, true);
            if (string.find(sPlayer, "Unknown") == nil) then
            local _, race = UnitRace("raid" .. i);
            local sex = UnitSex("raid" .. i);
            local guild = GetGuildInfo("raid" .. i);
            local name = GetFixedUpUnitName("raid" .. i, true);
            local rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
            
                if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]) then
                    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name] = { };
                end
                if(CT_RaidTracker_Options["SaveExtendedPlayerInfo"] == 1) then
                    if(race) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["race"] = race; end
                    if(fileName) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["class"] = fileName; end
                        if(sex) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["sex"] = sex; end
                    if(level > 0) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["level"] = level; end
                    if(guild) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["guild"] = guild; end
                end
                tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Join"],
                    {
                        ["player"] = sPlayer,
                        ["time"] = sDate
                    }
                );
                if ( not online ) then
                    tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                        {
                            ["player"] = GetFixedUpUnitName("raid" .. i, true),
                            ["time"] = sDate
                        }
                    );
                end
                CT_RaidTracker_Online[name] = online;
            end
        end
    elseif( (GetNumGroupMembers()  > 0) and (CT_RaidTracker_Options["LogGroup"] == true) ) then
        for i = 1, GetNumGroupMembers(), 1 do
            local sPlayer = GetFixedUpUnitName("party" .. i, true);
            local _, race = UnitRace("party" .. i);
            local sex = UnitSex("party" .. i);
            local guild = GetGuildInfo("party" .. i);
            local name = GetFixedUpUnitName("party" .. i, true);
            local rank = UnitPVPRank("party" .. i);
            local level = UnitLevel("party" .. i);
            local _, class = UnitClass("party" .. i);
            local online = UnitIsConnected("party" .. i);
            if (class) then
                local fileName = string.upper(class);
            end;
            if(sPlayer ~= UKNOWNBEING and name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]) then
                    CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name] = { };
                end
                if(CT_RaidTracker_Options["SaveExtendedPlayerInfo"] == 1) then
                    if(race) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["race"] = race; end
                    if(fileName) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["class"] = fileName; end
                        if(sex) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["sex"] = sex; end
                    if(level > 0) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["level"] = level; end
                    if(guild) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["guild"] = guild; end
                end
                tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Join"],
                    {
                        ["player"] = sPlayer,
                        ["time"] = sDate
                    }
                );
                if ( not online ) then
                    tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                        {
                            ["player"] = name,
                            ["time"] = sDate
                        }
                    );
                end
                CT_RaidTracker_Online[name] = online;
            end
        end

        --Player isnt in party so add individual

        local sPlayer = GetFixedUpUnitName("player", true);
        local _, race = UnitRace("player");
        local sex = UnitSex("player");
        local guild = GetGuildInfo("player");
        local name = GetFixedUpUnitName("player", true);
        local rank = UnitPVPRank("player");
        local level = UnitLevel("player");
        local _, class = UnitClass("player");
        local online = UnitIsConnected("player");
        local fileName = string.upper(class);
        if(sPlayer ~= UKNOWNBEING and name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
            if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]) then
                CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name] = { };
            end
            if(CT_RaidTracker_Options["SaveExtendedPlayerInfo"] == 1) then
                if(race) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["race"] = race; end
                if(fileName) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["class"] = fileName; end
                    if(sex) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["sex"] = sex; end
                if(level > 0) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["level"] = level; end
                if(guild) then CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["PlayerInfos"][name]["guild"] = guild; end
            end
            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Join"],
                {
                    ["player"] = sPlayer,
                    ["time"] = sDate
                }
            );
            if ( not online ) then
                tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                    {
                        ["player"] = name,
                        ["time"] = sDate
                    }
                );
            end
            CT_RaidTracker_Online[name] = online;
        end
    end
    if(CT_RaidTracker_Options["AutoZone"] == true) then
        CT_RaidTracker_DoZoneCheck()
    end
    -- clear the waitlist
    CT_RaidTracker_WaitList = { };
    CT_RaidTracker_Debug("Joined new raid at " .. sDate);
    CT_RaidTracker_Update();
    CT_RaidTracker_UpdateView();
end

function CT_RaidTrackerEndRaid()
    local raidendtime = CT_RaidTracker_Date();
    if(CT_RaidTracker_GetCurrentRaid) then
        CT_RaidTracker_Print("Ending current raid at "..raidendtime, 1, 1, 0);
        for k, v in pairs(CT_RaidTracker_Online) do
            CT_RaidTracker_Debug("ADDING LEAVE", k, raidendtime);
            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                {
                    ["player"] = k,
                    ["time"] = raidendtime,
                }
            );
        end
        if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["End"]) then
            CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["End"] = raidendtime;
        end
        CT_RaidTracker_GetCurrentRaid = nil;
        -- clear the waitlist
        CT_RaidTracker_WaitList = { };
        CT_RaidTracker_Debug("Left raid.","CT_RaidTrackerEndRaid");
        CT_RaidTracker_Online = { };
        CT_RaidTracker_UpdateView();
        CT_RaidTracker_Update();
    end
end

function CT_RaidTrackerSnapshotRaid()
    local sDate = CT_RaidTracker_Date();
    local newraid = {};
    if(CT_RaidTracker_GetCurrentRaid) then
        CT_RaidTracker_Print("Snapshotting current raid", 1, 1, 0);
        tinsert(CT_RaidTracker_RaidLog, 2, {
            ["Loot"] = { },
            ["Join"] = { },
            ["Leave"] = { },
            ["PlayerInfos"] = { },
            ["BossKills"] = { },
            ["key"] = sDate,
            ["End"] = sDate,
            });
        if(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Zone"]) then
            CT_RaidTracker_RaidLog[2]["Zone"] = CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Zone"];
        end

        for k, v in pairs(CT_RaidTracker_Online) do
            CT_RaidTracker_RaidLog[2]["PlayerInfos"][k] = {};
            tinsert(CT_RaidTracker_RaidLog[2]["Join"], {
                ["player"] = k,
                ["time"] = sDate
                });
            tinsert(CT_RaidTracker_RaidLog[2]["Leave"], {
                ["player"] = k,
                ["time"] = sDate
                });
        end
        CT_RaidTracker_UpdateView();
        CT_RaidTracker_Update();
    end
end

function CT_RaidTrackerAddGuild()
    if(CT_RaidTracker_GetCurrentRaid) then
        SetGuildRosterShowOffline(false);
     for i = 1, GetNumGuildMembers() do
        local name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(i);
       -- CT_RaidTracker_Debug("GUILD", name, online);
        if( online ~= CT_RaidTracker_Online[name] ) then
          if( online ) then
            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Join"],
            {
               ["player"] = name,
               ["time"] = CT_RaidTracker_Date()
            }
            );
            CT_RaidTracker_Online[name] = online;
            CT_RaidTracker_Debug("GUILD-ONLINE", name);
          elseif ( not online and CT_RaidTracker_Online[name]) then
                        tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Leave"],
                            {
                                ["player"] = name,
                                ["time"] = CT_RaidTracker_Date()
                            }
                        );
                        CT_RaidTracker_Online[name] = online;
                        CT_RaidTracker_Debug("GUILD-OFFLINE", name);
             end
           end
     end
  end
    CT_RaidTracker_Update();
    CT_RaidTracker_UpdateView();
end

PlayerGroupsIndexes = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};

function CT_RaidTracker_GetPlayerIndexes(raidid)
    local PlayerIndexes = { };
    local PlayerFound = nil;
    if(CT_RaidTracker_RaidLog[raidid]) then
        for k, v in pairs(CT_RaidTracker_RaidLog[raidid]["Join"]) do
            if ( v["player"] ) then
                PlayerFound = false;
                for k2, v2 in pairs(PlayerIndexes) do
                    if(v2 == v["player"]) then
                        PlayerFound = true;
                        break;
                    end
                end
                if(not PlayerFound) then
                    tinsert(PlayerIndexes, v["player"]);
                end
            end
        end
    end
    table.sort(PlayerIndexes);
    return PlayerIndexes;
end

function CT_RaidTracker_GetPlayerGroups(raidid)
    local PlayerIndexes = CT_RaidTracker_GetPlayerIndexes(raidid);
    local PlayerGroups = { };
    local PlayerGroup;
    for k, v in pairs(PlayerIndexes) do
        PlayerGroup = CT_RaidTracker_PlayerGroupIndex(strupper(strsub(CT_RaidTracker_StripSpecialChars(v), 1, 1)));
        if(not PlayerGroups[PlayerGroup]) then
            PlayerGroups[PlayerGroup] = { };
        end
        tinsert(PlayerGroups[PlayerGroup], v);
    end
    return PlayerGroups;
end

function CT_RaidTracker_PlayerGroupIndex(letter)
    letter = strupper(letter);
    for k, v in pairs(PlayerGroupsIndexes) do
        if(v == letter) then
            return k;
        end
    end
    return;
end

function CT_RaidTracker_StripSpecialChars(sstring)

    sstring = string.gsub(sstring, "\194\161", "!");
    sstring = string.gsub(sstring, "\194\170", "a");
    sstring = string.gsub(sstring, "\194\186", "o");
    sstring = string.gsub(sstring, "\194\191", "?");
    sstring = string.gsub(sstring, "\195\128", "A");
    sstring = string.gsub(sstring, "\195\129", "A");
    sstring = string.gsub(sstring, "\195\130", "A");
    sstring = string.gsub(sstring, "\195\131", "A");
    sstring = string.gsub(sstring, "\195\133", "A");
    sstring = string.gsub(sstring, "\195\135", "C");
    sstring = string.gsub(sstring, "\195\136", "E");
    sstring = string.gsub(sstring, "\195\137", "E");
    sstring = string.gsub(sstring, "\195\138", "E");
    sstring = string.gsub(sstring, "\195\139", "E");
    sstring = string.gsub(sstring, "\195\140", "I");
    sstring = string.gsub(sstring, "\195\141", "I");
    sstring = string.gsub(sstring, "\195\142", "I");
    sstring = string.gsub(sstring, "\195\143", "I");
    sstring = string.gsub(sstring, "\195\144", "D");
    sstring = string.gsub(sstring, "\195\145", "N");
    sstring = string.gsub(sstring, "\195\146", "O");
    sstring = string.gsub(sstring, "\195\147", "O");
    sstring = string.gsub(sstring, "\195\148", "O");
    sstring = string.gsub(sstring, "\195\149", "O");
    sstring = string.gsub(sstring, "\195\152", "O");
    sstring = string.gsub(sstring, "\195\153", "U");
    sstring = string.gsub(sstring, "\195\154", "U");
    sstring = string.gsub(sstring, "\195\155", "U");
    sstring = string.gsub(sstring, "\195\157", "Y");
    sstring = string.gsub(sstring, "\195\160", "a");
    sstring = string.gsub(sstring, "\195\161", "a");
    sstring = string.gsub(sstring, "\195\162", "a");
    sstring = string.gsub(sstring, "\195\163", "a");
    sstring = string.gsub(sstring, "\195\165", "a");
    sstring = string.gsub(sstring, "\195\167", "c");
    sstring = string.gsub(sstring, "\195\168", "e");
    sstring = string.gsub(sstring, "\195\169", "e");
    sstring = string.gsub(sstring, "\195\170", "e");
    sstring = string.gsub(sstring, "\195\171", "e");
    sstring = string.gsub(sstring, "\195\172", "i");
    sstring = string.gsub(sstring, "\195\173", "i");
    sstring = string.gsub(sstring, "\195\174", "i");
    sstring = string.gsub(sstring, "\195\175", "i");
    sstring = string.gsub(sstring, "\195\176", "d");
    sstring = string.gsub(sstring, "\195\177", "n");
    sstring = string.gsub(sstring, "\195\178", "o");
    sstring = string.gsub(sstring, "\195\179", "o");
    sstring = string.gsub(sstring, "\195\180", "o");
    sstring = string.gsub(sstring, "\195\181", "o");
    sstring = string.gsub(sstring, "\195\184", "o");
    sstring = string.gsub(sstring, "\195\185", "u");
    sstring = string.gsub(sstring, "\195\186", "u");
    sstring = string.gsub(sstring, "\195\187", "u");
    sstring = string.gsub(sstring, "\195\189", "y");
    sstring = string.gsub(sstring, "\195\191", "y");
    sstring = string.gsub(sstring, "\195\132", "Ae");
    sstring = string.gsub(sstring, "\195\134", "AE");
    sstring = string.gsub(sstring, "\195\150", "Oe");
    sstring = string.gsub(sstring, "\195\156", "Ue");
    sstring = string.gsub(sstring, "\195\158", "TH");
    sstring = string.gsub(sstring, "\195\159", "ss");
    sstring = string.gsub(sstring, "\195\164", "ae");
    sstring = string.gsub(sstring, "\195\166", "ae");
    sstring = string.gsub(sstring, "\195\182", "oe");
    sstring = string.gsub(sstring, "\195\188", "ue");
    sstring = string.gsub(sstring, "\195\190", "th");
    return sstring;
end

function CT_RaidTrackerShowDkpLink(link)
    URLFrameEditBox:SetText(link);
    URLFrameEditBox:HighlightText();
    URLFrame:Show();
end

function CT_RaidTrackerFixXMLEntities(value)
    return gsub(value, "&", "&amp;");
end

function CT_RaidTrackerGenerateGLDkpXML(id)
    local race, class, level, sex;

    if (not CT_RaidTracker_RaidLog[id]["End"]) then
        CT_RaidTracker_Print("You must end the raid before exporting the data.");
        return;
    end;

    local link = "<RaidInfo>";

    link = link.."<version>"..GetAddOnMetadata("GuildLaunchCT_RaidTrackerClassic", "X-GLExportVersion").."</version>";
    link = link.."<mod_version>"..GetAddOnMetadata("GuildLaunchCT_RaidTrackerClassic", "Version").."</mod_version>";
    --if(CT_RaidTracker_Options["ExportFormat"] == 0) then
    --    local link = link.."<Version>1.4</Version>";
    --end

    --if(CT_RaidTracker_Options["ExportFormat"] == 0) then
    --    link = link.."<key>"..CT_RaidTracker_RaidLog[id]["key"].."</key>";
    --end
    if (CT_RaidTracker_RaidLog[id]["Realm"]) then
        link = link.."<realm>"..CT_RaidTracker_RaidLog[id]["Realm"].."</realm>";
    end

    -- timezone
    link = link.."<timezone>"..CT_RaidTracker_Options["Timezone"].."</timezone>";

    --if(CT_RaidTracker_Options["ExportFormat"] == 3) then
    --CT_RaidTracker_AdjustTimeStamp
        link = link.."<start>"..CT_RaidTracker_GetTime(CT_RaidTracker_RaidLog[id]["key"]).."</start>";
    --else
    --    link = link.."<start>"..CT_RaidTracker_RaidLog[id]["key"].."</start>";
    --end

    if(CT_RaidTracker_RaidLog[id]["End"]) then
        --if(CT_RaidTracker_Options["ExportFormat"] == 3) then
            link = link.."<end>"..CT_RaidTracker_GetTime(CT_RaidTracker_RaidLog[id]["End"]).."</end>";
        --else
        --    link = link.."<end>"..CT_RaidTracker_RaidLog[id]["End"].."</end>";
        --end
    end
    if(CT_RaidTracker_RaidLog[id]["zone"]) then
        link = link.."<zone>"..CT_RaidTracker_RaidLog[id]["zone"].."</zone>";
    end
    if(CT_RaidTracker_RaidLog[id]["PlayerInfos"]) then
        link = link.."<PlayerInfos>";
        local playerinfosindex = 1;
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["PlayerInfos"]) do
            link = link.."<key"..playerinfosindex..">";
            link = link.."<name>"..CT_RaidTrackerFixXMLEntities(key).."</name>";
            for key2, val2 in pairs(CT_RaidTracker_RaidLog[id]["PlayerInfos"][key]) do
                if(key2 == "note") then
                    link = link.."<"..key2.."><![CDATA["..val2.."]]></"..key2..">";

                else
                    link = link.."<"..key2..">"..val2.."</"..key2..">";
                end
            end
            link = link.."</key"..playerinfosindex..">";
            playerinfosindex = playerinfosindex + 1;
        end
        link = link.."</PlayerInfos>";
    end
    if(CT_RaidTracker_RaidLog[id]["BossKills"]) then
        local bosskillsindex = 1;
        link = link.."<BossKills>";
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["BossKills"]) do
            link = link.."<key"..bosskillsindex..">";
            link = link.."<name>"..val["boss"].."</name>";
            if (val["event_source"] ~= nil) then
                link = link.."<event_source>"..val["event_source"].."</event_source>";
            else
                link = link.."<event_source></event_source>";
            end
            if (val["event_note"] ~= nil) then
                link = link.."<event_note><![CDATA["..val["event_note"].."]]></event_note>";
            else
                link = link.."<event_note></event_note>";
            end
            link = link.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
            if (val["value"] ~= nil) then
                link = link.."<value>"..val["value"].."</value>";
            else
                link = link.."<value></value>";
            end
            if( CT_RaidTracker_RaidLog[id]["BossKills"][key]["attendees"]) then
                link = link.."<attendees>";
                for key2, val2 in pairs(CT_RaidTracker_RaidLog[id]["BossKills"][key]["attendees"]) do
                    link = link.."<key"..key2..">";
                    link = link.."<name>"..CT_RaidTrackerFixXMLEntities(val2).."</name>";
                    link = link.."</key"..key2..">";
                end
                link = link.."</attendees>";
            end
            link = link.."</key"..bosskillsindex..">";
            bosskillsindex = bosskillsindex + 1;
        end
        link = link.."</BossKills>";
    end
    -- new exports
    if(CT_RaidTracker_RaidLog[id]["wipes"]) then
        local wipeindex = 1;
        link = link.."<Wipes>";
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["wipes"]) do
            link = link.."<key"..wipeindex..">";
            link = link.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
            if(CT_RaidTracker_RaidLog[id]["wipes"][key]["attendees"]) then
                link = link.."<attendees>";
                for key2, val2 in pairs(CT_RaidTracker_RaidLog[id]["wipes"][key]["attendees"]) do
                    link = link.."<key"..key2..">";
                    link = link.."<name>"..CT_RaidTrackerFixXMLEntities(val2).."</name>";
                    link = link.."</key"..key2..">";
                end
                link = link.."</attendees>";
            end
            link = link.."</key"..wipeindex..">";
            wipeindex = wipeindex + 1;
        end
        link = link.."</Wipes>";
    end
    if(CT_RaidTracker_RaidLog[id]["attendances"]) then
        local attendanceindex = 1;
        link = link.."<Attendances>";
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["attendances"]) do
            link = link.."<key"..attendanceindex..">";
            link = link.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
            if(CT_RaidTracker_RaidLog[id]["attendances"][key]["attendees"]) then
                link = link.."<attendees>";
                for key2, val2 in pairs(CT_RaidTracker_RaidLog[id]["attendances"][key]["attendees"]) do
                    link = link.."<key"..key2..">";
                    link = link.."<name>"..CT_RaidTrackerFixXMLEntities(val2).."</name>";
                    link = link.."</key"..key2..">";
                end
                link = link.."</attendees>";
            end
            link = link.."</key"..attendanceindex..">";
            attendanceindex = attendanceindex + 1;
        end
        link = link.."</Attendances>";
    end
    if(CT_RaidTracker_RaidLog[id]["nextboss"]) then
        link = link.."<NextBoss>"..CT_RaidTracker_RaidLog[id]["nextboss"].."</NextBoss>";
    end
    --
    --if(CT_RaidTracker_Options["ExportFormat"] == 0) then
    --        local sNote = "<note><![CDATA[";
    --        if(CT_RaidTracker_RaidLog[id]["note"]) then sNote = sNote..CT_RaidTracker_RaidLog[id]["note"]; end
    --        if(CT_RaidTracker_RaidLog[id]["zone"]) then sNote = sNote.." - Zone: "..CT_RaidTracker_RaidLog[id]["zone"]; end
    --        sNote = sNote.."]]></note>";
    --        link = link..sNote;
    --    else
            if(CT_RaidTracker_RaidLog[id]["note"]) then link = link.."<note><![CDATA["..CT_RaidTracker_RaidLog[id]["note"].."]]></note>"; end
    --    end
    link = link.."<Join>";
    for key, val in pairs(CT_RaidTracker_RaidLog[id]["Join"]) do
        link = link.."<key"..key..">";
        link = link.."<player>"..CT_RaidTrackerFixXMLEntities(val["player"]).."</player>";
        --if(CT_RaidTracker_Options["ExportFormat"] == 0) then
        --    if(val["race"]) then
        --        race = val["race"];
        --    elseif(CT_RaidTracker_RaidLog[id]["PlayerInfos"] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["race"]) then
        --        race = CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["race"];
        --    else
        --        race = nil;
        --    end
        --    if(val["class"]) then
        --        class = val["class"];
        --    elseif(CT_RaidTracker_RaidLog[id]["PlayerInfos"] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["class"]) then
        --        class = CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["class"];
        --    else
        --        class = nil;
        --    end
        --    if(val["sex"]) then
        --        sex = val["sex"];
        --    elseif(CT_RaidTracker_RaidLog[id]["PlayerInfos"] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["sex"]) then
        --        sex = CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["sex"];
        --    else
        --        sex = nil;
        --    end
        --    if(val["level"]) then
        --        level = val["level"];
        --    elseif(CT_RaidTracker_RaidLog[id]["PlayerInfos"] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["level"]) then
        --        level = CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["level"];
        --    else
        --        level = nil;
        --    end
        --    if(race) then link = link.."<race>"..race.."</race>"; end
        --    if(class) then link = link.."<class>"..class.."</class>"; end
        --    if(sex) then link = link.."<sex>"..sex.."</sex>"; end
        --    if(level) then link = link.."<level>"..level.."</level>"; end
        --end
        --if(CT_RaidTracker_Options["ExportFormat"] == 0 and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["note"]) then link = link.."<note>"..CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["note"].."</note>"; end
        --if(CT_RaidTracker_Options["ExportFormat"] == 3) then
            link = link.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
        --else
        --    link = link.."<time>"..val["time"].."</time>";
        --end
        link = link.."</key"..key..">";
    end
    link = link.."</Join>";
    link = link.."<Leave>";
    for key, val in pairs(CT_RaidTracker_RaidLog[id]["Leave"]) do
        link = link.."<key"..key..">";
        link = link.."<player>"..CT_RaidTrackerFixXMLEntities(val["player"]).."</player>";
        --if(CT_RaidTracker_Options["ExportFormat"] == 3) then
            link = link.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
        --else
        --    link = link.."<time>"..val["time"].."</time>";
        --end
        link = link.."</key"..key..">";
    end
    link = link.."</Leave>";
    link = link.."<Loot>";
    for key, val in pairs(CT_RaidTracker_RaidLog[id]["Loot"]) do
        link = link.."<key"..key..">";
        link = link.."<ItemName>"..CT_RaidTrackerFixXMLEntities(val["item"]["name"]).."</ItemName>";
        if (val["event_source"] ~= nil) then
            link = link.."<event_source>"..val["event_source"].."</event_source>";
        end
        link = link.."<ItemID>"..CT_RaidTrackerFixXMLEntities(val["item"]["id"]).."</ItemID>";
        if(val["item"]["icon"]) then link = link.."<Icon>"..CT_RaidTrackerFixXMLEntities(val["item"]["icon"]).."</Icon>"; end
        if(val["item"]["class"]) then link = link.."<Class>"..CT_RaidTrackerFixXMLEntities(val["item"]["class"]).."</Class>"; end
        if(val["item"]["subclass"]) then link = link.."<SubClass>"..CT_RaidTrackerFixXMLEntities(val["item"]["subclass"]).."</SubClass>"; end
        link = link.."<Color>"..val["item"]["c"].."</Color>";
        link = link.."<Count>"..val["item"]["count"].."</Count>";
        link = link.."<Player>"..val["player"].."</Player>";
        if(val["costs"]) then
            link = link.."<Costs>"..val["costs"].."</Costs>";
        end
        --if(CT_RaidTracker_Options["ExportFormat"] == 3) then
            link = link.."<Time>"..CT_RaidTracker_GetTime(val["time"]).."</Time>";
        --else
        --    link = link.."<Time>"..val["time"].."</Time>";
        --end
        if(val["zone"]) then link = link.."<Zone>"..val["zone"].."</Zone>"; end
        if(val["boss"]) then link = link.."<Boss>"..val["boss"].."</Boss>"; end
        --if(CT_RaidTracker_Options["ExportFormat"] == 0) then
        --    local sNote = "<Note><![CDATA[";
        --    if(val["note"]) then sNote = sNote..val["note"]; end
        --    if(val["zone"]) then sNote = sNote.." - Zone: "..val["zone"]; end
        --    if(val["boss"]) then sNote = sNote.." - Boss: "..val["boss"]; end
        --    if(val["costs"]) then sNote = sNote.." - "..val["costs"].." DKP"; end
        --    sNote = sNote.."]]></Note>";
        --    link = link..sNote;
        --else
            if(val["note"]) then link = link.."<Note><![CDATA["..val["note"].."]]></Note>"; end
        --end
        link = link.."</key"..key..">";
    end
    link = link.."</Loot>";
    link = link.."</RaidInfo>";
    CT_RaidTrackerShowDkpLink(link);
end

function CT_RaidTrackerGenerateMLdkpXML(id)
    local race, class, level, sex;

    if (not CT_RaidTracker_RaidLog[id]["End"]) then
        CT_RaidTracker_Print("You have to end the raid before you exporting it");
        return;
    end;

    local xml ='<?xml version="1.0"?>';
    xml = xml..'<!DOCTYPE ML_Raidtracker PUBLIC "-//MLdkp//DTD ML_Raidtracker V 1.5//EN" "http://www.mldkp.net/dtds/1.0/ML_Raidtracker.dtd">';

    xml = xml.."<raidinfo>";
    xml = xml.."<version>1.5</version>";

    xml = xml.."<start>"..CT_RaidTracker_GetTime(CT_RaidTracker_RaidLog[id]["key"]).."</start>";
    xml = xml.."<end>"..CT_RaidTracker_GetTime(CT_RaidTracker_RaidLog[id]["End"]).."</end>";

    if(CT_RaidTracker_RaidLog[id]["Realm"]) then
        xml = xml.."<realm>"..CT_RaidTracker_RaidLog[id]["Realm"].."</realm>";
    end

    if(CT_RaidTracker_RaidLog[id]["zone"]) then
        xml = xml.."<zone>"..CT_RaidTracker_RaidLog[id]["zone"].."</zone>";
    end
    if(CT_RaidTracker_RaidLog[id]["instanceid"]) then
        xml = xml.."<instanceid>"..CT_RaidTracker_RaidLog[id]["instanceid"].."</instanceid>";
    end
    xml = xml.."<exporter>"..GetFixedUpUnitName("Player", true).."</exporter>";

    if(CT_RaidTracker_RaidLog[id]["PlayerInfos"]) then
        xml = xml.."<playerinfos>";
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["PlayerInfos"]) do
            xml = xml.."<player>";
            xml = xml.."<name>"..key.."</name>";
            for key2, val2 in pairs(CT_RaidTracker_RaidLog[id]["PlayerInfos"][key]) do
                if(key2 == "note") then
                    xml = xml.."<"..key2.."><![CDATA["..val2.."]]></"..key2..">";
                elseif (key2 == "class") then
                    xml = xml.."<"..key2..">"..CT_RaidTracker_ClassTable[val2].."</"..key2..">";
                elseif (key2 == "race") then
                    xml = xml.."<"..key2..">"..CT_RaidTracker_RaceTable[val2].."</"..key2..">";
                elseif (key2 == "level") then
                    if (CT_RaidTracker_Options["MaxLevel"] ~= val2) then
                        xml = xml.."<"..key2..">"..val2.."</"..key2..">";
                    end;
                else
                    xml = xml.."<"..key2..">"..val2.."</"..key2..">";
                end
            end
            xml = xml.."</player>";
        end
        xml = xml.."</playerinfos>";
    end
    if(CT_RaidTracker_RaidLog[id]["BossKills"]) then
        local bosskillsindex = 1;
        xml = xml.."<bosskills>";
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["BossKills"]) do
            xml = xml.."<bosskill>";
            xml = xml.."<name>"..val["boss"].."</name>";
            xml = xml.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
            xml = xml.."</bosskill>";
        end
        xml = xml.."</bosskills>";
    end
    if(CT_RaidTracker_RaidLog[id]["wipes"]) then
        xml = xml.."<wipes>";
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["wipes"]) do
            xml = xml.."<wipe><time>"..val.."</time></wipe>";
        end
        xml = xml.."</wipes>";
    end
    if(CT_RaidTracker_RaidLog[id]["attendances"]) then
        xml = xml.."<attendances>";
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["attendances"]) do
            xml = xml.."<attendance><time>"..val.."</time></attendance>";
        end
        xml = xml.."</attendances>";
    end
    if(CT_RaidTracker_RaidLog[id]["nextboss"]) then
        xml = xml.."<nextboss>"..CT_RaidTracker_RaidLog[id]["nextboss"].."</nextboss>";
    end

    if(CT_RaidTracker_RaidLog[id]["note"]) then
        xml = xml.."<note><![CDATA["..CT_RaidTracker_RaidLog[id]["note"].."]]></note>";
    end

    xml = xml.."<joins>";
    for key, val in pairs(CT_RaidTracker_RaidLog[id]["Join"]) do
        xml = xml.."<join>";
        xml = xml.."<player>"..val["player"].."</player>";
        xml = xml.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
        xml = xml.."</join>";
    end
    xml = xml.."</joins>";
    xml = xml.."<leaves>";
    for key, val in pairs(CT_RaidTracker_RaidLog[id]["Leave"]) do
        xml = xml.."<leave>";
        xml = xml.."<player>"..val["player"].."</player>";
        xml = xml.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
        xml = xml.."</leave>";
    end
    xml = xml.."</leaves>";
    xml = xml.."<loots>";
    for key, val in pairs(CT_RaidTracker_RaidLog[id]["Loot"]) do
        xml = xml.."<loot>";
        xml = xml.."<itemname>"..val["item"]["name"].."</itemname>";
        xml = xml.."<itemid>"..val["item"]["id"].."</itemid>";
        xml = xml.."<count>"..val["item"]["count"].."</count>";
        xml = xml.."<player>"..val["player"].."</player>";
        if(val["costs"]) then
            xml = xml.."<costs>"..val["costs"].."</costs>";
        end
        xml = xml.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
        if(val["zone"]) then
            xml = xml.."<zone>"..val["zone"].."</zone>";
        end
        if(val["boss"]) then
            xml = xml.."<boss>"..val["boss"].."</boss>";
        end
        if(val["note"]) then
            xml = xml.."<note><![CDATA["..val["note"].."]]></note>";
        end
        xml = xml.."</loot>";
    end
    xml = xml.."</loots>";
    xml = xml.."</raidinfo>";
    CT_RaidTrackerShowDkpLink(xml);
end

function CT_RaidTrackerGenerateDkpLink(id)
    local race, class, level, sex;
    if (CT_RaidTracker_Options["ExportFormat"]==2) then
        CT_RaidTrackerGenerateMLdkpXML(id);
        return;
    end;

    -- GENERATE GUILD LAUNCH XML VERSION

    if (CT_RaidTracker_Options["ExportFormat"]==3) then
        CT_RaidTrackerGenerateGLDkpXML(id);
        return;
    end;
    local link = "<RaidInfo>";
    if(CT_RaidTracker_Options["ExportFormat"] == 0) then
        local link = link.."<Version>1.4</Version>";
    end

    if(CT_RaidTracker_Options["ExportFormat"] == 0) then
        link = link.."<key>"..CT_RaidTracker_RaidLog[id]["key"].."</key>";
    end
    if (CT_RaidTracker_RaidLog[id]["Realm"]) then
        link = link.."<realm>"..CT_RaidTracker_RaidLog[id]["Realm"].."</realm>";
    end

    if(CT_RaidTracker_Options["ExportFormat"] == 1) then
        link = link.."<start>"..CT_RaidTracker_GetTime(CT_RaidTracker_RaidLog[id]["key"]).."</start>";
    else
        link = link.."<start>"..CT_RaidTracker_RaidLog[id]["key"].."</start>";
    end

    if(CT_RaidTracker_RaidLog[id]["End"]) then
        if(CT_RaidTracker_Options["ExportFormat"] == 1) then
            link = link.."<end>"..CT_RaidTracker_GetTime(CT_RaidTracker_RaidLog[id]["End"]).."</end>";
        else
            link = link.."<end>"..CT_RaidTracker_RaidLog[id]["End"].."</end>";
        end
    end
    if(CT_RaidTracker_RaidLog[id]["zone"]) then
        link = link.."<zone>"..CT_RaidTracker_RaidLog[id]["zone"].."</zone>";
    end
    if(CT_RaidTracker_RaidLog[id]["PlayerInfos"]) then
        link = link.."<PlayerInfos>";
        local playerinfosindex = 1;
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["PlayerInfos"]) do
            link = link.."<key"..playerinfosindex..">";
            link = link.."<name>"..key.."</name>";
            for key2, val2 in pairs(CT_RaidTracker_RaidLog[id]["PlayerInfos"][key]) do
                if(key2 == "note") then
                    link = link.."<"..key2.."><![CDATA["..val2.."]]></"..key2..">";

                else
                    link = link.."<"..key2..">"..val2.."</"..key2..">";
                end
            end
            link = link.."</key"..playerinfosindex..">";
            playerinfosindex = playerinfosindex + 1;
        end
        link = link.."</PlayerInfos>";
    end
    if(CT_RaidTracker_RaidLog[id]["BossKills"]) then
        local bosskillsindex = 1;
        link = link.."<BossKills>";
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["BossKills"]) do
            link = link.."<key"..bosskillsindex..">";
            link = link.."<name>"..val["boss"].."</name>";
            if(CT_RaidTracker_Options["ExportFormat"] == 1) then
                link = link.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
            else
                link = link.."<time>"..val["time"].."</time>";
                if( CT_RaidTracker_RaidLog[id]["BossKills"][key]["attendees"]) then
                    link = link.."<attendees>";
                    for key2, val2 in pairs(CT_RaidTracker_RaidLog[id]["BossKills"][key]["attendees"]) do
                        link = link.."<key"..key2..">";
                        link = link.."<name>"..val2.."</name>";
                        link = link.."</key"..key2..">";
                    end
                    link = link.."</attendees>";
                end
            end
            link = link.."</key"..bosskillsindex..">";
            bosskillsindex = bosskillsindex + 1;
        end
        link = link.."</BossKills>";
    end
    -- new exports
    if(CT_RaidTracker_RaidLog[id]["wipes"]) then
        link = link.."<Wipes>";
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["wipes"]) do
            link = link.."<Wipe>"..val.."</Wipe>";
        end
        link = link.."</Wipes>";
    end
    if(CT_RaidTracker_RaidLog[id]["attendances"]) then
        link = link.."<Attendances>";
        for key, val in pairs(CT_RaidTracker_RaidLog[id]["attendances"]) do
            link = link.."<Attendance>"..val.."</Attendance>";
        end
        link = link.."</Attendances>";
    end
    if(CT_RaidTracker_RaidLog[id]["nextboss"]) then
        link = link.."<NextBoss>"..CT_RaidTracker_RaidLog[id]["nextboss"].."</NextBoss>";
    end
    --
    if(CT_RaidTracker_Options["ExportFormat"] == 0) then
            local sNote = "<note><![CDATA[";
            if(CT_RaidTracker_RaidLog[id]["note"]) then sNote = sNote..CT_RaidTracker_RaidLog[id]["note"]; end
            if(CT_RaidTracker_RaidLog[id]["zone"]) then sNote = sNote.." - Zone: "..CT_RaidTracker_RaidLog[id]["zone"]; end
            sNote = sNote.."]]></note>";
            link = link..sNote;
        else
            if(CT_RaidTracker_RaidLog[id]["note"]) then link = link.."<note><![CDATA["..CT_RaidTracker_RaidLog[id]["note"].."]]></note>"; end
        end
    link = link.."<Join>";
    for key, val in pairs(CT_RaidTracker_RaidLog[id]["Join"]) do
        link = link.."<key"..key..">";
        link = link.."<player>"..val["player"].."</player>";
        if(CT_RaidTracker_Options["ExportFormat"] == 0) then
            if(val["race"]) then
                race = val["race"];
            elseif(CT_RaidTracker_RaidLog[id]["PlayerInfos"] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["race"]) then
                race = CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["race"];
            else
                race = nil;
            end
            if(val["class"]) then
                class = val["class"];
            elseif(CT_RaidTracker_RaidLog[id]["PlayerInfos"] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["class"]) then
                class = CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["class"];
            else
                class = nil;
            end
            if(val["sex"]) then
                sex = val["sex"];
            elseif(CT_RaidTracker_RaidLog[id]["PlayerInfos"] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["sex"]) then
                sex = CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["sex"];
            else
                sex = nil;
            end
            if(val["level"]) then
                level = val["level"];
            elseif(CT_RaidTracker_RaidLog[id]["PlayerInfos"] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["level"]) then
                level = CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["level"];
            else
                level = nil;
            end
            if(race) then link = link.."<race>"..race.."</race>"; end
            if(class) then link = link.."<class>"..class.."</class>"; end
            if(sex) then link = link.."<sex>"..sex.."</sex>"; end
            if(level) then link = link.."<level>"..level.."</level>"; end
        end
        if(CT_RaidTracker_Options["ExportFormat"] == 0 and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]] and CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["note"]) then link = link.."<note>"..CT_RaidTracker_RaidLog[id]["PlayerInfos"][val["player"]]["note"].."</note>"; end
        if(CT_RaidTracker_Options["ExportFormat"] == 1) then
            link = link.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
        else
            link = link.."<time>"..val["time"].."</time>";
        end
        link = link.."</key"..key..">";
    end
    link = link.."</Join>";
    link = link.."<Leave>";
    for key, val in pairs(CT_RaidTracker_RaidLog[id]["Leave"]) do
        link = link.."<key"..key..">";
        link = link.."<player>"..val["player"].."</player>";
        if(CT_RaidTracker_Options["ExportFormat"] == 1) then
            link = link.."<time>"..CT_RaidTracker_GetTime(val["time"]).."</time>";
        else
            link = link.."<time>"..val["time"].."</time>";
        end
        link = link.."</key"..key..">";
    end
    link = link.."</Leave>";
    link = link.."<Loot>";
    for key, val in pairs(CT_RaidTracker_RaidLog[id]["Loot"]) do
        link = link.."<key"..key..">";
        link = link.."<ItemName>"..val["item"]["name"].."</ItemName>";
        link = link.."<ItemID>"..val["item"]["id"].."</ItemID>";
        if(val["item"]["icon"]) then link = link.."<Icon>"..val["item"]["icon"].."</Icon>"; end
        if(val["item"]["class"]) then link = link.."<Class>"..val["item"]["class"].."</Class>"; end
        if(val["item"]["subclass"]) then link = link.."<SubClass>"..val["item"]["subclass"].."</SubClass>"; end
        link = link.."<Color>"..val["item"]["c"].."</Color>";
        link = link.."<Count>"..val["item"]["count"].."</Count>";
        link = link.."<Player>"..val["player"].."</Player>";
        if(val["costs"]) then
            link = link.."<Costs>"..val["costs"].."</Costs>";
        end
        if(CT_RaidTracker_Options["ExportFormat"] == 1) then
            link = link.."<Time>"..CT_RaidTracker_GetTime(val["time"]).."</Time>";
        else
            link = link.."<Time>"..val["time"].."</Time>";
        end
        if(val["zone"]) then link = link.."<Zone>"..val["zone"].."</Zone>"; end
        if(val["boss"]) then link = link.."<Boss>"..val["boss"].."</Boss>"; end
        if(CT_RaidTracker_Options["ExportFormat"] == 0) then
            local sNote = "<Note><![CDATA[";
            if(val["note"]) then sNote = sNote..val["note"]; end
            if(val["zone"]) then sNote = sNote.." - Zone: "..val["zone"]; end
            if(val["boss"]) then sNote = sNote.." - Boss: "..val["boss"]; end
            if(val["costs"]) then sNote = sNote.." - "..val["costs"].." DKP"; end
            sNote = sNote.."]]></Note>";
            link = link..sNote;
        else
            if(val["note"]) then link = link.."<Note><![CDATA["..val["note"].."]]></Note>"; end
        end
        link = link.."</key"..key..">";
    end
    link = link.."</Loot>";
    link = link.."</RaidInfo>";
    CT_RaidTrackerShowDkpLink(link);
end

-- Editing
function CT_RaidTracker_EditPlayerNote(raidid, playerid)
    CT_RaidTrackerEditNoteFrame.type = "playernote";
    CT_RaidTrackerEditNoteFrame.raidid = raidid;
    CT_RaidTrackerEditNoteFrame.playerid = playerid;
    CT_RaidTrackerEditNoteFrame:Show();
end

function CT_RaidTracker_EditRaidNote(raidid)
    CT_RaidTrackerEditNoteFrame:Hide();
    CT_RaidTrackerEditNoteFrame.type = "raidnote";
    CT_RaidTrackerEditNoteFrame.raidid = raidid;
    CT_RaidTrackerEditNoteFrame:Show();
end

function CT_RaidTracker_EditItemNote(raidid, itemid)
    CT_RaidTrackerEditNoteFrame.type = "itemnote";
    CT_RaidTrackerEditNoteFrame.raidid = raidid;
    CT_RaidTrackerEditNoteFrame.itemid = itemid;
    CT_RaidTrackerEditNoteFrame:Show();
end

function CT_RaidTracker_EditItemCount(raidid, itemid)
    CT_RaidTrackerEditNoteFrame.type = "itemcount";
    CT_RaidTrackerEditNoteFrame.raidid = raidid;
    CT_RaidTrackerEditNoteFrame.itemid = itemid;
    CT_RaidTrackerEditNoteFrame:Show();
end

function CT_RaidTracker_EditCosts(raidid, itemid)
    CT_RaidTracker_EditCostsEx(raidid, itemid, nil);
end

function CT_RaidTracker_EditCostsEx(raidid, itemid, scosts)
    CT_RaidTrackerEditCostFrame.type = "itemcost";
    CT_RaidTrackerEditCostFrame.raidid = raidid;
    CT_RaidTrackerEditCostFrame.itemid = itemid;

    --oberan cost test
    if(scosts ~= nil)then
        CT_RaidTrackerEditCostFrameNoteEB:SetText(scosts);
    end

    CT_RaidTrackerEditCostFrame:Show();
end

function CT_RaidTracker_EditLooter(raidid, itemid)
    CT_RaidTracker_Debug("CT_RaidTracker_EditLooter", raidid, itemid);
    CT_RaidTrackerEditNoteFrame.type = "looter";
    CT_RaidTrackerEditNoteFrame.raidid = raidid;
    CT_RaidTrackerEditNoteFrame.itemid = itemid;
    CT_RaidTrackerEditNoteFrame:Show();
end

function CT_RaidTracker_EditTime(raidid, what)
    -- what: raidend/raidstart
     CT_RaidTrackerEditNoteFrame.type = "time";
     CT_RaidTrackerEditNoteFrame.what = what;
    CT_RaidTrackerEditNoteFrame.raidid = raidid;
    CT_RaidTrackerEditNoteFrame:Show();
end

function CT_RaidTracker_EditItemTime(raidid, itemid)
     CT_RaidTrackerEditNoteFrame.type = "time";
     CT_RaidTrackerEditNoteFrame.what = "item";
    CT_RaidTrackerEditNoteFrame.raidid = raidid;
    CT_RaidTrackerEditNoteFrame.itemid = itemid;
    CT_RaidTrackerEditNoteFrame:Show();
end

function CT_RaidTracker_EditZone(raidid)
    CT_RaidTrackerEditNoteFrame.type = "zone";
    CT_RaidTrackerEditNoteFrame.raidid = raidid;
    CT_RaidTrackerEditNoteFrame:Show();
end



function CT_RaidTracker_EditNote_OnShow(this)
    local text;

    if ( this.itemid ) then
        CT_RaidTrackerEditNoteFrame.itemitemid = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["item"]["id"];
        CT_RaidTrackerEditNoteFrame.itemtime = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["time"];
        CT_RaidTrackerEditNoteFrame.itemplayer = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["player"];
    end

    if ( this.type == "raidnote" ) then
        local raidkey = CT_RaidTracker_RaidLog[this.raidid]["key"];
        getglobal(this:GetName() .. "Title"):SetText("Edit Note");
        getglobal(this:GetName() .. "Editing"):SetText("Editing note for \"|c" .. "0000ff00" .. "" .. raidkey .. "|r\"");
            text = CT_RaidTracker_RaidLog[this.raidid]["note"];

    elseif ( this.type == "itemnote" ) then
        local itemname = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["item"]["name"];
        local itemcolor = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["item"]["c"];
        getglobal(this:GetName() .. "Title"):SetText("Edit Note");
        getglobal(this:GetName() .. "Editing"):SetText("Editing note for \"|c" .. itemcolor .. "" .. itemname .. "|r\"");
            text = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["note"];

    elseif ( this.type == "itemcount" ) then
        local itemname = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["item"]["name"];
        local itemcolor = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["item"]["c"];
        getglobal(this:GetName() .. "Title"):SetText("Edit Count");
        getglobal(this:GetName() .. "Editing"):SetText("Editing count for \"|c" .. itemcolor .. "" .. itemname .. "|r\"");
            text = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["item"]["count"];

    elseif ( this.type == "playernote") then
        getglobal(this:GetName() .. "Title"):SetText("Edit Note");
        getglobal(this:GetName() .. "Editing"):SetText("Editing note for player \"" .. this.playerid .. "\"");
        if( CT_RaidTracker_RaidLog[this.raidid]["PlayerInfos"][this.playerid] and CT_RaidTracker_RaidLog[this.raidid]["PlayerInfos"][this.playerid]["note"] ) then
            text = CT_RaidTracker_RaidLog[this.raidid]["PlayerInfos"][this.playerid]["note"];
            end

    elseif(this.type == "looter") then
        local itemname = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["item"]["name"];
        local itemcolor = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["item"]["c"];
        local looter = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["player"];
        getglobal(this:GetName() .. "Title"):SetText("Edit Looter");
        getglobal(this:GetName() .. "Editing"):SetText("Editing looter for \"|c" .. itemcolor .. "" .. itemname .. "|r\"");
        text = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["player"];

    elseif(this.type == "time") then
        getglobal(this:GetName() .. "Title"):SetText("Edit Time");
        if(this.what == "raidend") then
            getglobal(this:GetName() .. "Editing"):SetText("Editing End Time");
            text = CT_RaidTracker_RaidLog[this.raidid]["End"];
        elseif(this.what == "raidstart") then
          getglobal(this:GetName() .. "Editing"):SetText("Editing Start Time");
            text = CT_RaidTracker_RaidLog[this.raidid]["key"];
          elseif(this.what == "item") then
          getglobal(this:GetName() .. "Editing"):SetText("Editing Item Time");
            text = CT_RaidTracker_RaidLog[this.raidid]["Loot"][this.itemid]["time"];
        end

    elseif(this.type == "zone") then
        local raidkey = CT_RaidTracker_RaidLog[this.raidid]["key"];
        text = CT_RaidTracker_RaidLog[this.raidid]["zone"];
        getglobal(this:GetName() .. "Title"):SetText("Edit Zone");
        getglobal(this:GetName() .. "Editing"):SetText("Editing zone for \"|c" .. "0000ff00" .. "" .. raidkey .. "|r\"");
    end

    if ( text ) then
        getglobal(this:GetName() .. "NoteEB"):SetText(text);
        getglobal(this:GetName() .. "NoteEB"):HighlightText();
    else
        getglobal(this:GetName() .. "NoteEB"):SetText("");
    end
end

function CT_RaidTracker_SaveCost(option)
    local text = CT_RaidTrackerEditCostFrameNoteEB:GetText();
    local raidid = CT_RaidTrackerEditCostFrame.raidid;
    local lootid;

    if(CT_RaidTrackerEditCostFrame.itemplayer and CT_RaidTrackerEditCostFrame.itemitemid and CT_RaidTrackerEditCostFrame.itemtime) then
        lootid = CT_RaidTracker_GetLootId(raidid, CT_RaidTrackerEditCostFrame.itemplayer, CT_RaidTrackerEditCostFrame.itemitemid, CT_RaidTrackerEditCostFrame.itemtime)
    end

    if ( strlen(text) == 0 ) then
        text = nil;
    end


  if(text and not string.find(text, "^(%d+%.?%d*)$") ) then
    CT_RaidTracker_Print("CT_RaidTracker Edit Costs: Invalid value", 1, 1, 0);
  else
      CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["costs"] = text;
      if ( type(dkpp_ctra_sub) == "function") then
          dkpp_ctra_sub(raidid,lootid);
      end;
  end
    if (option == "bank") then
        CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["player"] = "bank";
    end;
    if (option == "disenchanted") then
        CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["player"] = "disenchanted";
    end;

    CT_RaidTracker_Update();
    CT_RaidTracker_UpdateView();
end;

function CT_RaidTracker_SaveNote()
    local text = CT_RaidTrackerEditNoteFrameNoteEB:GetText();
    local raidid = CT_RaidTrackerEditNoteFrame.raidid;
    local typeof = type;
    local type = CT_RaidTrackerEditNoteFrame.type;
    local lootid;
    if(CT_RaidTrackerEditNoteFrame.itemplayer and CT_RaidTrackerEditNoteFrame.itemitemid and CT_RaidTrackerEditNoteFrame.itemtime) then
        lootid = CT_RaidTracker_GetLootId(raidid, CT_RaidTrackerEditNoteFrame.itemplayer, CT_RaidTrackerEditNoteFrame.itemitemid, CT_RaidTrackerEditNoteFrame.itemtime)
    end

    CT_RaidTracker_Debug("CT_RaidTracker_SaveNote", raidid, type, lootid);

    if ( strlen(text) == 0 ) then
        text = nil;
    end

    if (type == "itemnote") then
        CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["note"] = text;

    elseif (type == "itemcount") then
        if(not text or not string.find(text, "^(%d+)$") ) then
            CT_RaidTracker_Print("CT_RaidTracker Edit Count: Invalid value", 1, 1, 0);
        else
            CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["item"]["count"] = tonumber(text);
        end

    elseif (type == "raidnote" ) then
        CT_RaidTracker_RaidLog[raidid]["note"] = text;

    elseif(type == "playernote") then
        local playerid = CT_RaidTrackerEditNoteFrame.playerid;
        if ( not CT_RaidTracker_RaidLog[raidid]["PlayerInfos"][playerid] ) then
            CT_RaidTracker_RaidLog[raidid]["PlayerInfos"][playerid] = {};
        end
        CT_RaidTracker_RaidLog[raidid]["PlayerInfos"][playerid]["note"] = text;

    elseif(type == "looter") then
        if(text and strlen(text) > 0) then
            CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["player"] = text;
        end

    elseif(type == "time") then
        local what = CT_RaidTrackerEditNoteFrame.what;
        if(text and not string.find(text, "^(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)$")) then
            CT_RaidTracker_Print("CT_RaidTracker Edit Time: Invalid Time format", 1, 1, 0);
          else
              if(what == "raidend") then
                CT_RaidTracker_RaidLog[raidid]["End"] = text;
            elseif(what == "raidstart") then
                CT_RaidTracker_RaidLog[raidid]["key"] = text;
              elseif(what == "item") then
                  CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["time"] = text;
            end
        end

    elseif(type == "zone") then
        CT_RaidTracker_SaveZone(raidid, text);
    end

    CT_RaidTrackerEditNoteFrame.type = nil;
    CT_RaidTrackerEditNoteFrame.raidid = nil;
    CT_RaidTrackerEditNoteFrame.playerid = nil;
    CT_RaidTrackerEditNoteFrame.what = nil;
    CT_RaidTrackerEditNoteFrame.itemid = nil;
    CT_RaidTrackerEditNoteFrame.itemplayer = nil;
    CT_RaidTrackerEditNoteFrame.itemitemid = nil;
    CT_RaidTrackerEditNoteFrame.itemtime = nil;

    CT_RaidTracker_Update();
    CT_RaidTracker_UpdateView();
end

function CT_RaidTracker_SaveZone(raidid, text)
    local zone, zonetrigger, zonefound;
    if (text == nil or strlen(text) == 0 ) then
        text = nil;
        zone = nil;
        zonetrigger = nil;
    elseif( string.find(text, "^(.+)%-(.+)$") ) then
        _, _, zone, zonetrigger = string.find(text, "^(.+)%-(.+)$");
    else
        zone = text;
        zonetrigger = text;
    end
    if(zone and zonetrigger) then
        if(not CT_RaidTracker_RaidLog[raidid]["zone"] or CT_RaidTracker_RaidLog[raidid]["zone"] ~= zone) then
            for k, v in pairs(CT_RaidTracker_ZoneTriggers) do
                if(zonetrigger == k) then
                    zonefound = 1;
                    break;
                end
            end
            if(not zonefound) then
                for k, v in pairs(CT_RaidTracker_CustomZoneTriggers) do
                    if(zonetrigger == k) then
                        zonefound = 1;
                        break;
                    end
                end
            end
            if(not zonefound) then
                CT_RaidTracker_Print("CT_RaidTracker Custom Zones: Added \""..zone.."\" (Trigger: \""..zonetrigger.."\")", 1, 1, 0);
                CT_RaidTracker_CustomZoneTriggers[zonetrigger] = zone;
            end
        end
    elseif(not zone and not zonetrigger and CT_RaidTracker_RaidLog[raidid]["zone"]) then
        for k, v in pairs(CT_RaidTracker_CustomZoneTriggers) do
            if(v == CT_RaidTracker_RaidLog[raidid]["zone"]) then
                CT_RaidTracker_CustomZoneTriggers[k] = nil;
                CT_RaidTracker_Print("CT_RaidTracker Custom Zones: Removed \""..v.."\" (Trigger: \""..k.."\")", 1, 1, 0);
            end
        end
    end

    CT_RaidTracker_RaidLog[raidid]["zone"] = zone;
end

function CT_RaidTracker_LootSetBoss(raidid, itemitemid, itemtime, itemplayer, boss)

    local lootid = CT_RaidTracker_GetLootId(raidid, itemplayer, itemitemid, itemtime);
    CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["boss"] = boss;
    CT_RaidTracker_Update();
    CT_RaidTracker_UpdateView();
end

function CT_RaidTracker_LootSetLooter(raidid, itemitemid, itemtime, itemplayer, player)
    local lootid = CT_RaidTracker_GetLootId(raidid, itemplayer, itemitemid, itemtime);
    CT_RaidTracker_RaidLog[raidid]["Loot"][lootid]["player"] = player;
    CT_RaidTracker_Update();
    CT_RaidTracker_UpdateView();
end

function CT_RaidTracker_RaidSetZone(raidid, zone)
    CT_RaidTracker_RaidLog[raidid]["zone"] = zone;
    CT_RaidTracker_Update();
    CT_RaidTracker_UpdateView();
end

function CT_RaidTracker_ItemsRightClickMenu_Initialize(self, level)
    if(not level) then
        return;
    end
    local raidid, itemid = 0, 0;
    local dropdown, info, lvalue;

    if ( UIDROPDOWNMENU_OPEN_MENU ) then
        dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU);
    else
        dropdown = self;
    end

    if (level == 1) then
        raidid = self:GetParent().raidid;
        itemid = self:GetParent().itemid;
        local itemitemid = CT_RaidTracker_RaidLog[raidid]["Loot"][itemid]["item"]["id"];
        local itemtime = CT_RaidTracker_RaidLog[raidid]["Loot"][itemid]["time"];
        local itemplayer = CT_RaidTracker_RaidLog[raidid]["Loot"][itemid]["player"];

        info = UIDropDownMenu_CreateInfo();
        info.text = "Edit Looter";
        info.hasArrow = 1;
        info.value = { ["opt"] = "quick_looter", ["raidid"] = raidid, ["itemid"] = itemid, ["itemitemid"] = itemitemid, ["itemtime"] = itemtime, ["itemplayer"] = itemplayer, ["cplayer"] = CT_RaidTracker_RaidLog[raidid]["Loot"][itemid]["player"] };
        info.func = function(self)
            HideDropDownMenu(1);
            local lootid = CT_RaidTracker_GetLootId(self.value["raidid"], self.value["itemplayer"], self.value["itemitemid"], self.value["itemtime"]);
            CT_RaidTracker_EditLooter(self.value["raidid"], lootid);
        end;
        UIDropDownMenu_AddButton(info, level);

        info = UIDropDownMenu_CreateInfo();
        if(CT_RaidTracker_RaidLog[raidid]["Loot"][itemid]["costs"]) then
            info.text = "Edit Costs ("..CT_RaidTracker_RaidLog[raidid]["Loot"][itemid]["costs"]..")";
        else
            info.text = "Edit Costs";
        end
        info.value = { ["raidid"] = raidid, ["itemid"] = itemid, ["itemitemid"] = itemitemid, ["itemtime"] = itemtime, ["itemplayer"] = itemplayer };
        info.func = function(self)
            HideDropDownMenu(1);
            local lootid = CT_RaidTracker_GetLootId(self.value["raidid"], self.value["itemplayer"], self.value["itemitemid"], self.value["itemtime"]);
            ---OBERAN COSTS
            if(CT_RaidTracker_Options["AutoSetEPGPCost"] == true)then
                sCosts = GPLib:GetValue("item:" .. itemitemid);
                CT_RaidTracker_Debug("itemitemid:", itemitemid, "cost:", scosts);
                CT_RaidTracker_EditCostsEx(self.value.raidid, lootid, sCosts);
            else
                CT_RaidTracker_EditCosts(self.value.raidid, lootid);
            end
        end;
        UIDropDownMenu_AddButton(info, level);

        info = UIDropDownMenu_CreateInfo();
        if(CT_RaidTracker_RaidLog[raidid]["Loot"][itemid]["item"]["count"]) then
            info.text = "Edit Count ("..CT_RaidTracker_RaidLog[raidid]["Loot"][itemid]["item"]["count"]..")";
        else
            info.text = "Edit Count";
        end
        info.value = { ["raidid"] = raidid, ["itemid"] = itemid, ["itemitemid"] = itemitemid, ["itemtime"] = itemtime, ["itemplayer"] = itemplayer };
        info.func = function(self)
            HideDropDownMenu(1);
            local lootid = CT_RaidTracker_GetLootId(self.value["raidid"], self.value["itemplayer"], self.value["itemitemid"], self.value["itemtime"]);
            CT_RaidTracker_EditItemCount(self.value.raidid, lootid);
        end;
        UIDropDownMenu_AddButton(info, level);

        info = UIDropDownMenu_CreateInfo();
        info.text = "Edit Time";
        info.value = { ["raidid"] = raidid, ["itemid"] = itemid, ["itemitemid"] = itemitemid, ["itemtime"] = itemtime, ["itemplayer"] = itemplayer };
        info.func = function(self)
            HideDropDownMenu(1);
            local lootid = CT_RaidTracker_GetLootId(self.value["raidid"], self.value["itemplayer"], self.value["itemitemid"], self.value["itemtime"]);
            CT_RaidTracker_EditItemTime(self.value.raidid, lootid);
        end;
        UIDropDownMenu_AddButton(info, level);

        info = UIDropDownMenu_CreateInfo();
        info.text = "Dropped from:";
        info.hasArrow = 1;
        info.value = { ["opt"] = "dropped_from_zones", ["raidid"] = raidid, ["itemid"] = itemid, ["itemitemid"] = itemitemid, ["itemtime"] = itemtime, ["itemplayer"] = itemplayer };
        if(CT_RaidTracker_RaidLog[raidid]["Loot"][itemid]["boss"]) then
            info.text = "Dropped from: "..CT_RaidTracker_RaidLog[raidid]["Loot"][itemid]["boss"];
            info.value["cboss"] = CT_RaidTracker_RaidLog[raidid]["Loot"][itemid]["boss"];
            info.checked = 1;
        else
            info.text = "Dropped from: none";
        end
        UIDropDownMenu_AddButton(info, level);

    elseif (level == 2) then
        --if(this.value) then
        --    lvalue = this.value;
        --else
        --    lvalue = this:GetParent().value;
        --end;

        lvalue = UIDROPDOWNMENU_MENU_VALUE;

        if(lvalue) then
            if(lvalue["opt"] == "dropped_from_zones") then

                for k, v in pairs(CT_RaidTracker_Bosses) do
                    info = {};
                    if(v == 1) then
                        info.text = k;
                        info.value = { ["raidid"] = lvalue["raidid"], ["itemid"] = lvalue["itemid"], ["zone"] = lvalue["zone"], ["boss"] = k, ["itemitemid"] = lvalue["itemitemid"], ["itemtime"] = lvalue["itemtime"], ["itemplayer"] = lvalue["itemplayer"] };
                        info.func = function(self)
                            HideDropDownMenu(1);
                            CT_RaidTracker_LootSetBoss(lvalue["raidid"], lvalue["itemitemid"], lvalue["itemtime"], lvalue["itemplayer"], self.value["boss"])
                        end;
                        if(lvalue["cboss"] == k) then
                            info.checked = 1;
                        end
                    else
                        info.text = k;
                        info.hasArrow = 1;
                        info.value = { ["opt"] = "dropped_from_bosses", ["raidid"] = lvalue["raidid"], ["itemid"] = lvalue["itemid"], ["zone"] = k, ["cboss"] = lvalue["cboss"], ["itemitemid"] = lvalue["itemitemid"], ["itemtime"] = lvalue["itemtime"], ["itemplayer"] = lvalue["itemplayer"] };
                        if(lvalue["cboss"]) then
                            for k2, v2 in pairs(CT_RaidTracker_Bosses[k]) do
                                if(lvalue["cboss"] == v2) then
                                    info.checked = 1;
                                    break;
                                end
                            end
                        end
                    end
                    UIDropDownMenu_AddButton(info, level);
                end

                info = UIDropDownMenu_CreateInfo();
                info.text = "None";
                info.value = lvalue;
                info.func = function(self)
                    HideDropDownMenu(1);
                    CT_RaidTracker_LootSetBoss(self.value["raidid"], self.value["itemitemid"], self.value["itemtime"], self.value["itemplayer"], nil)
                end;
                UIDropDownMenu_AddButton(info, level);
            elseif(lvalue["opt"] == "quick_looter") then
                if(CT_RaidTracker_QuickLooter and getn(CT_RaidTracker_QuickLooter) >= 1) then
                    for k, v in pairs(CT_RaidTracker_QuickLooter) do
                        info = UIDropDownMenu_CreateInfo();
                        info.text = v;
                        info.value = { ["raidid"] = lvalue["raidid"], ["itemid"] = lvalue["itemid"], ["itemitemid"] = lvalue["itemitemid"], ["itemtime"] = lvalue["itemtime"], ["itemplayer"] = lvalue["itemplayer"], ["player"] = v, ["cplayer"] = lvalue["cplayer"] };
                        info.func = function(self)
                            HideDropDownMenu(1);
                            CT_RaidTracker_LootSetLooter(self.value["raidid"], self.value["itemitemid"], self.value["itemtime"], self.value["itemplayer"], self.value["player"]);
                        end;
                        if(lvalue["cplayer"] == v) then
                            info.checked = 1;
                        end
                        UIDropDownMenu_AddButton(info, level);
                    end
                    info = UIDropDownMenu_CreateInfo();
                    info.disabled = 1;
                    UIDropDownMenu_AddButton(info, level);
                end

                PlayerGroups = CT_RaidTracker_GetPlayerGroups(lvalue["raidid"]);
                for k, v in pairs(PlayerGroups) do
                    info = UIDropDownMenu_CreateInfo();
                    info.text = PlayerGroupsIndexes[k];
                    info.hasArrow = 1;
                    info.value = { ["opt"] = "quick_looter_subplayers", ["raidid"] = lvalue["raidid"], ["itemid"] = lvalue["itemid"], ["playergroupsindex"] = k, ["itemitemid"] = lvalue["itemitemid"], ["itemtime"] = lvalue["itemtime"], ["itemplayer"] = lvalue["itemplayer"], ["players"] = v, ["cplayer"] = lvalue["cplayer"] };
                    for k2, v2 in pairs(v) do
                        if(lvalue["cplayer"] == v2) then
                            info.checked = 1;
                            break;
                        end
                    end
                    UIDropDownMenu_AddButton(info, level);
                end
            end
        end
    elseif (level == 3) then
        --if(this.value) then
        --    lvalue = this.value;
        --else
        --    lvalue = this:GetParent().value;
        --end;

        lvalue = UIDROPDOWNMENU_MENU_VALUE;

        if(lvalue) then
            if(lvalue["opt"] == "dropped_from_bosses") then
                for k, v in pairs(CT_RaidTracker_Bosses[lvalue["zone"]]) do
                    if (type(v) == "table") then
                        for k2, v2 in pairs(v) do
                            info = UIDropDownMenu_CreateInfo();
                            info.text = k..' - '..v2;
                            info.value = { ["raidid"] = lvalue["raidid"], ["itemid"] = lvalue["itemid"], ["zone"] = lvalue["zone"], ["itemitemid"] = lvalue["itemitemid"], ["itemtime"] = lvalue["itemtime"], ["itemplayer"] = lvalue["itemplayer"], ["boss"] = v2 };
                            info.func = function(self)
                                HideDropDownMenu(1);
                                CT_RaidTracker_LootSetBoss(self.value["raidid"], self.value["itemitemid"], self.value["itemtime"], self.value["itemplayer"], self.value["boss"])
                            end;
                            if(lvalue["cboss"] == v) then
                                info.checked = 1;
                            end
                            UIDropDownMenu_AddButton(info, level);
                        end;
                    else
                        info = UIDropDownMenu_CreateInfo();
                        info.text = v;
                        info.value = { ["raidid"] = lvalue["raidid"], ["itemid"] = lvalue["itemid"], ["zone"] = lvalue["zone"], ["itemitemid"] = lvalue["itemitemid"], ["itemtime"] = lvalue["itemtime"], ["itemplayer"] = lvalue["itemplayer"], ["boss"] = v };
                        info.func = function(self)
                            HideDropDownMenu(1);
                            CT_RaidTracker_LootSetBoss(self.value["raidid"], self.value["itemitemid"], self.value["itemtime"], self.value["itemplayer"], self.value["boss"])
                        end;
                        if(lvalue["cboss"] == v) then
                            info.checked = 1;
                        end
                        UIDropDownMenu_AddButton(info, level);
                    end;
                end
            elseif(lvalue["opt"] == "quick_looter_subplayers") then
                for k, v in pairs(lvalue["players"]) do
                    info = UIDropDownMenu_CreateInfo();
                    info.text = v;
                    info.value = { ["raidid"] = lvalue["raidid"], ["itemid"] = lvalue["itemid"], ["itemitemid"] = lvalue["itemitemid"], ["itemtime"] = lvalue["itemtime"], ["itemplayer"] = lvalue["itemplayer"], ["player"] = v };
                    info.func = function(self)
                        HideDropDownMenu(1);
                        CT_RaidTracker_LootSetLooter(self.value["raidid"], self.value["itemitemid"], self.value["itemtime"], self.value["itemplayer"], self.value["player"]);
                    end;
                    if(CT_RaidTracker_RaidLog[lvalue["raidid"]]["Loot"][lvalue["itemid"]]["player"] == v) then
                        info.checked = 1;
                    end
                    UIDropDownMenu_AddButton(info, level);
                end
            end
        end
    end
end

function CT_RaidTracker_ItemsRightClickMenu_Toggle(this)
    
    local menu = getglobal(this:GetParent():GetName().."RightClickMenu");
    menu.point = "TOPLEFT";
    menu.relativePoint = "BOTTOMLEFT";
    ToggleDropDownMenu(1, nil, menu, "cursor", -60, 0);
end

function CT_RaidTracker_RaidsRightClickMenu_Initialize(self, level)
    if(not level) then
        return;
    end
    local raidid, itemid = 0, 0;
    local dropdown, info, lvalue;

    if ( UIDROPDOWNMENU_OPEN_MENU ) then
        dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU);
    else
        dropdown = self;
    end

    if (level == 1) then
        raidid = self.orig_raidid + FauxScrollFrame_GetOffset(CT_RaidTrackerListScrollFrame);
        --pprint(raidid)
        info = {};
        if ( CT_RaidTracker_RaidLog[raidid]["key"] ) then
            info.text = "Edit Start ("..CT_RaidTracker_RaidLog[raidid]["key"]..")";
        else
            info.text = "Edit Start";
        end
        info.value = { ["raidid"] = raidid, ["what"] = "raidstart"};
        info.func = function(self)
            HideDropDownMenu(1);
            CT_RaidTracker_EditTime(self.value["raidid"], self.value["what"]);
        end;
        UIDropDownMenu_AddButton(info, level);

        info = {};
        if ( CT_RaidTracker_RaidLog[raidid]["End"] ) then
            info.text = "Edit End ("..CT_RaidTracker_RaidLog[raidid]["End"]..")";
        else
            info.text = "Edit End";
        end
        info.value = { ["raidid"] = raidid, ["what"] = "raidend"};
        info.func = function(self)
            HideDropDownMenu(1);            
            CT_RaidTracker_EditTime(self.value["raidid"], self.value["what"]);
        end;
        UIDropDownMenu_AddButton(info, level);

        info = {};
        if ( CT_RaidTracker_RaidLog[raidid]["zone"] ) then
            info.text = "Edit Zone ("..CT_RaidTracker_RaidLog[raidid]["zone"]..")";
        else
            info.text = "Edit Zone";
        end
        info.hasArrow = 1;
        info.value = { ["opt"] = "raid_zones", ["raidid"] = raidid};
        info.func = function(self)
            pprint(info)
            HideDropDownMenu(1);
            CT_RaidTracker_EditZone(self.value["raidid"]);
        end;
        if ( CT_RaidTracker_RaidLog[raidid]["zone"] ) then
            for k, v in pairs(CT_RaidTracker_Zones) do
                if(CT_RaidTracker_RaidLog[raidid]["zone"] and CT_RaidTracker_RaidLog[raidid]["zone"] == v) then
                    info.checked = 1;
                    break;
                end
            end
        end
        UIDropDownMenu_AddButton(info, level);

        info = {};
        if ( CT_RaidTracker_RaidLog[raidid]["note"] ) then
            info.text = "Edit Note ("..CT_RaidTracker_RaidLog[raidid]["note"]..")";
        else
            info.text = "Edit Note";
        end
        info.value = { ["raidid"] = raidid};
        info.func = function(self)
            HideDropDownMenu(1);
            --CT_RaidTracker_EditNote(info.value["raidid"], "raidnote")
            CT_RaidTracker_EditRaidNote(self.value["raidid"]);
        end;
        UIDropDownMenu_AddButton(info, level);

        if (CT_RaidTracker_GetCurrentRaid ~= nil) then
            info = {};
            info.text = "Add Event";
            info.value = { ["raidid"] = raidid};
            info.func = function()
                HideDropDownMenu(1);
                CT_RaidTracker_ShowAddEventFrame();
            end;
            UIDropDownMenu_AddButton(info, level);

            info = {};
            info.text = "Add Attendance";
            info.value = { ["raidid"] = raidid};
            info.func = function()
                HideDropDownMenu(1);
                CT_RaidTracker_AddAttendance();
            end;
            UIDropDownMenu_AddButton(info, level);

            info = {};
            info.text = "Add Wipe";
            info.value = { ["raidid"] = raidid};
            info.func = function()
                HideDropDownMenu(1);
                CT_RaidTracker_AddWipe();
            end;
            UIDropDownMenu_AddButton(info, level);
        end



        info = {};
        info.text = "Show DKP String";
        info.value = { ["raidid"] = raidid};
        info.func = function(self)
            HideDropDownMenu(1);
            CT_RaidTrackerGenerateDkpLink(self.value["raidid"]);
        end;
        UIDropDownMenu_AddButton(info, level);
    elseif (level == 2) then
        --if(self.value) then
        --    lvalue = self.value;
        --else
        --    lvalue = self:GetParent().value;
        --end;
        lvalue = UIDROPDOWNMENU_MENU_VALUE;
        --pprint(lvalue)
        if(lvalue) then
            if(lvalue["opt"] == "raid_zones") then
                for k, v in pairs(CT_RaidTracker_Zones) do
                    info = {};
                    info.text = v;
                    info.value = { ["raidid"] = lvalue["raidid"], ["zone"] = v};
                    info.func = function(self)
                        HideDropDownMenu(1);
                        CT_RaidTracker_RaidSetZone(self.value["raidid"], self.value["zone"]);
                    end;
                    if(CT_RaidTracker_RaidLog[lvalue["raidid"]]["zone"] == v) then
                        info.checked = 1;
                    end
                    UIDropDownMenu_AddButton(info, level);
                end

                info = {};
                info.text = "None";
                info.value = { ["raidid"] = lvalue["raidid"]};
                info.func = function(self)
                    HideDropDownMenu(1);
                    CT_RaidTracker_RaidSetZone(self.value["raidid"], nil);
                end;
                UIDropDownMenu_AddButton(info, level);

                local CT_RaidTracker_CustomZoneTriggersSpacer = false;

                for k, v in pairs(CT_RaidTracker_CustomZoneTriggers) do
                    if(not CT_RaidTracker_CustomZoneTriggersSpacer) then
                        info = {};
                        info.disabled = 1;
                        UIDropDownMenu_AddButton(info, level);
                        CT_RaidTracker_CustomZoneTriggersSpacer = true;
                    end
                    info = {};
                    info.text = v;
                    info.value = { ["raidid"] = lvalue["raidid"], ["zone"] = v};
                    info.func = function(self)
                        HideDropDownMenu(1);
                        CT_RaidTracker_RaidSetZone(self.value["raidid"], self.value["zone"]);
                    end;
                    if(CT_RaidTracker_RaidLog[lvalue["raidid"]]["zone"] == v) then
                        info.checked = 1;
                    end
                    UIDropDownMenu_AddButton(info, level);
                end
            end
        end
    end
end

function CT_RaidTracker_RaidsRightClickMenu_Toggle(self)
    CT_RaidTracker_Debug("Right Click Menu Toggle", 1); 
    CT_RaidTracker_Debug(self:GetName().."RightClickMenu", 1);
    local menu = getglobal(self:GetName().."RightClickMenu");
    menu.point = "TOPLEFT";
    menu.relativePoint = "BOTTOMLEFT";
    menu.orig_raidid = self:GetID();
    ToggleDropDownMenu(1, nil, menu, "cursor", 0, 0);
end

function CT_RaidTracker_ConvertGlobalString(globalString)
    -- Stolen from nurfed (and fixed for german clients)
    globalString = string.gsub(globalString, "%%%d%$", "%%");
    globalString = string.gsub(globalString, "%%s", "(.+)");
    globalString = string.gsub(globalString, "%%d", "(%%d+)");
    return globalString;
end

--Oberan, added an overload to handle the vars being added from a call, and not the window
function CT_RaidTracker_JoinLeaveSave()
      local player_name = CT_RaidTrackerJoinLeaveFrameNameEB:GetText();
    local player_note = CT_RaidTrackerJoinLeaveFrameNoteEB:GetText();
    local player_time = CT_RaidTrackerJoinLeaveFrameTimeEB:GetText();

    CT_RaidTracker_JoinLeaveSaveEx(player_name, player_note, player_time, CT_RaidTrackerJoinLeaveFrame.raidid, CT_RaidTrackerJoinLeaveFrame.type);
end

--Oberan: Converted, and optimized most of this code to not be so dependent on the window
function CT_RaidTracker_JoinLeaveSaveEx(player_name, player_note, player_time, raidId, joinType)
    local retVal = 0;
    if(player_name == nil or strlen(player_name) == 0) then
        CT_RaidTracker_Print("CT_RaidTracker Join/Leave: No player", 1, 1, 0);
        return nil;
    end
    if(not string.find(player_time, "^(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)$")) then
        CT_RaidTracker_Print("CT_RaidTracker Join/Leave: Invalid Time format", 1, 1, 0);
        return nil;
    end

    if((strlen(player_name) > 0)) then
        local sDate = CT_RaidTracker_Date();
        CT_RaidTracker_Debug("CT_RaidTracker_JoinLeave", player_name, player_note);
        if (joinType == "Join") then
            tinsert(CT_RaidTracker_RaidLog[raidId]["Join"],
            {
               ["player"] = player_name,
               ["time"] = player_time
            }
            );
            CT_RaidTracker_Online[player_name] = 1;
            CT_RaidTracker_Print(player_name.." manually joined at "..player_time, 1, 1, 0);
            retVal = 1;
        elseif (joinType == "Leave") then
            tinsert(CT_RaidTracker_RaidLog[raidId]["Leave"],
            {
               ["player"] = player_name,
               ["time"] = player_time
            }
            );
            CT_RaidTracker_Online[player_name] = nil;
            CT_RaidTracker_Print(player_name.." manually left at "..player_time, 1, 1, 0);
            retVal = 1;
        end
        if(strlen(player_note) > 0) then
            if( not CT_RaidTracker_RaidLog[raidId]["PlayerInfos"][player_name]) then
                CT_RaidTracker_RaidLog[raidId]["PlayerInfos"][player_name] = {};
            end
            CT_RaidTracker_RaidLog[raidId]["PlayerInfos"][player_name]["note"] = player_note;
        end
        CT_RaidTracker_Update();
        CT_RaidTracker_UpdateView();
    end
    return retVal;
end




-- Next Boss selection handling

function CT_RaidTracker_Boss_InitWindow()
    UIDropDownMenu_Initialize(CT_RaidTrackerNextBossFrameBossDropdown, CT_RaidTracker_Boss_Init);
end;

function CT_RaidTracker_Boss_Init()
    local i = 0;
    local ii = 0;
    if (CT_RaidTracker_GetCurrentRaid == nil) then
        return;
    end;

    i = CT_RaidTracker_Boss_Add_Button(CT_RaidTracker_BossUnitTriggers["DEFAULTBOSS"],i);
    ii = ii + 1;
    if (CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["zone"] == nil) then
        for k,v in pairs(CT_RaidTracker_Bosses) do
                CT_RaidTracker_Debug(k,v);
            if (v == 1) then
                ii = ii + 1;
                for k2,v2 in pairs(CT_RaidTracker_BossUnitTriggers) do
                    if (v2 == v) then
                        i = CT_RaidTracker_Boss_Add_Button(k2,i);
                    end;
                end;
            end;
        end
    else
        for k,v in pairs(CT_RaidTracker_Bosses[CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["zone"]]) do
            local addit = true;
            for k2,v2 in pairs(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"]) do
                if (v2["boss"] == v) then
                    addit = false;
                end;
            end;
            if (addit == true) then
                if (type(v) == "table") then
                    for k2,v2 in pairs(v) do
                        ii = ii + 1;
                        for k3,v3 in pairs(CT_RaidTracker_BossUnitTriggers) do
                            if (v3 == v2) then
                                i = CT_RaidTracker_Boss_Add_Button(k..' - '..k3,i);
                            end;
                        end;
                    end;
                else
                    ii = ii + 1;
                    for k2,v2 in pairs(CT_RaidTracker_BossUnitTriggers) do
                        if (v2 == v) then
                            i = CT_RaidTracker_Boss_Add_Button(k2,i);
                        end;
                    end;
                end;
            end;
        end
    end;
    if (ii == 2) then
        UIDropDownMenu_SetSelectedID(CT_RaidTrackerNextBossFrameBossDropdown, ii);
    end;
end;

function CT_RaidTracker_Boss_Add_Button(k,i)
    local info = {
        text = k;
        func = CT_RaidTracker_Boss_Update;
    };
    UIDropDownMenu_AddButton(info);
    if (i == cur_class_id) then
        UIDropDownMenu_SetSelectedID(CT_RaidTrackerNextBossFrameBossDropdown, i+1);
        UIDropDownMenu_SetText(info.text, CT_RaidTrackerNextBossFrameBossDropdown);
    end
    return i
end;

function CT_RaidTracker_Boss_Update()
    i = this:GetID();
    UIDropDownMenu_SetSelectedID(CT_RaidTrackerNextBossFrameBossDropdown, i);
end;

function CT_RaidTracker_ShowAddEventFrame()
    if (CT_RaidTracker_GetCurrentRaid == nil) then
        CT_RaidTracker_Print("You must have an active raid to use this function. Type '/rt' and then click 'New' to start a raid.", 1, 1, 0);
        return false;
    else
        CT_RaidTrackerAddEventFrameNameEB:SetText("");
        CT_RaidTrackerAddEventFrameTitle:SetText("Add Event");
        if (CT_RaidTracker_Options["AutoBossBoss"] ~= nil) then
            CT_RaidTrackerAddEventFrameNameEB:SetText(CT_RaidTracker_Options["AutoBossBoss"]);
        end
        CT_RaidTrackerAddEventFrame.type = "AddEvent";
        CT_RaidTrackerAddEventFrame.raidid = CT_RaidTrackerFrame.selected;
        CT_RaidTrackerAddEventFrame:Show();
    end
end

--[[
Guild Launch Logging
]]

-- RT AddEvent

function CT_RaidTracker_AddEventSave()
    local event_name = CT_RaidTrackerAddEventFrameNameEB:GetText();
    local event_note = CT_RaidTrackerAddEventFrameNoteEB:GetText();
    local event_value = CT_RaidTrackerAddEventFrameValueEB:GetText();
    local event_time = CT_RaidTrackerAddEventFrameTimeEB:GetText();

    CT_RaidTracker_AddEventSaveEx(event_name, event_note, event_value, event_time);
end

function CT_RaidTracker_AddEventSaveEx(event_name, event_note, event_value, event_time)
    local tAttendees = { };
    local tAttendeesWaitlist = { };
    
    if( (CT_RaidTracker_Options["LogAttendees"] == 1) or (CT_RaidTracker_Options["LogAttendees"] == 3)) then
        if((IsInRaid() == true) and (GetNumGroupMembers() > 0)) then
            for i = 1, GetNumGroupMembers() do
                local rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i);
                local name = GetFixedUpUnitName("raid" .. i, true);
                if (name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                    if (CT_RaidTracker_Options["LogAttendees"] == 3)then
                        if (zone==GetRealZoneText()) then
                            tinsert(tAttendees, name);
                        end;
                    else
                        tinsert(tAttendees, name);
                    end;
                end
            end
        elseif( (GetNumGroupMembers() > 0) and (CT_RaidTracker_Options["LogGroup"] == true) ) then
            for i = 1, GetNumGroupMembers() do
                local name = GetFixedUpUnitName("party" .. i, true);
                if (name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                    tinsert(tAttendees, name);
                end
            end
            --Party dosent include player, so add individual
            local name = GetFixedUpUnitName("player", true);
            if (name and name ~= UKNOWNBEING and name ~= UNKNOWN) then
                tinsert(tAttendees, name);
            end
        end

        if (CT_RaidTracker_Options["WaitlistAttendanceType"] == 1) then                        
            for k,v in pairs(CT_RaidTracker_WaitList) do
                tinsert(tAttendees, k);
            end
        elseif (CT_RaidTracker_Options["WaitlistAttendanceType"] == 2) then
            for k,v in pairs(CT_RaidTracker_WaitList) do
                tinsert(tAttendeesWaitlist, k);
            end                        
        else
            for k,v in pairs(CT_RaidTracker_WaitList) do
                tinsert(tAttendees, k);
            end    
        end
    end

    if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"]) then
        CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"] = { };
    end

    tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"],
        {
        ["boss"] = event_name,
        ["time"] = event_time,
        ["attendees"] = tAttendees,
        ["value"] = event_value,
        ["event_note"] = event_note,
        }
    );
            
    -- add wait listers if there are any
    if (#(tAttendeesWaitlist) > 0) then                                                    
        if (CT_RaidTracker_Options["WaitlistAttendanceType"] == 2) then
            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"],
                {
                ["boss"] = event_name .. " - Waitlist",
                ["time"] = event_time,
                ["attendees"] = tAttendeesWaitlist,
                ["value"] = event_value,
                ["event_note"] = event_note,                
                }
            );                    
        end
    end            

    CT_RaidTracker_Print("Event Added:"..event_name.." manually added at "..event_time.." for a value of "..event_value, 1, 1, 0);
end

function CT_RaidTracker_AddEventWithAttendees(event_name, event_value, event_attendees)
    local tAttendees = { };
    local tAttendeesWaitlist = { };
    --pprint(event_attendees)
    for player_name,v in pairs(event_attendees) do
        --pprint(v)
        --CT_RaidTracker_Print("next attendee");
        tinsert(tAttendees, player_name);
    end

    --for k,v in pairs(CT_RaidTracker_WaitList) do
    --    tinsert(tAttendees, k);
    --end
    
    if (CT_RaidTracker_Options["WaitlistAttendanceType"] == 1) then                        
        for k,v in pairs(CT_RaidTracker_WaitList) do
            tinsert(tAttendees, k);
        end
    elseif (CT_RaidTracker_Options["WaitlistAttendanceType"] == 2) then
        for k,v in pairs(CT_RaidTracker_WaitList) do
            tinsert(tAttendeesWaitlist, k);
        end                        
    else
        for k,v in pairs(CT_RaidTracker_WaitList) do
            tinsert(tAttendees, k);
        end    
    end

    if(not CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"]) then
        CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"] = { };
    end

    if(CT_RaidTracker_Options["AutoBoss"] >= 1) then
        sBoss = CT_RaidTracker_Options["AutoBossBoss"];
        if (sBoss ~= nil and sBoss ~= "") then
            event_name = sBoss;
        end
    end

    tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"],
            {
                ["boss"] = event_name,
                ["time"] = CT_RaidTracker_Date(),
                ["attendees"] = tAttendees,
                ["value"] = event_value,
                ["event_source"] = "DKPmon",
            }
            );
            
    -- add wait listers if there are any
    if (#(tAttendeesWaitlist) > 0) then                                                    
        if (CT_RaidTracker_Options["WaitlistAttendanceType"] == 2) then
            tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["BossKills"],
                {
                ["boss"] = event_name .. " - Waitlist",
                ["time"] = sDate,
                ["attendees"] = tAttendeesWaitlist,
                ["event_source"] = "DKPmon",
                }
            );                    
        end
    end            

    CT_RaidTracker_Print("Event Added:"..event_name.." manually added at "..CT_RaidTracker_Date().." for a value of "..event_value, 1, 1, 0);
end

function CT_RaidTracker_AddItem(sPlayer, event_name, itemLink, sCosts)
    --pprint(itemwinners);

    if(CT_RaidTracker_Options["AutoBoss"] >= 1) then
        sBoss = CT_RaidTracker_Options["AutoBossBoss"];
        if (sBoss ~= nil and sBoss ~= "") then
            event_name = sBoss;
        end
    end

    iCount = 1;

    local sColor, sItem, sName = CT_RaidTracker_GetItemInfo(itemLink);

    local nameGIF, linkGIF, qualityGIF, iLevelGIF, minLevelGIF, classGIF, subclassGIF, maxStackGIF, invtypeGIV, iconGIF = GetItemInfo("item:"..sItem);
    _,_, iconGIF = string.find(iconGIF, "^.*\\(.*)$")

    if(CT_RaidTracker_Options["SaveTooltips"] == true) then
        tTooltip = CT_RaidTracker_GetItemTooltip(sItem);
    end

    tinsert(CT_RaidTracker_RaidLog[CT_RaidTracker_GetCurrentRaid]["Loot"], 1,
        {
            ["player"] = sPlayer,
            ["item"] = {
                ["c"] = sColor,
                ["id"] = sItem,
                ["tooltip"] = tTooltip,
                ["name"] = sName,
                ["icon"] = iconGIF,
                ["count"] = iCount,
                ["class"] = classGIF,
                ["subclass"] = subclassGIF,
            },
            ["zone"] = GetRealZoneText(),
            ["costs"] = sCosts,
            ["boss"] = event_name,
            ["time"] = CT_RaidTracker_Date(),
            ["note"] = sNote,
            ["attendees"] = tAttendees,
            ["event_source"] = "DKPmon",
        }
    );

    CT_RaidTracker_Print("Event Added:"..event_name.." manually added at "..CT_RaidTracker_Date().." for a item "..sName, 1, 1, 0);
end

local recursions = {}

local function better_toString(data, depth)
    if type(data) == "string" then
        return ("%q"):format(data)
    elseif type(data) == "wstring" then
        return ("L%q"):format(WStringToString(data))
    elseif type(data) ~= "table" then
        return ("%s"):format(tostring(data))
    else
        if recursions[data] then
            return "{<recursive table>}"
        end
        recursions[data] = true
        if next(data) == nil then
            return "{}"
        elseif next(data, next(data)) == nil then
            return "{ [" .. better_toString(next(data), depth) .. "] = " .. better_toString(select(2, next(data)), depth) .. " }"
        else
            local t = {}
            t[#t+1] = "{\n"
            local keys = {}
            for k in pairs(data) do
                keys[#keys+1] = k
            end
            table.sort(keys, mysort)
            for _, k in ipairs(keys) do
                local v = data[k]
                for i = 1, depth do
                    t[#t+1] = "    "
                end
                t[#t+1] = "["
                t[#t+1] = better_toString(k, depth+1)
                t[#t+1] = "] = "
                t[#t+1] = better_toString(v, depth+1)
                t[#t+1] = ",\n"
            end

            for i = 1, depth do
                t[#t+1] = "    "
            end
            t[#t+1] = "}"
            return table.concat(t)
        end
    end
end

function pprint(...)
    local n = select('#', ...)
    local t = {n, ': '}
    for i = 1, n do
        if i > 1 then
            t[#t+1] = ", "
        end
        t[#t+1] = better_toString((select(i, ...)), 0)
    end
    for k in pairs(recursions) do
        recursions[k] = nil
    end
    --print(table.concat(t))
end

function GetFixedUpUnitName(name)
    if name == nil then
        return name
    else
        local fixedUpUnitName = GetUnitName(name, true)
        if fixedUpUnitName == nil then
            return name
        end
        if string.match(fixedUpUnitName, "-") then
            return  fixedUpUnitName:gsub("%s+", "")
        else
            local realmName = GetRealmName(name)
            return fixedUpUnitName.."-"..realmName:gsub("%s+", "")
        end
    end
end