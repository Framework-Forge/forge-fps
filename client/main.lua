local settings = FpsSettings.copy(FpsSettings.defaults)
local opened, ready, stopped = false, false, false
local session, generation = 0, 0
local suspended, external = {}, {}
local effective, autoLevel, lastAuto, lowTicks, highTicks = nil, 0, 0, 0, 0
local benchmark, lastResult
local alertTicks, alertVisible = 0, false
local loadedPreferences, pendingPolicy = {}, {}
local rpcId, locale = 0, FpsLocale.resolve(true)
local function persist(value)
    local ok, encoded = pcall(json.encode, { version = 1, settings = value })
    if not ok then return false end
    return pcall(SetResourceKvp, Config.StorageKey, encoded)
end
local function shouldSuspend()
    local camera = GetRenderingCam and GetRenderingCam()
    return next(external) ~= nil or IsEntityDead(PlayerPedId()) or IsPauseMenuActive() or (IsNuiFocused() and not opened)
        or (camera and camera ~= -1 and camera ~= 0)
end
local function apply(explicit)
    if next(suspended) or shouldSuspend() then
        FpsAutomation.effective(settings,true,opened,benchmark~=nil)
        FpsGraphics.restore(); FpsPerformance.restore(); return
    end
    effective = FpsAutomation.effective(settings,false,opened,benchmark~=nil)
    if settings.automatic and settings.preset ~= 'original' and autoLevel > 0 then
        effective.bloom = math.max(FpsPolicy.minimum('bloom'), effective.bloom - autoLevel * .05)
    end
    FpsGraphics.apply(effective, explicit)
    FpsPerformance.configure(effective,explicit)
end
FpsPerformance.setGuard(function()return not shouldSuspend() and (not benchmark or benchmark.active==true)end)
local function snapshot()
    local w, h = GetActiveScreenResolution()
    local graphics = FpsGraphics.status(); for key, value in pairs(FpsPerformance.status()) do graphics[key] = value end
    return {
        settings = FpsSettings.copy(settings),
        presets = FpsSettings.copy(FpsSettings.presets),
        metrics = FpsMetrics.snapshot(GetGameTimer()),
        graphics = graphics,
        suspended = next(suspended) ~= nil or shouldSuspend(),
        effective = FpsSettings.copy(effective or settings),
        result = lastResult,
        resolution = { width = w, height = h },
        limits = { bloom = FpsPolicy.minimum('bloom'), cinematicBlur = FpsPolicy.minimum('cinematicBlur') },
        policy = { rules = FpsSettings.copy(FpsPolicy.current or FpsPolicy.defaults()), revision = FpsPolicy.revision, admin = FpsPolicy.admin, exclusive = FpsSettings.copy(FpsPolicy.exclusive), ready = FpsPolicy.ready },
        catalog = FpsSettings.catalog(),
        benchmarkSeconds = Config.BenchmarkSeconds,
        diagnostics=FpsDiagnostics.snapshot(settings,opened),
        locale = locale,
        version = '1.3.1',
        session = session
    }
end
local function close()
    if not opened then return end
    opened = false; session = session + 1; SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close', hud = settings.hud, position = settings.hudPosition, settings = settings, locale = locale })
end
local function cancelBenchmark(message)
    if not benchmark then return end
    generation = generation + 1; benchmark = nil; FpsMetrics.endCapture(); FpsGraphics.restore(); FpsPerformance.restore(); apply(true)
    SendNUIMessage({ action = 'testEnd', message = message or 'Comparação cancelada. Configuração anterior restaurada.' })
end
local function open()
    if benchmark then cancelBenchmark() end
    if opened then
        close(); return
    end
    if not ready or IsNuiFocused() or IsPauseMenuActive() or IsEntityDead(PlayerPedId()) then return end
    locale = FpsLocale.resolve(true)
    TriggerServerEvent('forge-fps:policy:request')
    session = session + 1; opened = true; FpsMetrics.reset(); SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', payload = snapshot() })
end
local function validSession(data)
    return opened and type(data) == 'table' and data.session == session and not benchmark
