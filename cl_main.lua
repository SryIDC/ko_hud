local playerId = PlayerId()
local playerPed = PlayerPedId()
local playerCoords = GetEntityCoords(playerPed)
local inVehicle = IsPedInAnyVehicle(playerPed)

CreateThread(function()
    while true do
        playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)
        inVehicle = IsPedInAnyVehicle(playerPed)

        Wait(100)
    end
end)


local hudVisible = true
local QBCore = nil

-- Hide HUD when map/pause menu is open
CreateThread(function()
    local lastPauseState = false
    while true do
        Wait(200)
        local pauseActive = IsPauseMenuActive()
        if pauseActive ~= lastPauseState then
            lastPauseState = pauseActive
            SendNUIMessage({
                component = 'hud',
                visible = not pauseActive
            })
        end
    end
end)

exports('hudVisibility', function(toggle)
    hudVisible = toggle
end)

--
-- HIDE HEALTH
--
-- MINIMAP SETUP
--

CreateThread(function()
    local scaleform = RequestScaleformMovie('minimap')

    SetRadarBigmapEnabled(true, false)

    Wait(0)

    SetRadarBigmapEnabled(false, false)

    -- Apply minimap customization if enabled
    if Config.minimap and Config.minimap.enabled then
        -- Set minimap zoom level
        SetRadarZoom(Config.minimap.zoomLevel)

        -- Set minimap position and size
        SetMinimapComponentPosition('minimap', 'L', 'B',
            Config.minimap.position.x, Config.minimap.position.y,
            Config.minimap.size.width, Config.minimap.size.height)

        -- Set minimap shape (square or circle)
        if Config.minimap.shape == 'square' then
            SetMinimapClipType(0) -- Square
        else
            SetMinimapClipType(1) -- Circle
        end

        -- Configure interior display
        if Config.minimap.showInInterior then
            SetRadarAsInteriorThisFrame(GetHashKey(""), 0.0, 0.0, 0, 1)
        else
            SetRadarAsInteriorThisFrame(GetHashKey(""), 0.0, 0.0, 0, 0)
        end
    end

    while true do
        BeginScaleformMovieMethod(scaleform, 'SETUP_HEALTH_ARMOUR')

        if Config.vanilla then
            ScaleformMovieMethodAddParamInt(1)
            EndScaleformMovieMethod()
            return
        end

        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
        SetRadarBigmapEnabled(false, false)

        Wait(0)
    end
end)

--
-- HUD COMPONENTS
--

if Config.componentsDisabler then
    CreateThread(function()
        while true do
            HideHudComponentThisFrame(1)
            HideHudComponentThisFrame(3)
            HideHudComponentThisFrame(4)
            HideHudComponentThisFrame(6)
            HideHudComponentThisFrame(8)
            HideHudComponentThisFrame(7)
            HideHudComponentThisFrame(9)

            Wait(0)
        end
    end)
end

--
-- RADAR IN VEHICLE
--

local bypass = false

exports('bypassRadar', function(toggle)
    bypass = toggle
end)


-- Need to set command
CreateThread(function()
    DisplayRadar(true)

    if not Config.radarOnlyInCar then
        return
    end

    while true do
        if bypass then
            DisplayRadar(true)
        else
            if not inVehicle then
                DisplayRadar(false)
            else
                DisplayRadar(true)
            end
        end

        Wait(1000)
    end
end)

--
-- HUD LOCATION
--

local activeCoords = vec2(0.0, 0.0)
local postalText = 'CP 0000'
local directionText = 'N'
local postals = {}
local zones = {}

-- CreateThread(function()
--     local postalsJson = LoadResourceFile(GetCurrentResourceName(), 'zips.json')
--     postalsJson = json.decode(postalsJson)

--     for i, postal in ipairs(postalsJson) do
--         postals[i] = { vec2(postal.x, postal.y), code = postal.code }
--     end

--     local zonesJson = LoadResourceFile(GetCurrentResourceName(), 'zones.json')
--     zonesJson = json.decode(zonesJson)

--     for _, zone in pairs(zonesJson) do
--         zones[zone.zone] = zone.name
--     end
-- end)

