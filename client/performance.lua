FpsPerformance = {}
local active, owned, status = {}, {}, {}
local index = {}; for _, item in ipairs(FpsCatalog) do index[item.key] = item end
local natives = {
    lodScale = 'OverrideLodscaleThisFrame',
    pedDensity = 'SetPedDensityMultiplierThisFrame',
    vehicleDensity = 'SetVehicleDensityMultiplierThisFrame',
    parkedDensity = 'SetParkedVehicleDensityMultiplierThisFrame',
    randomVehDensity = 'SetRandomVehicleDensityMultiplierThisFrame',
    scenarioInside = 'SetScenarioPedDensityMultiplierThisFrame',
    scenarioOutside = 'SetScenarioPedDensityMultiplierThisFrame',
    hideDecals = 'SetDisableDecalRenderingThisFrame',
    reducePedModels = 'SetReducePedModelBudget',
    reduceVehicleModels = 'SetReduceVehicleModelBudget',
    pedPopulationBudget = 'SetPedPopulationBudget',
    vehiclePopulationBudget = 'SetVehiclePopulationBudget',
    shadowDistance = 'CascadeShadowsSetCascadeBoundsScale',
    ambientVehRange='SetAmbientVehicleRangeMultiplierThisFrame',ambientPedRange='SetAmbientPedRangeMultiplierThisFrame',
    distantCars='SetDistantCarsEnabled',randomCops='SetCreateRandomCops',
    garbageTrucks='SetGarbageTrucks',randomBoats='SetRandomBoats',randomTrains='SetRandomTrains',
    lowPriorityVehGens='SetAllLowPriorityVehicleGeneratorsActive',
    artificialLights='SetArtificialLightsState',artificialLightsVeh='SetArtificialLightsStateAffectsVehicles',
    vehicleDistantLights='DisableVehicleDistantlights',distantSirens='DistantCopCarSirens',
    vehicleTrails='SetForceVehicleTrails',footstepTracks='SetForcePedFootstepsTracks',
    motionBlur='SetPedMotionBlur',filmGrain='SetNoisinessoveride',shadowMode='CascadeShadowsSetShadowSampleType',
}
local motionPed
local guard=function()return true end
function FpsPerformance.setGuard(fn)guard=fn end
local function write(key, value)
    if key == 'pedPopulationBudget' or key == 'vehiclePopulationBudget' then value = math.floor(value) end
    if index[key].type == 'range' and key ~= 'pedPopulationBudget' and key ~= 'vehiclePopulationBudget' then value =
        value + 0.0 end
    local fn = _G[natives[key]]; if type(fn) ~= 'function' then return false end
    if key=='motionBlur'then return pcall(fn,motionPed or PlayerPedId(),value)end
    if key=='artificialLights' or key=='vehicleDistantLights'then value=not value end
    if key=='randomCops'then
        if not SetCreateRandomCopsOnScenarios or not SetCreateRandomCopsNotOnScenarios then return false end
        local a=pcall(fn,value);local b=pcall(SetCreateRandomCopsOnScenarios,value);local c=pcall(SetCreateRandomCopsNotOnScenarios,value)
        return a and b and c
    end
    local ok = pcall(fn, value); return ok
end
function FpsPerformance.restore()
    if FpsExtras then FpsExtras.restore()end
    active = {}
    for key, entry in pairs(owned) do write(key, entry.baseline) end
    owned = {}
    motionPed=nil
end

function FpsPerformance.configure(settings,explicit)
    if FpsExtras then FpsExtras.configure(settings,explicit)end
    active = {}; status = {}
    if motionPed and motionPed~=PlayerPedId()then
        if owned.motionBlur and (not DoesEntityExist or DoesEntityExist(motionPed))then write('motionBlur',owned.motionBlur.baseline)end
        owned.motionBlur=nil;motionPed=nil
    end
    for key, name in pairs(natives) do
        local item = index[key]; local allowed = FpsSettings.allowed(item)
        local present = type(_G[name]) == 'function'
        if key=='randomCops'then present=present and type(SetCreateRandomCopsOnScenarios)=='function' and type(SetCreateRandomCopsNotOnScenarios)=='function'end
        status[key] = { available = allowed and present, reason = not allowed and
        (FpsPolicy.rule(key).reason or 'Bloqueado pela política do servidor.') or
        not present and 'Native indisponível nesta instalação.' or '' }
        local neutral = FpsSettings.neutral(item)
        local value = settings.preset ~= 'original' and allowed and settings[key]
        if value == nil or not allowed or settings.preset == 'original' then value = neutral end
        if item.exclusive then
            local entry = owned[key]
            if value ~= neutral and allowed and present and FpsPolicy.exclusive[key] then
                local baseline = FpsPolicy.baselines[key]
                if entry and entry.baseline ~= baseline then
                    write(key, entry.baseline); owned[key] = nil; entry = nil
                end
                entry = entry or { baseline = baseline }
                if key=='motionBlur'then motionPed=PlayerPedId()end
                if entry.last ~= value then
                    if write(key, value) then
                        entry.last = value; owned[key] = entry
                    else
                        -- Compound controls may have applied an earlier native.
                        write(key,entry.baseline);status[key] = { available = false, reason = 'Não foi possível aplicar o parâmetro.' }
                    end
                end
            elseif entry then
                write(key, entry.baseline); owned[key] = nil
            end
        elseif value ~= item.default and allowed and present then
            active[key] = value
        end
    end
    for _,key in ipairs({'blockPedSpawns','blockParkedSpawns'})do
        local allowed=FpsSettings.allowed(index[key]);status[key]={available=allowed,reason=allowed and '' or 'Bloqueado pela política do servidor.'}
        if settings.preset~='original' and allowed and settings[key]then active[key]=true end
    end
end

function FpsPerformance.needed()
    -- The population event is not a per-frame task.
    for key in pairs(active) do if key ~= 'blockPedSpawns' then return true end end
    return false
end

function FpsPerformance.tick()
    for key, value in pairs(active) do
        if key ~= 'scenarioInside' and key ~= 'scenarioOutside' and key~='blockPedSpawns' and key~='blockParkedSpawns' then
            local ok
            if key == 'hideDecals' then ok = pcall(_G[natives[key]]) else ok = write(key, value) end
            if not ok then
                active[key] = nil; status[key] = { available = false, reason = 'Falha na native; parâmetro suspenso.' }
            end
        end
    end
    if active.blockParkedSpawns then
        local ok=pcall(SetParkedVehicleDensityMultiplierThisFrame,0.0)
        if not ok then active.blockParkedSpawns=nil;status.blockParkedSpawns={available=false,reason='Native indisponível nesta instalação.'}end
    end
    if active.scenarioInside or active.scenarioOutside then
        -- Native order is interior, exterior; both are floats, even at 0 or 1.
        local ok = pcall(SetScenarioPedDensityMultiplierThisFrame, (active.scenarioInside or 1.0) + 0.0,
            (active.scenarioOutside or 1.0) + 0.0)
        if not ok then
            active.scenarioInside, active.scenarioOutside = nil, nil
            status.scenarioInside = { available = false, reason = 'Falha na native; parâmetro suspenso.' }; status.scenarioOutside =
            status.scenarioInside
        end
    end
end

AddEventHandler('populationPedCreating',function()
    if active.blockPedSpawns and guard() then CancelEvent()end
end)

function FpsPerformance.status()
    local result=FpsSettings.copy(status)
    if FpsExtras then for key,value in pairs(FpsExtras.status())do result[key]=value end end
    return result
end
