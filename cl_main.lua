local playerId, playerPed, inVehicle, hudVisible, seatbelt, weapon, playerloaded
local job = {}
local speedfactor = Config.useMiles and 2.236936 or 3.6

exports('hudVisibility', function(toggle)
    hudVisible = toggle
    ToggleHud(toggle)
end)
--
-- HUD COMPONENTS
--
DisplayRadar(false)
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

local bypass = false
local cinematic

RegisterCommand('minimap', function()
    bypass = not bypass
    DisplayRadar(bypass)
    SetResourceKvpInt("toggle_minimap", bypass and 1 or 0)
end, false)

RegisterCommand('cinematic', function()
    cinematic = not cinematic
    hudVisible = not cinematic
    ToggleHud(not cinematic)
end, false)

-- Need to set command
CreateThread(function()
    bypass = GetResourceKvpInt("toggle_minimap") == 1
    DisplayRadar(bypass)
end)

--
-- HUD LOCATION
--

local activeCoords = vec2(0.0, 0.0)
local postalText = 'CP 0000'
local postals = {}
local zones = {}

CreateThread(function()
    local postalsJson = LoadResourceFile(GetCurrentResourceName(), 'zips.json')
    postalsJson = json.decode(postalsJson)

    for i, postal in ipairs(postalsJson) do
        postals[i] = { vec2(postal.x, postal.y), code = postal.code }
    end

    local zonesJson = LoadResourceFile(GetCurrentResourceName(), 'zones.json')
    zonesJson = json.decode(zonesJson)

    for _, zone in pairs(zonesJson) do
        zones[zone.zone] = zone.name
    end
end)

local directions = { "N", "NE", "E", "SE", "S", "SW", "W", "NW", "N" }

local function getCardinalDirection(heading)
    local index = math.floor(((heading % 360) + 22.5) / 45) + 1
    return directions[index]
end


--
-- HUD STATUS
--

local hunger = 100
local thirst = 100
local stress = 0
local voice_type = 'mic_mute.png'
local voice_talking = false
local voice_radio = false
local lastShootTime = 0
local lastStressCheck = 0

AddStateBagChangeHandler('hunger', ('player:%s'):format(cache.serverId), function(_, _, value)
    hunger = value
end)

AddStateBagChangeHandler('thirst', ('player:%s'):format(cache.serverId), function(_, _, value)
    thirst = value
end)

AddStateBagChangeHandler('stress', ('player:%s'):format(cache.serverId), function(_, _, value)
    stress = value
    TriggerEvent('hud:stressChanged', value)
end)



-- Function to safely increase stress
local function increaseStress(amount)
    if not Config.stressConfig or not Config.stressConfig.enabled then
        return
    end
    local newStress = stress + amount
    if newStress > Config.stressConfig.maxStress then
        newStress = Config.stressConfig.maxStress
    end
    LocalPlayer.state:set('stress', newStress, true)
end