-- CreateThread(function()
--     while not postals do
--         Wait(0)
--     end

--     while true do
--         local nearestIndex, nearestDist

--         for i = 1, #postals do
--             local dist = #(playerCoords.xy - postals[i][1])

--             if not nearestDist or dist < nearestDist then
--                 nearestIndex = i
--                 nearestDist = dist
--                 activeCoords = postals[i][1]
--             end
--         end

--         local code = postals[nearestIndex].code

--         postalText = string.format('CP %s', code)

--         Wait(1000)
--     end
-- end)

-- CreateThread(function()
--     local directions = {
--         [0] = 'N',
--         [45] = 'NW',
--         [90] = 'W',
--         [135] = 'SW',
--         [180] = 'S',
--         [225] = 'SE',
--         [270] = 'E',
--         [315] =
--         'NE',
--         [360] = 'N',
--     }

--     while true do
--         for k, v in pairs(directions) do
--             direction = GetEntityHeading(playerPed)

--             if math.abs(direction - k) < 22.5 then
--                 directionText = v
--                 break
--             end
--         end

--         Wait(500)
--     end
-- end)

-- CreateThread(function()
--     while true do
--         if not IsRadarHidden() and Config.location.enabled and hudVisible then
--             local zone = GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)
--             local streetname, _ = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
--             local streetnameText = GetStreetNameFromHashKey(streetname)
--             local dist = #(playerCoords.xy - activeCoords)
--             local distanceText = string.format('%sm', math.floor(dist))
--             local zoneText = streetnameText

--             if zones[string.upper(zone)] then
--                 zoneText = zones[string.upper(zone)]
--             end

--             SendNUIMessage({
--                 component = 'position',
--                 heading = GetEntityHeading(playerPed),
--                 postal = postalText,
--                 direction = directionText,
--                 distance = distanceText,
--                 street = streetnameText,
--                 zone = zoneText
--             })
--         else
--             SendNUIMessage({
--                 component = 'position',
--                 visible = false
--             })
--         end

--         Wait(Config.globalUpdateTime)
--     end
-- end)

--
-- HUD STATUS
--

local hunger = 100
local thirst = 100
local stress = 0
local voice_type = 'mic_mute.png'
local voice_talking = false
local voice_radio = false
local seatbelt = false

-- Stress tracking variables
local lastShootTime = 0
local lastStressCheck = 0
local customStressManagement = false -- Flag to indicate we're managing stress manually

-- Stress persistence functions
-- local function saveStress(stressValue)
--     if Config.stressConfig and Config.stressConfig.persistStress then
--         -- SetResourceKvp('jordqn_hud_stress', tostring(stressValue))
--         -- print("Stress saved:", stressValue)
--         LocalPlayer.state:set('stress', stressValue, true)
--     end
-- end

local function loadStress()
    if Config.stressConfig and Config.stressConfig.persistStress then
        local savedStress = GetResourceKvpString('jordqn_hud_stress')
        if savedStress then
            local stressValue = tonumber(savedStress) or 0
            if stressValue > 0 then
                customStressManagement = true
                -- print("Stress loaded:", stressValue)
                return stressValue
            end
        end
    end
    return 0
end

-- Load stress on script start
-- CreateThread(function()
--     Wait(1000) -- Wait for everything to initialize
--     local loadedStress = loadStress()
--     if loadedStress > 0 then
--         stress = loadedStress
--         -- print("Restored stress value:", stress)
--     end
-- end)

-- Auto-save stress periodically to prevent loss
-- CreateThread(function()
--     while true do
--         Wait(30000) -- Save every 30 seconds
--         if customStressManagement and Config.stressConfig and Config.stressConfig.persistStress then
--             saveStress(stress)
--         end
--     end
-- end)

-- Reset stress on revive/respawn
-- local wasPlayerDead = false

-- CreateThread(function()
--     while true do
--         local playerPed = PlayerPedId()
--         local isDead = IsEntityDead(playerPed) or IsPedFatallyInjured(playerPed)

--         -- Check if player was dead and is now alive (revived)
--         if wasPlayerDead and not isDead then
--             -- print("Player revived - resetting stress to 0")
--             stress = 0
--             customStressManagement = true
--             saveStress(0)
--             TriggerEvent('hud:stressChanged', 0)
--         end

--         wasPlayerDead = isDead
--         Wait(1000) -- Check every second
--     end
-- end)


