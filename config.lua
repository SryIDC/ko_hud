Config = {}

-- Can be 'qbcore', 'esx' or 'standalone'.
Config.framework = 'qbcore' -- Default = 'standalone'

-- Toggle LegacyFuel hook.
Config.LegacyFuel = false -- Default = false

-- Toggle pmaVoice hook.
Config.pmaVoice = true -- Default = false

-- Configure the location component.
Config.location = {
    enabled = true, -- Default = true
    left = 310,     -- Default = 310
    bottom = 30     -- Default = 30
}

-- Defines the hud update time, a higher value may reduce script consumption.
Config.globalUpdateTime = 1 -- Default = 1

-- Configure the speedometer component.
Config.speedometer = {
    enabled = true, -- Default = true
    bottom = -50    -- Default = -50
}

-- Configure the status component.
Config.status = {
    enabled = true, -- Default = true
    right = 20,     -- Default = 20
    bottom = 30     -- Default = 30
}

-- Activates/deactivates GTA's vanilla hud for life and armor. [default = false]
Config.vanilla = false

-- Enables/disables components that may interfere with the use of this HUD. [default = true]
Config.componentsDisabler = true

-- Enables/disables radar display only in vehicle (also affects position hud). [default = true]
Config.radarOnlyInCar = false

-- Configure minimap settings
Config.minimap = {
    enabled = false,  -- Enable/disable minimap customization
    zoomLevel = 200,  -- Minimap zoom level (100-400, default GTA is ~200)
    shape = 'square', -- 'square' or 'circle' minimap shape
    position = {
        x = 0.0,      -- X position offset (-1.0 to 1.0)
        y = 0.0       -- Y position offset (-1.0 to 1.0)
    },
    size = {
        width = 0.18,      -- Minimap width (0.1 to 0.3)
        height = 0.24      -- Minimap height (0.1 to 0.4)
    },
    showInInterior = true, -- Show minimap in interiors
    fadeWithHUD = true     -- Fade minimap with HUD visibility
}

-- Activates/deactivates the hunger bar display. [default = true]
Config.enableHunger = true

-- Activates/deactivates the thirst bar display. [default = true]
Config.enableThirst = true

-- Activates/deactivates the seat belt display. [default = true]
Config.enableSeatBelt = true

-- Activates/deactivates the fuel level display. [default = true]
Config.enableFuel = true

-- Activates/deactivates the voice display. [default = true]
Config.enableVoice = true

-- Activates/deactivates the armor bar display. [default = true]
Config.enableArmor = true

-- Activates/deactivates the stress bar display. [default = true]
Config.enableStress = true

-- Configure automatic stress increases
Config.stressConfig = {
    enabled = true,       -- Enable automatic stress increases
    maxStress = 100,      -- Maximum stress level (0-100)
    persistStress = true, -- Save/restore stress across resource restarts

    -- Shooting stress
    shootingStress = {
        enabled = true,  -- Enable stress from shooting
        increase = 1,    -- Stress increase per shot
        cooldown = 1000, -- Cooldown between stress increases (ms)
    },

    -- Driving stress (speed without seatbelt)
    drivingStress = {
        enabled = true,      -- Enable stress from dangerous driving
        speedThreshold = 75, -- Speed threshold (mph/kmh based on Config.useMiles)
        increase = 0.5,      -- Stress increase per interval
        interval = 2000,     -- Check interval (ms)
    }
}

-- Activates/deactivates the bank balance display. [default = true]
Config.enableBankBalance = true

-- Configure bank balance settings
Config.bankBalance = {
    enabled = true, -- Enable/disable bank balance display
    updateTime = 5, -- Update interval in seconds
    position = {
        top = 190,  -- Top position in pixels
        right = 25  -- Right position in pixels
    }
}

-- Activates/deactivates the cash balance display. [default = true]
Config.enableCashBalance = false

-- Configure cash balance settings
Config.cashBalance = {
    enabled = true, -- Enable/disable cash balance display
    updateTime = 5, -- Update interval in seconds
    position = {
        top = 200,  -- Top position in pixels
        right = 25  -- Right position in pixels
    }
}

-- Activates/deactivates the job display. [default = true]
Config.enableJobDisplay = true

-- Configure job display settings
Config.jobDisplay = {
    enabled = true, -- Enable/disable job display
    updateTime = 3, -- Update interval in seconds
    position = {
        top = 150,  -- Top position in pixels (above balances)
        right = 25  -- Right position in pixels
    }
}

-- Activates/deactivates the player ID display. [default = true]
Config.enablePlayerID = true

-- Configure player ID display settings
Config.playerID = {
    enabled = true,  -- Enable/disable player ID display
    updateTime = 2,  -- Update interval in seconds
    position = {
        right = 70,  -- Right position in pixels (next to voice icon)
        bottom = 150 -- Bottom position in pixels (aligned with voice icon)
    }
}

-- Determines whether you want to use miles or kilometers. [default = true]
Config.useMiles = false

-- List of electric vehicles.
Config.electricVehicles = {
    `buffalo5`,
    `cyclone`,
    `cyclone2`,
    `dilettante`,
    `dilettante2`,
    `iwagen`,
    `imorgon`,
    `khamelion`,
    `coureur`,
    `neon`,
    `omnisegt`,
    `powersurge`,
    `raiden`,
    `voltic2`,
    `surge`,
    `tezeract`,
    `virtue`,
    `voltic`,
    `caddy`,
    `caddy2`,
    `caddy3`,
    `airtug`
}
