RegisterNetEvent('hud:server:GainStress', function(value)
    local state = Player(source).state
    state:set('stress', math.min(100, (state.stress or 0) + value), true)
end)