AddEventHandler("pma-voice:setTalkingMode", function(val)
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

AddEventHandler("pma-voice:radioActive", function(radioTalking)
    voice_radio = radioTalking
end)

-- Shooting stress detection
local function holdingWeaponLoop()
    while weapon do
        if Config.stressConfig and Config.stressConfig.enabled and Config.stressConfig.shootingStress.enabled then
            local isShooting = IsPedShooting(playerPed)
            if isShooting then
                local currentTime = GetGameTimer()
                if currentTime - lastShootTime >= Config.stressConfig.shootingStress.cooldown then
                    increaseStress(Config.stressConfig.shootingStress.increase)
                    lastShootTime = currentTime
                end
            end
        end
        Wait(100)
    end
end

-- CONFIGURATION
--
function ToggleHud(bool)
    SendNUIMessage({
        component = 'playerId',
        visible = bool,
        playerId = bool and cache.serverId
    })

    SendNUIMessage({
        component = 'job',
        visible = bool,
        jobName = bool and job.label,
        jobGrade = bool and job.grade.name .. (job.onduty and '' or ' (Off Duty)')
    })
end

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

function Init()
    playerloaded = true
    job = QBX.PlayerData.job
    ToggleHud(true)
    CreateThread(function()
        SendNUIMessage({
            component = 'position',
            visible = false
        })
        while true do
            if LocalPlayer.state.isLoggedIn then
                if inVehicle and Config.location.enabled and hudVisible then
                    local playerCoords = GetEntityCoords(cache.ped)
                    local heading = GetEntityHeading(cache.ped)
                    local zone = GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)
                    local streetname, _ = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
                    local streetnameText = GetStreetNameFromHashKey(streetname)
                    local distance = #(playerCoords.xy - activeCoords)
                    local distanceText = string.format('%sm', math.floor(distance))
                    local zoneText = streetnameText
                    if zones[string.upper(zone)] then
                        zoneText = zones[string.upper(zone)]
                    end
                    local nearestIndex, nearestDist
                    for i = 1, #postals do
                        local dist = #(playerCoords.xy - postals[i][1])

                        if not nearestDist or dist < nearestDist then
                            nearestIndex = i
                            nearestDist = dist
                            activeCoords = postals[i][1]
                        end
                    end
                    local code = postals[nearestIndex].code
                    postalText = string.format('CP %s', code)
                    SendNUIMessage({
                        component = 'position',
                        heading = heading,
                        postal = postalText,
                        direction = getCardinalDirection(heading),
                        distance = distanceText,
                        street = streetnameText,
                        zone = zoneText
                    })
                else
                    SendNUIMessage({
                        component = 'position',
                        visible = false
                    })
                end
            end
            Wait(Config.globalUpdateTime)
        end
    end)
    local visiblestate = false
    CreateThread(function()
        while true do
            Wait(Config.globalUpdateTime)
            if hudVisible then
                local voice = voice_type
                if voice_radio then
                    voice = 'mic_radio.png'
                end

                if stress < 0 then stress = 0 end
                if stress > 100 then stress = 100 end
                voice_talking = NetworkIsPlayerTalking(playerId) == 1
                visiblestate = true
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
                    health = GetEntityHealth(cache.ped),
                    maxhealth = GetEntityMaxHealth(cache.ped),
                    armor = GetPedArmour(cache.ped),
                    hunger = hunger,
                    thirst = thirst,
                    stress = stress,
                    oxygen = GetPlayerUnderwaterTimeRemaining(playerId)
                })
            else
                if visiblestate then
                    SendNUIMessage({
                        component = 'status',
                        visible = false
                    })
                    visiblestate = false
                end
            end
        end
    end)

    --
    -- HUD SPEEDOMETER
    local vehiclehud = false
    CreateThread(function()
        while true do
            if Config.speedometer.enabled and playerloaded and inVehicle and hudVisible then
                local multipler = Config.useMiles and 2.236936 or 3.6
                local maxSpeed = GetVehicleEstimatedMaxSpeed(inVehicle) * multipler
                local speed = GetEntitySpeed(inVehicle) * multipler
                local maxFuel = GetVehicleHandlingFloat(inVehicle, 'CHandlingData', 'fPetrolTankVolume')
                local fuel = GetVehicleFuelLevel(inVehicle)
                local hasMotor = true
                local isElectric = false

                if maxFuel < 5.0 then
                    hasMotor = false
                end

                if Config.LegacyFuel then
                    fuel = math.floor(exports['LegacyFuel']:GetFuel(inVehicle))
                end

                local model = GetEntityModel(inVehicle)
                isElectric = Config.electricVehicles[model]
                local _, _, highbeams = GetVehicleLightsState(inVehicle)
                vehiclehud = true
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
                    engine = GetIsVehicleEngineRunning(inVehicle),
                    seatbelt = seatbelt
                })
            else
                if vehiclehud then
                    vehiclehud = false
                    SendNUIMessage({
                        component = 'speedometer',
                        visible = false
                    })
                end
            end

            Wait(Config.globalUpdateTime)
        end
    end)
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

    -- Driving stress detection (speed without seatbelt)
    CreateThread(function()
        while true do
            if Config.stressConfig and Config.stressConfig.enabled and Config.stressConfig.drivingStress.enabled then
                if inVehicle then
                    if cache.seat == -1 then
                        local speed = GetEntitySpeed(inVehicle)
                        local speedConverted = speed * speedfactor
                        if speedConverted > Config.stressConfig.drivingStress.speedThreshold and not seatbelt then
                            local currentTime = GetGameTimer()

                            if currentTime - lastStressCheck >= Config.stressConfig.drivingStress.interval then
                                increaseStress(Config.stressConfig.drivingStress.increase)
                                lastStressCheck = currentTime
                            end
                        end
                    end
                end
            end
            Wait(Config.stressConfig and Config.stressConfig.drivingStress.interval or 2000)
        end
    end)


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
end

--cache management

lib.onCache('vehicle', function(value)
    inVehicle = value
    if value then
        DisplayRadar(true)
    else
        DisplayRadar(bypass)
        seatbelt = false
    end
end)
lib.onCache('ped', function(value)
    playerPed = value
end)
lib.onCache('playerId', function(value)
    playerId = value
end)
lib.onCache('weapon', function(value)
    weapon = value
    if weapon then
        holdingWeaponLoop()
    end
end)

--Handlers
AddEventHandler('QBCore:Client:OnPlayerLoaded', Init)

AddEventHandler('qbx_seatbelt:client:togglebelt', function(bool)
    seatbelt = bool
end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    job = job
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(onDuty)
    job.onduty = onDuty
end)

CreateThread(function()
    if LocalPlayer.state.isLoggedIn then
        Init()
    end
end)
