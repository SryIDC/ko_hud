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
Config.enableStress = true
Config.useStress = {
    shooting = true,
    driving = true,
}
Config.screenShake = 70            -- Minimum stress level for screen shaking
Config.shootingStressChance = 0.05 -- Percentage stress chance when shooting (0-1) (default = 10%)
Config.unbuckledSpeed = 400        -- Going over this Speed will cause stress
Config.minimumSpeed = 400          -- Going over this Speed will cause stress
Config.stressWLJobs = {
    police = true,
    ambulance = true,
}

Config.weaponWLStress = { -- Disable gaining stress from weapons in this table
    [`weapon_petrolcan`] = false,
    [`weapon_hazardcan`] = false,
    [`weapon_fireextinguisher`] = false
}

Config.intensity = {
    [1] = {
        min = 50,
        max = 60,
        intensity = 1500,
    },
    [2] = {
        min = 60,
        max = 70,
        intensity = 2000,
    },
    [3] = {
        min = 70,
        max = 80,
        intensity = 2500,
    },
    [4] = {
        min = 80,
        max = 90,
        intensity = 2700,
    },
    [5] = {
        min = 90,
        max = 100,
        intensity = 3000,
    },
}

Config.effectInterval = {
    [1] = {
        min = 50,
        max = 60,
        timeout = math.random(50000, 60000)
    },
    [2] = {
        min = 60,
        max = 70,
        timeout = math.random(40000, 50000)
    },
    [3] = {
        min = 70,
        max = 80,
        timeout = math.random(30000, 40000)
    },
    [4] = {
        min = 80,
        max = 90,
        timeout = math.random(20000, 30000)
    },
    [5] = {
        min = 90,
        max = 100,
        timeout = math.random(15000, 20000)
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
    [`buffalo5`] = true,
    [`cyclone`] = true,
    [`cyclone2`] = true,
    [`dilettante`] = true,
    [`dilettante2`] = true,
    [`iwagen`] = true,
    [`imorgon`] = true,
    [`khamelion`] = true,
    [`coureur`] = true,
    [`neon`] = true,
    [`omnisegt`] = true,
    [`powersurge`] = true,
    [`raiden`] = true,
    [`voltic2`] = true,
    [`surge`] = true,
    [`tezeract`] = true,
    [`virtue`] = true,
    [`voltic`] = true,
    [`caddy`] = true,
    [`caddy2`] = true,
    [`caddy3`] = true,
    [`airtug`] = true
}