AddStateBagChangeHandler('hunger', ('player:%s'):format(cache.serverId), function(_, _, value)
    hunger = value
end)

-- AddStateBagChangeHandler('dead', ('player:%s'):format(cache.serverId), function(_, _, value)
--     wasPlayerDead = value
-- end)


AddStateBagChangeHandler('thirst', ('player:%s'):format(cache.serverId), function(_, _, value)
    thirst = value
end)

AddStateBagChangeHandler('stress', ('player:%s'):format(cache.serverId), function(_, _, value)
    stress = value

    LocalPlayer.state:set('stress', value, true)
    TriggerEvent('hud:stressChanged', value)
end)

-- exports('setThirst', function(val)
--     thirst = val
-- end)

-- exports('setHunger', function(val)
--     hunger = val
-- end)

-- exports('setStress', function(val)
--     stress = val
--     customStressManagement = true
--     saveStress(val)
--     -- print("Stress set via export to:", val)
-- end)

-- Function to safely increase stress
local function increaseStress(amount)
    if not Config.stressConfig or not Config.stressConfig.enabled then
        -- print("Stress system disabled or config missing")
        return
    end

    LocalPlayer.state:set('stress', stress + amount, true)
end

exports('setVoiceDistance', function(val)
    if val == 0 then
        voice_type = 'mic_mute.png'
    elseif val == 1 then
        voice_type = 'mic_one.png'
    elseif val == 2 then
        voice_type = 'mic_two.png'
    elseif val == 3 then
        voice_type = 'mic_three.png'
    end
end)

AddEventHandler("pma-voice:setTalkingMode", function(mode)
    voiceRange = NetworkIsPlayerTalking(cache.playerId) == 1
    updateStats()
end)

AddEventHandler("pma-voice:radioActive", function(radioTalking)
    voice_radio = radioTalking
end)

-- exports('setVoiceRadio', function(toggle)
--     voice_radio = toggle
-- end)

-- exports('setVoiceTalking', function(toggle)
--     voice_talking = toggle
-- end)

CreateThread(function()
    if Config.framework == 'esx' then
        AddEventHandler('esx_status:onTick', function(data)
            for i = 1, #data do
                if data[i].name == 'thirst' then
                    thirst = math.floor(data[i].percent)
                end

                if data[i].name == 'hunger' then
                    hunger = math.floor(data[i].percent)
                end

                if data[i].name == 'stress' then
                    stress = math.floor(data[i].percent)
                end
            end
        end)
    end

    if Config.framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
    end

    while true do
        ::redo::

        Wait(Config.globalUpdateTime)

        local voice = voice_type

        if voice_radio then
            voice = 'mic_radio.png'
        end

        if Config.status.enabled and hudVisible then
            if Config.framework == 'qbcore' then
                local PlayerData = QBCore.Functions.GetPlayerData()

                if (PlayerData.metadata ~= nil) then
                    hunger = PlayerData.metadata['hunger']
                    thirst = PlayerData.metadata['thirst']

                    -- Only update stress from metadata if we're not managing it manually
                    if not customStressManagement then
                        stress = PlayerData.metadata['stress'] or 0
                    end

                    -- Ensure stress is within valid bounds
                    if stress < 0 then stress = 0 end
                    if stress > 100 then stress = 100 end
                else
                    SendNUIMessage({
                        component = 'status',
                        visible = false
                    })

                    goto redo
                end
            end

            if Config.pmaVoice then
                exports['jordqn_hud']:setVoiceDistance(LocalPlayer.state.proximity.index)

                if not MumbleIsPlayerTalking(playerId) then
                    voice_talking = false
                else
                    voice_talking = true
                end
            end

            SendNUIMessage({
                component = 'status',
                framework = Config.framework,
                hungerVisible = Config.enableHunger,
                thirstVisible = Config.enableThirst,
                armorVisible = Config.enableArmor,
                voiceVisible = Config.enableVoice,
                stressVisible = Config.enableStress,
                voiceType = voice,
                voiceTalking = voice_talking,
                health = GetEntityHealth(playerPed),
                maxhealth = GetEntityMaxHealth(playerPed),
                armor = GetPedArmour(playerPed),
                hunger = hunger,
                thirst = thirst,
                stress = stress,
                oxygen = GetPlayerUnderwaterTimeRemaining(playerId)
            })

            -- Debug: Print stress info occasionally
            if GetGameTimer() % 5000 < 100 then -- Every 5 seconds roughly
                -- print(string.format("DEBUG: Stress=%d, StressVisible=%s, EnableStress=%s",
                --     stress,
                --     tostring(Config.enableStress),
                --     tostring(Config.enableStress)))
            end
        else
            SendNUIMessage({
                component = 'status',
                visible = false
            })
        end
    end
end)

