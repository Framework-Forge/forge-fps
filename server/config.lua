-- SERVER ONLY. The administrative panel uses the same inherited ACE as Forge Pause.
FpsServerConfig = {
    Ace = 'forge.fps.admin',
    InheritAce = 'forge-core.admin',
    PolicyFile = 'admin-policy.json',
    -- Rules set here are defaults; a published policy takes precedence.
    Rules = {
        -- pedDensity={allowed=true,min=0.5},
        -- vehicleDensity={allowed=true,min=0.5},
        -- lodScale={allowed=true,min=0.7},
    },
    -- Natives without getters cannot restore an unknown prior state.
    -- Enable only if no other resource owns the parameter. Baseline is explicit,
    -- not a claim that we captured the player's original GTA setting.
    Exclusive = {
        -- New controls stay disabled until the responsible admin declares ownership.
        distantCars = {
            enabled = true,
            baseline = true
        },
        randomCops = {
            enabled = true,
            baseline = true
        },
        garbageTrucks = {
            enabled = true,
            baseline = true
        },
        randomBoats = {
            enabled = true,
            baseline = true
        },
        randomTrains = {
            enabled = true,
            baseline = true
        },
        lowPriorityVehGens = {
            enabled = true,
            baseline = true
        },
        artificialLights = {
            enabled = true,
            baseline = true
        },
        artificialLightsVeh = {
            enabled = true,
            baseline = true
        },
        vehicleDistantLights = {
            enabled = true,
            baseline = true
        },
        distantSirens = {
            enabled = true,
            baseline = true
        },
        vehicleTrails = {
            enabled = true,
            baseline = true
        },
        footstepTracks = {
            enabled = true,
            baseline = true
        },
        motionBlur = {
            enabled = true,
            baseline = true
        },
        filmGrain = {
            enabled = true,
            baseline = 1.0
        },
        shadowMode = {
            enabled = true,
            baseline = 'CSM_ST_SOFT16'
        },
        reducePedModels = {
            enabled = true,
            baseline = true
        },
        reduceVehicleModels = {
            enabled = true,
            baseline = true
        },
        pedPopulationBudget = {
            enabled = true,
            baseline = 3
        },
        vehiclePopulationBudget = {
            enabled = true,
            baseline = 3
        },
        shadowDistance = {
            enabled = true,
            baseline = 1.0
        },
    },
}