end
local function commit(value)
    local valid, reason = FpsSettings.validate(value)
    if not valid then return { ok = false, message = reason } end
    if not persist(valid) then return { ok = false, message = 'Não foi possível salvar neste computador.' } end
    settings = valid; loadedPreferences = {}; autoLevel, lowTicks, highTicks = 0, 0, 0; apply(true); FpsMetrics.reset()
    SendNUIMessage({ action = 'hud', visible = settings.hud, position = settings.hudPosition, settings = settings })
    return { ok = true, payload = snapshot(), message = 'Preferências salvas neste computador.' }
end
RegisterNUICallback('ready', function(_, cb)
    ready = true
    if opened then
        SendNUIMessage({ action = 'open', payload = snapshot() })
    else
        SendNUIMessage({ action = 'close', hud = settings.hud, position = settings.hudPosition, settings = settings, locale = locale })
    end
    cb({ ok = true, payload = snapshot() })
end)
RegisterNUICallback('close', function(_, cb)
    cancelBenchmark(); close(); cb({ ok = true })
end)
RegisterNUICallback('save', function(data, cb)
    if not validSession(data) then
        cb({ ok = false, message = 'Sessão encerrada. Abra o painel novamente.' }); return
    end
    cb(commit(data.settings))
end)
RegisterNUICallback('reset', function(data, cb)
    if not validSession(data) then
        cb({ ok = false, message = 'Sessão encerrada.' }); return
    end
    cb(commit(FpsSettings.defaults))
end)
RegisterNUICallback('preset', function(data, cb)
    if not validSession(data) then
        cb({ ok = false, message = 'Sessão encerrada.' }); return
    end
    local value, reason = FpsSettings.preset(data.id, settings)
    cb(value and commit(value) or { ok = false, message = reason })
end)
RegisterNetEvent('forge-fps:policy:updated', function(payload)
    local wasReady, oldRevision, oldAdmin = FpsPolicy.ready, FpsPolicy.revision, FpsPolicy.admin
    if not FpsPolicy.receive(payload) then return end
    if wasReady and oldRevision == FpsPolicy.revision and oldAdmin == FpsPolicy.admin then return end
    cancelBenchmark('Política administrativa mudou. Comparação cancelada.')
    FpsGraphics.restore(); FpsPerformance.restore()
    local candidate = next(loadedPreferences) and loadedPreferences or settings
    settings = FpsSettings.validate(candidate, true) or FpsSettings.copy(FpsSettings.defaults)
    if next(loadedPreferences) and settings.preset ~= 'custom' then
        -- Stored named presets follow the revised recipe; custom preferences are
        -- preserved (apart from the mandatory LOD floor and automatic language).
        settings = FpsSettings.preset(settings.preset, settings) or settings
    end
    loadedPreferences = {}; autoLevel, lowTicks, highTicks = 0, 0, 0; apply(true)
    SendNUIMessage({ action = 'policy', payload = snapshot(), message =
    'Política administrativa sincronizada. Ajustes revogados foram suspensos.' })
end)
RegisterNetEvent('forge-fps:policy:reply', function(id, response)
    if type(response) ~= 'table' then return end
    local callback = pendingPolicy[id]; if not callback then return end
    pendingPolicy[id] = nil
    if response.policy and FpsPolicy.receive(response.policy) then
        settings = FpsSettings.validate(settings, true) or FpsSettings.copy(FpsSettings.defaults); apply(true)
    end
    callback({ ok = response.ok == true, message = response.message, payload = snapshot(), policy = response.policy })
end)
RegisterNUICallback('adminPolicyRefresh', function(data, cb)
    if not validSession(data) then
        cb({ ok = false, message = 'Sessão encerrada.' }); return
    end
    TriggerServerEvent('forge-fps:policy:request'); cb({ ok = true, message = 'Consultando política do servidor…' })
end)
RegisterNUICallback('adminPolicySave', function(data, cb)
    if not validSession(data) or not FpsPolicy.admin then
        cb({ ok = false, message = 'Sem permissão administrativa.' }); return
    end
    local valid, reason = FpsPolicy.validate(data.rules)
    if not valid then
        cb({ ok = false, message = reason }); return
    end
    rpcId = rpcId % 2147483647 + 1; local ticket = rpcId; pendingPolicy[ticket] = cb
    TriggerServerEvent('forge-fps:policy:save', ticket, data.revision, valid)
    CreateThread(function()
        Wait(5000); if pendingPolicy[ticket] then
            local callback = pendingPolicy[ticket]; pendingPolicy[ticket] = nil; callback({ ok = false, message =
            'Servidor não respondeu. Atualize a política antes de tentar novamente.' })
        end
    end)
end)
RegisterNUICallback('benchmark', function(data, cb)
    if not validSession(data) then
        cb({ ok = false, message = 'Sessão encerrada ou comparação em andamento.' }); return
    end
    local candidate, reason = FpsSettings.validate(data.settings)
    if not candidate then
        cb({ ok = false, message = reason }); return
    end
    if shouldSuspend() then
        cb({ ok = false, message = 'Feche outras câmeras ou menus antes de comparar.' }); return
    end
    local ped = PlayerPedId(); local pos, rot = GetEntityCoords(ped), GetGameplayCamRot(2)
    generation = generation + 1; local ticket = generation
    benchmark = { candidate = candidate }; lastResult = nil; opened = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'testStart', seconds = Config.BenchmarkSeconds })
    cb({ ok = true })
    CreateThread(function()
        local function alive()
            if ticket ~= generation or stopped then return false end
            local p, r = GetEntityCoords(ped), GetGameplayCamRot(2)
            local yaw = math.abs((r.z - rot.z + 180) % 360 - 180)
            if PlayerPedId() ~= ped or IsEntityDead(ped) or IsPedShooting(ped) or shouldSuspend()
                or (p.x - pos.x) ^ 2 + (p.y - pos.y) ^ 2 + (p.z - pos.z) ^ 2 > 9 or yaw > 15 or math.abs(r.x - rot.x) > 15 then
                cancelBenchmark('Cenário mudou. Comparação cancelada e ajustes restaurados.'); return false
            end
            return true
        end
        local function measure(phase)
            local settle = GetGameTimer() + 2000
            SendNUIMessage({ action = 'testProgress', phase = 'settle', next = phase, remaining = 2 })
            while GetGameTimer() < settle do
                if not alive() then return end; Wait(100)
            end
            FpsMetrics.beginCapture(); local finish = GetGameTimer() + Config.BenchmarkSeconds * 1000
            while GetGameTimer() < finish do
                if not alive() then return end
                SendNUIMessage({ action = 'testProgress', phase = phase, remaining = math.ceil((finish - GetGameTimer()) /
                1000) })
                Wait(250)
            end
            if not alive() then return end
            return FpsMetrics.endCapture()
        end
        FpsGraphics.restore(); FpsPerformance.restore()
        local baseline = measure('original'); if not baseline then return end
            FpsGraphics.apply(candidate, true); FpsPerformance.configure(candidate,true)
        benchmark.active = true
        local tested = measure('candidate'); if not tested then return end
        if not alive() then return end
        benchmark = nil; FpsGraphics.restore(); FpsPerformance.restore(); apply(true); FpsMetrics.reset()
        lastResult = {
            before = baseline,
            after = tested,
            candidate = candidate,
            reverted = true,
            valid = baseline.samples >= 60 and tested.samples >= 60,
            delta = tested.fps - baseline.fps
        }
        session = session + 1; opened = true; SetNuiFocus(true, true)
        SendNUIMessage({ action = 'open', payload = snapshot() })
        SendNUIMessage({ action = 'testEnd', message =
        'Comparação concluída; o ajuste anterior foi restaurado. Ganho observado não é garantia.' })
    end)