--
-- PMA VOICE
--

-- if Config.pmaVoice then
--     AddEventHandler('pma-voice:radioActive', function(toggle)
--         voice_radio = toggle
--     end)
-- end

--
-- STRESS DETECTION
--

-- print("About to start stress detection threads...")
-- print("Config exists:", Config ~= nil)
-- print("Config.stressConfig exists:", Config.stressConfig ~= nil)

-- Shooting stress detection
CreateThread(function()
    -- print("Starting shooting stress detection thread")
    Wait(2000) -- Wait for everything to load

    -- Debug config
    if Config.stressConfig then
        -- print("Config.stressConfig exists")
        -- print("Config.stressConfig.enabled:", Config.stressConfig.enabled)
        if Config.stressConfig.shootingStress then
            -- print("Config.stressConfig.shootingStress.enabled:", Config.stressConfig.shootingStress.enabled)
            -- print("Config.stressConfig.shootingStress.increase:", Config.stressConfig.shootingStress.increase)
        else
            -- print("Config.stressConfig.shootingStress is nil")
        end
    else
        -- print("Config.stressConfig is nil")
    end

    while true do
        if Config.stressConfig and Config.stressConfig.enabled and Config.stressConfig.shootingStress.enabled then
            local isShooting = IsPedShooting(playerPed)

            if isShooting then
                local currentTime = GetGameTimer()
                -- print("Player is shooting! Current time:", currentTime, "Last shot time:", lastShootTime)

                -- Check if enough time has passed since last stress increase
                if currentTime - lastShootTime >= Config.stressConfig.shootingStress.cooldown then
                    -- print("Player is shooting - increasing stress by", Config.stressConfig.shootingStress.increase)
                    increaseStress(Config.stressConfig.shootingStress.increase)
                    lastShootTime = currentTime
                else
                    -- print("Shooting detected but cooldown active. Time since last:", currentTime - lastShootTime)
                end
            end
        else
            if not Config.stressConfig then
                -- print("Config.stressConfig is nil")
            elseif not Config.stressConfig.enabled then
                -- print("Stress system disabled")
            elseif not Config.stressConfig.shootingStress.enabled then
                -- print("Shooting stress disabled")
            end
        end

        Wait(100) -- Check every 100ms for responsive shooting detection
    end
end)

