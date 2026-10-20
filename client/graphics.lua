FpsGraphics = {}
local groups = {
    bloom = { 'bloom.blurblendmult.small', 'bloom.blurblendmult.med', 'bloom.blurblendmult.large' },
    cinematicBlur = { 'bokeh.sizeMultiplier' },
    bokehAlpha = { 'bokeh.globalAlpha' },
    renderLodLights = { 'lodlight.small.range', 'lodlight.medium.range', 'lodlight.large.range', 'lodlight.small.fade', 'lodlight.medium.fade', 'lodlight.large.fade' },
    renderCoronas = { 'misc.coronas.sizeScaleGlobal', 'misc.coronas.intensityScaleGlobal', 'misc.coronas.sizeScaleWater', 'misc.coronas.intensityScaleWater' },
    renderDistantLights = { 'distantlights.size', 'distantlights.sizeMin', 'distantlights.sizeUpscale', 'distantlights.carlight.farFade', 'distantlights.carlight.HDRIntensity', 'distantlights.streetlight.HDRIntensity' },
    renderPuddles = { 'puddles.range', 'puddles.scale', 'puddles.strength', 'puddles.depth' },
    renderVehicleLights = { 'car.headlights.volume.intensityscale', 'car.headlights.volume.outerintensity', 'car.headlights.volume.sizescale', 'vehicle.lights.fadeDistance.main', 'vehicle.lights.fadeDistance.secondary', 'vehicle.lights.fadeDistance.neon', 'vehicle.lights.fadeDistance.sirens' },
}
local channels = { 'bloomSmall', 'bloomMedium', 'bloomLarge' }
local owned, blocked, status = {}, {}, {}
local function read(key)
    if not GetVisualSettingFloat or not SetVisualSettingFloat then return end
    local ok, n = pcall(GetVisualSettingFloat, key)
    if ok and type(n) == 'number' and n == n and n >= 0 and n < 100000 then return n + 0.0 end
end
local function equal(a, b) return a and b and math.abs(a - b) <= math.max(0.00001, math.abs(b) * 0.00001) end
function FpsGraphics.restore()
    for key, entry in pairs(owned) do
        local now = read(key)
        -- Never undo a more recent change owned by another resource.
        if equal(now, entry.last) then pcall(SetVisualSettingFloat, key, entry.original + 0.0) end
    end
    owned = {}
end

function FpsGraphics.apply(settings, explicit)
    if explicit then blocked = {} end
    status = {}
    for group, keys in pairs(groups) do
        local policy = group == 'bokehAlpha' and 'cinematicBlur' or group
        local allowed = FpsSettings.allowed({ key = group, policy = policy })
        local overallAllowed = allowed
        if group == 'bloom' then for _, channel in ipairs(channels) do if FpsSettings.allowed({ key = channel, policy = 'bloom' }) then allowed = true end end end
        local scale = allowed and (settings[group] or 1.0) or 1.0
        if settings.preset == 'original' then scale = 1.0 end
        status[group] = { available = overallAllowed == true, reason = overallAllowed and '' or
        'Bloqueado pela política do servidor.' }
        local unavailable, observed = false, {}
        if allowed then
            for _, key in ipairs(keys) do
                observed[key] = read(key)
                if not observed[key] then unavailable = true end
            end
        end
        if unavailable then
            status[group] = { available = false, reason = 'Efeito indisponível nesta instalação; grupo não aplicado.' }; scale = 1.0
        end
        for index, key in ipairs(keys) do
            local keyScale = scale
            if group == 'bloom' and allowed and not unavailable and settings.preset ~= 'original' then
                local channel = channels[index]
                local channelAllowed = FpsSettings.allowed({ key = channel, policy = 'bloom' })
                local floor = overallAllowed and FpsSettings.minimum({ key = 'bloom', policy = 'bloom' }) or 0
                if channelAllowed then floor = math.max(floor, FpsSettings.minimum({ key = channel, policy = 'bloom' })) end
                keyScale = math.max(floor,
                    (overallAllowed and scale or 1.0) * (channelAllowed and settings[channel] or 1.0))
            end
            local entry = owned[key]
            local now = allowed and observed[key] or (entry and read(key) or nil)
            if entry and not equal(now, entry.last) then
                owned[key] = nil; entry = nil; blocked[key] = true
            end
            if blocked[key] then
                status[group] = { available = false, reason = 'Outro recurso alterou este efeito; ajuste suspenso.' }
            elseif now and keyScale < 1.0 then
                entry = entry or { original = now, last = now }
                local target = entry.original * keyScale + 0.0
                if not equal(now, target) then
                    local ok = pcall(SetVisualSettingFloat, key, target)
                    if ok then
                        entry.last = target; owned[key] = entry
                    else
                        status[group] = { available = false, reason = 'Não foi possível aplicar este efeito.' }
                    end
                else
                    owned[key] = entry
                end
            elseif now and entry then
                pcall(SetVisualSettingFloat, key, entry.original + 0.0); owned[key] = nil
            end
        end
        if group == 'bloom' then
            for i, channel in ipairs(channels) do
                local permitted = FpsSettings.allowed({ key = channel, policy = 'bloom' })
                status[channel] = {
                    available = permitted and not unavailable and not blocked[keys[i]],
                    reason = not permitted and 'Bloqueado pela política do servidor.' or
                    unavailable and 'Efeito indisponível nesta instalação.' or
                    blocked[keys[i]] and 'Outro recurso alterou este efeito; ajuste suspenso.' or ''
                }
            end
        end
    end
end

function FpsGraphics.status() return FpsSettings.copy(status) end