end)
RegisterCommand(Config.Command, open, false)
if Config.Key ~= '' then RegisterKeyMapping(Config.Command, 'Forge FPS: abrir painel', 'keyboard', Config.Key) end
exports('Open', open)
exports('GetSettings', function() return FpsSettings.copy(settings) end)
exports('GetMetrics', function() return FpsSettings.copy(FpsMetrics.snapshot(GetGameTimer())) end)
exports('SetSuspended', function(value)
    local resource = GetInvokingResource(); if not resource or type(value) ~= 'boolean' then return false end
    external[resource] = value or nil; apply(false); return true
end)
AddEventHandler('onClientResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        stopped = true; generation = generation + 1; FpsGraphics.restore(); FpsPerformance.restore(); if opened then
            SetNuiFocus(false, false) end
    elseif external[resource] then
        external[resource] = nil; apply(false)
    end
end)
CreateThread(function()
    local raw = GetResourceKvpString(Config.StorageKey)
    if raw and #raw < 16384 then
        local ok, decoded = pcall(json.decode, raw)
        if ok and type(decoded) == 'table' and decoded.version == 1 then
            if type(decoded.settings) == 'table' then loadedPreferences = decoded.settings end
        end
    end
    TriggerServerEvent('forge-fps:policy:request')
    Wait(500); apply(true)
    SendNUIMessage({ action = 'hud', visible = settings.hud, position = settings.hudPosition, settings = settings })
    local lastSuspended = false
    while not stopped do
        Wait(1000)
        local detected = FpsLocale.resolve()
        if detected ~= locale then locale = detected; SendNUIMessage({ action = 'locale', locale = locale }) end
        if opened and IsEntityDead(PlayerPedId()) then close() end
        local paused = shouldSuspend()
        suspended.scene = paused or nil
        if not benchmark then apply(paused ~= lastSuspended) end
        lastSuspended = paused
        local now = GetGameTimer()
        local measure = opened or settings.hud or benchmark ~= nil or (settings.automatic and settings.preset ~= 'original') or settings.alertLowFps
        local metric = measure and FpsMetrics.snapshot(now) or {samples=0,fps=0}
        if not FpsPolicy.ready and now % 5000 < 1100 then TriggerServerEvent('forge-fps:policy:request') end
        if not benchmark and not paused and not opened and settings.automatic and settings.preset ~= 'original' and metric.samples >= 60 then
            lowTicks = metric.fps < settings.autoFloor and lowTicks + 1 or 0
            highTicks = metric.fps > settings.autoCeiling and highTicks + 1 or 0
            if now - lastAuto >= settings.autoCooldown * 1000 then
                local nextLevel = autoLevel
                if lowTicks >= 5 then nextLevel = math.min(4, autoLevel + 1) elseif highTicks >= 10 then nextLevel = math
                    .max(0, autoLevel - 1) end
                if nextLevel ~= autoLevel then
                    autoLevel, lastAuto = nextLevel, now; apply(false)
                end
            end
        end
        local low = settings.alertLowFps and not paused and not opened and not benchmark and metric.samples >= 60 and
        metric.fps < settings.alertThreshold
        alertTicks = low and alertTicks + 1 or 0
        local show = alertTicks >= settings.alertDuration
        if show ~= alertVisible then
            alertVisible = show; SendNUIMessage({ action = 'lowFps', visible = show, fps = metric.fps })
        end
        if opened or settings.hud or benchmark then
            local history = (opened or settings.hudShowGraph) and FpsMetrics.history(now, metric) or nil
            local graphics
            if opened then
                graphics = FpsGraphics.status(); for key, value in pairs(FpsPerformance.status()) do graphics[key] = value end
            end
            -- Closed HUD never receives/copies the whole control catalog/status.
            SendNUIMessage({ action = 'metrics', diagnostics=FpsDiagnostics.snapshot(settings,opened),metrics = metric, history = history, position = settings.hudPosition, hud =
            settings.hud and not(settings.pauseSaver and IsPauseMenuActive()), effective = opened and effective or nil, graphics = graphics, suspended = paused })
        end
    end
end)
CreateThread(function()
    local active = false
    local lastHud = 0
    while not stopped do
        local needed = opened or settings.hud or (settings.automatic and settings.preset ~= 'original') or settings.alertLowFps or benchmark ~= nil
        if FpsPerformance.needed() and not shouldSuspend() and (not benchmark or benchmark.active) then FpsPerformance
                .tick() end
        if needed then
            if not active then FpsMetrics.reset() end
            active = true
            local now = GetGameTimer()
            local paused = IsPauseMenuActive() and settings.pauseSaver
            if not paused then
                FpsMetrics.push(GetFrameTime() * 1000, now, GetFrameCount and GetFrameCount())
                if settings.hud and not opened and not benchmark and now - lastHud >= 250 then
                    lastHud = now; SendNUIMessage({ action = 'frame', metrics = FpsMetrics.current(now) })
                end
            end
            if benchmark and IsControlJustPressed(0, 200) then cancelBenchmark() end
            Wait(0)
        else
            active = false; Wait(FpsPerformance.needed() and 0 or 500)
        end
    end
end)