-- Driving stress detection (speed without seatbelt)
CreateThread(function()
    -- print("Starting driving stress detection thread")
    while true do
        if Config.stressConfig and Config.stressConfig.enabled and Config.stressConfig.drivingStress.enabled then
            if inVehicle then
                local vehicle = GetVehiclePedIsIn(playerPed, false)

                if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    local speed = GetEntitySpeed(vehicle)
                    local speedConverted = Config.useMiles and (speed * 2.236936) or (speed * 3.6)

                    -- Get current seatbelt state - try multiple methods
                    local currentSeatbelt = false

                    -- Try to get from qbx_seatbelt export
                    local success, result = pcall(function()
                        return exports['qbx_seatbelt']:getSeatbeltState()
                    end)
                    if success and result ~= nil then
                        currentSeatbelt = result
                    else
                        -- Try alternative export
                        success, result = pcall(function()
                            return exports['qbx_seatbelt']:GetSeatbeltState()
                        end)
                        if success and result ~= nil then
                            currentSeatbelt = result
                        else
                            -- Try player state
                            success, result = pcall(function()
                                return LocalPlayer.state.seatbelt
                            end)
                            if success and result ~= nil then
                                currentSeatbelt = result
                            else
                                -- Fall back to internal seatbelt variable
                                currentSeatbelt = seatbelt
                            end
                        end
                    end

                    -- print(string.format("Speed: %.1f, Threshold: %d, Seatbelt: %s", speedConverted, Config.stressConfig.drivingStress.speedThreshold, tostring(currentSeatbelt)))

                    -- Check if driving fast without seatbelt
                    if speedConverted > Config.stressConfig.drivingStress.speedThreshold and not currentSeatbelt then
                        local currentTime = GetGameTimer()
                        -- print(string.format("CONDITION MET! Speed %.1f > %d AND seatbelt=%s", speedConverted, Config.stressConfig.drivingStress.speedThreshold, tostring(currentSeatbelt)))
                        -- print(string.format("Time check: current=%d, last=%d, interval=%d", currentTime, lastStressCheck, Config.stressConfig.drivingStress.interval))

                        if currentTime - lastStressCheck >= Config.stressConfig.drivingStress.interval then
                            -- print("Driving fast without seatbelt - increasing stress by", Config.stressConfig.drivingStress.increase)
                            increaseStress(Config.stressConfig.drivingStress.increase)
                            lastStressCheck = currentTime
                        else
                            -- print("Conditions met but interval cooldown active")
                        end
                    end
                end
            end
        else
            -- print("Driving stress detection disabled or config missing")
        end

        Wait(Config.stressConfig and Config.stressConfig.drivingStress.interval or 2000)
    end
end)

--
-- HUD SPEEDOMETER
--

-- Function to check seatbelt state from qbx_seatbelt
local function getSeatbeltState()
    -- Try to get state from qbx_seatbelt export if available
    local success, result = pcall(function()
        return exports['qbx_seatbelt']:getSeatbeltState()
    end)

    if success and result ~= nil then
        return result
    end

    -- Try alternative export names
    success, result = pcall(function()
        return exports['qbx_seatbelt']:GetSeatbeltState()
    end)

    if success and result ~= nil then
        return result
    end

    -- Try getting from player metadata if available
    success, result = pcall(function()
        return LocalPlayer.state.seatbelt
    end)

    if success and result ~= nil then
        return result
    end

    -- Default to the current seatbelt variable
    return seatbelt
end

exports('setSeatBelt', function(toggle)
    seatbelt = toggle
end)

-- Debug command to test stress
RegisterCommand('teststress', function(source, args)
    local amount = tonumber(args[1]) or 10
    --print(string.format("Testing stress increase by %d", amount))
    --print("Current stress before:", stress)
    increaseStress(amount)
    --print("Current stress after:", stress)
end, false)

-- Command to toggle custom stress management
RegisterCommand('togglestress', function()
    customStressManagement = not customStressManagement
    --print("Custom stress management:", customStressManagement)
end, false)

-- Command to manually save stress
-- RegisterCommand('savestress', function()
--     saveStress(stress)
--     --print("Manually saved stress:", stress)
-- end, false)

-- -- Command to clear saved stress
-- RegisterCommand('clearstress', function()
--     DeleteResourceKvp('jordqn_hud_stress')
--     stress = 0
--     customStressManagement = false
--     --print("Cleared saved stress, reset to 0")
-- end, false)

-- -- Command to decrease stress
-- RegisterCommand('decreasestress', function(source, args)
--     local amount = tonumber(args[1]) or 10
--     local oldStress = stress
--     stress = math.max(0, stress - amount)
--     customStressManagement = true
--     LocalPlayer.state:set('stress', stress, true)
--     -- print(string.format("Stress decreased from %d to %d (-%d)", oldStress, stress, amount))
-- end, false)

CreateThread(function()
    while true do
        if Config.speedometer.enabled and hudVisible then
            if inVehicle then
                local vehicle = GetVehiclePedIsIn(playerPed, false)

                if DoesEntityExist(vehicle) then
                    local multipler = Config.useMiles and 2.236936 or 3.6
                    local maxSpeed = GetVehicleEstimatedMaxSpeed(vehicle) * multipler
                    local speed = GetEntitySpeed(vehicle) * multipler
                    local maxFuel = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume')
                    local fuel = GetVehicleFuelLevel(vehicle)
                    local hasMotor = true
                    local isElectric = false

                    if maxFuel < 5.0 then
                        hasMotor = false
                    end

                    if Config.LegacyFuel then
                        fuel = math.floor(exports['LegacyFuel']:GetFuel(vehicle))
                    end

                    local model = GetEntityModel(vehicle)

                    for _, v in pairs(Config.electricVehicles) do
                        if v == model then
                            isElectric = true
                            break
                        end
                    end

                    local _, _, highbeams = GetVehicleLightsState(vehicle)

                    -- Get current seatbelt state
                    local currentSeatbelt = getSeatbeltState()

                    SendNUIMessage({
                        component = 'speedometer',
                        framework = Config.framework,
                        seatbeltVisible = Config.enableSeatBelt,
                        fuelVisible = Config.enableFuel,
                        useMiles = Config.useMiles,
                        speed = speed,
                        maxspeed = maxSpeed,
                        fuel = fuel,
                        hasmotor = hasMotor,
                        iselectric = isElectric,
                        maxfuel = maxFuel,
                        highbeams = highbeams,
                        engine = GetIsVehicleEngineRunning(vehicle),
                        seatbelt = currentSeatbelt
                    })
                else
                    SendNUIMessage({
                        component = 'speedometer',
                        visible = false
                    })
                end
            else
                SendNUIMessage({
                    component = 'speedometer',
                    visible = false
                })
            end
        else
            SendNUIMessage({
                component = 'speedometer',
                visible = false
            })
        end

        Wait(Config.globalUpdateTime)
    end
end)

--
-- BANK BALANCE & CASH
--

-- CreateThread(function()
--     while true do
--         if ((Config.enableBankBalance and Config.bankBalance.enabled) or (Config.enableCashBalance and Config.cashBalance.enabled)) and hudVisible then
--             local bankBalance = 0
--             local cashBalance = 0

--             -- Get bank and cash balance based on framework
--             if Config.framework == 'qbcore' then
--                 local success, bankResult, cashResult = pcall(function()
--                     if QBCore and QBCore.Functions then
--                         local PlayerData = QBCore.Functions.GetPlayerData()
--                         if PlayerData and PlayerData.money then
--                             return PlayerData.money.bank or 0, PlayerData.money.cash or 0
--                         end
--                     end
--                     return 0, 0
--                 end)
--                 if success then
--                     bankBalance = bankResult
--                     cashBalance = cashResult
--                 end
--             elseif Config.framework == 'esx' then
--                 -- ESX bank and cash balance
--                 local success, bankResult, cashResult = pcall(function()
--                     if ESX and ESX.GetPlayerData then
--                         local playerData = ESX.GetPlayerData()
--                         if playerData and playerData.accounts then
--                             local bank = 0
--                             local cash = 0
--                             for _, account in pairs(playerData.accounts) do
--                                 if account.name == 'bank' then
--                                     bank = account.money or 0
--                                 elseif account.name == 'money' then
--                                     cash = account.money or 0
--                                 end
--                             end
--                             return bank, cash
--                         end
--                     end
--                     return 0, 0
--                 end)
--                 if success then
--                     bankBalance = bankResult
--                     cashBalance = cashResult
--                 end
--             else
--                 -- Standalone - you can customize this
--                 bankBalance = 5000 -- Default value for standalone
--                 cashBalance = 1500 -- Default value for standalone
--             end

--             -- Send bank balance
--             if Config.enableBankBalance and Config.bankBalance.enabled then
--                 SendNUIMessage({
--                     component = 'bank',
--                     balance = bankBalance,
--                     visible = true
--                 })
--             else
--                 SendNUIMessage({
--                     component = 'bank',
--                     visible = false
--                 })
--             end

--             -- Send cash balance
--             if Config.enableCashBalance and Config.cashBalance.enabled then
--                 SendNUIMessage({
--                     component = 'cash',
--                     balance = cashBalance,
--                     visible = true
--                 })
--             else
--                 SendNUIMessage({
--                     component = 'cash',
--                     visible = false
--                 })
--             end
--         else
--             SendNUIMessage({
--                 component = 'bank',
--                 visible = false
--             })
--             SendNUIMessage({
--                 component = 'cash',
--                 visible = false
--             })
--         end

--         Wait(math.max(Config.bankBalance.updateTime, Config.cashBalance.updateTime) * 1000)
--     end
-- end)

-- JOB DISPLAY
CreateThread(function()
    while true do
        if Config.enableJobDisplay and Config.jobDisplay.enabled and hudVisible then
            local jobName = "Unemployed"
            local jobGrade = "Citizen"

            -- Get job data based on framework
            if Config.framework == 'qbcore' then
                local success, jobResult, gradeResult = pcall(function()
                    if QBCore and QBCore.Functions.GetPlayerData then
                        local PlayerData = QBCore.Functions.GetPlayerData()
                        if PlayerData.job then
                            local jobLabel = PlayerData.job.label or PlayerData.job.name or "Unemployed"
                            local gradeLabel = "Citizen"

                            -- Check if player is on duty
                            if PlayerData.job.onduty ~= nil then
                                if PlayerData.job.onduty == false then
                                    gradeLabel = "Off Duty"
                                elseif PlayerData.job.grade and PlayerData.job.grade.name then
                                    gradeLabel = PlayerData.job.grade.name
                                end
                            elseif PlayerData.job.grade and PlayerData.job.grade.name then
                                gradeLabel = PlayerData.job.grade.name
                            end

                            return jobLabel, gradeLabel
                        end
                    end
                    return "Unemployed", "Citizen"
                end)

                if success then
                    jobName = jobResult
                    jobGrade = gradeResult
                end
            elseif Config.framework == 'esx' then
                -- ESX job data
                local success, jobResult, gradeResult = pcall(function()
                    if ESX and ESX.GetPlayerData then
                        local PlayerData = ESX.GetPlayerData()
                        if PlayerData.job then
                            local jobLabel = PlayerData.job.label or "Unemployed"
                            local gradeLabel = "Citizen"

                            -- Check if player is on duty (ESX may use different property names)
                            if PlayerData.job.onduty ~= nil then
                                if PlayerData.job.onduty == false then
                                    gradeLabel = "Off Duty"
                                elseif PlayerData.job.grade_label then
                                    gradeLabel = PlayerData.job.grade_label
                                end
                            elseif PlayerData.job.grade_label then
                                gradeLabel = PlayerData.job.grade_label
                            end

                            return jobLabel, gradeLabel
                        end
                    end
                    return "Unemployed", "Citizen"
                end)

                if success then
                    jobName = jobResult
                    jobGrade = gradeResult
                end
            else
                -- Standalone mode
                jobName = "Police Officer" -- Example job for standalone
                jobGrade = "Officer"
            end

            -- Send job data to UI
            SendNUIMessage({
                component = 'job',
                visible = true,
                jobName = jobName,
                jobGrade = jobGrade
            })
        else
            SendNUIMessage({
                component = 'job',
                visible = false
            })
        end

        Wait(Config.jobDisplay.updateTime * 1000)
    end
end)

-- PLAYER ID DISPLAY
CreateThread(function()
    while true do
        if Config.enablePlayerID and Config.playerID.enabled and hudVisible then
            local playerId = GetPlayerServerId(PlayerId())

            -- Send player ID data to UI
            SendNUIMessage({
                component = 'playerId',
                visible = true,
                playerId = playerId
            })
        else
            SendNUIMessage({
                component = 'playerId',
                visible = false
            })
        end

        Wait(Config.playerID.updateTime * 1000)
    end
end)

--
-- CONFIGURATION
--

CreateThread(function()
    SendNUIMessage({
        component = 'configuration',
        locationleft = Config.location.left,
        locationbottom = Config.location.bottom,
        statusright = Config.status.right,
        statusbottom = Config.status.bottom,
        speedometerbottom = Config.speedometer.bottom,
        banktop = Config.bankBalance.position.top,
        bankright = Config.bankBalance.position.right,
        cashtop = Config.cashBalance.position.top,
        cashright = Config.cashBalance.position.right,
        jobtop = Config.jobDisplay.position.top,
        jobright = Config.jobDisplay.position.right,
        playeridright = Config.playerID.position.right,
        playeridbottom = Config.playerID.position.bottom
    })
end)
