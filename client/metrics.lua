FpsMetrics = {}
local samples, times, head, count, history = {}, {}, 1, 0, {}
local capture
local capacity = 4096
local lastMs, lastTime, lastFrame, cached, cachedAt
function FpsMetrics.aggregate(values)
    local n = #values
    if n == 0 then return { ready = false, fps = 0, frameMs = 0, low1 = 0, p95 = 0, samples = 0 } end
    local sorted, total = {}, 0
    for i, ms in ipairs(values) do
        sorted[i] = ms; total = total + ms
    end
    table.sort(sorted)
    local worst = math.max(1, math.ceil(n * 0.01)); local slow = 0
    for i = n - worst + 1, n do slow = slow + sorted[i] end
    return { ready = true, fps = n * 1000 / total, frameMs = total / n, low1 = 1000 / (slow / worst), p95 = sorted
    [math.max(1, math.ceil(n * .95))], samples = n }
end

function FpsMetrics.push(ms, now, frame)
    if type(ms) ~= 'number' or ms ~= ms or ms <= 0 or ms > 10000 then return end
    if frame ~= nil and frame == lastFrame then return end
    lastMs, lastTime, lastFrame = ms, now, frame
    local idx = (head + count - 1) % capacity + 1; samples[idx], times[idx] = ms, now
    if count == capacity then head = head % capacity + 1 else count = count + 1 end
    if capture and #capture < 10000 then capture[#capture + 1] = ms end
end

function FpsMetrics.reset()
    samples, times, head, count, history = {}, {}, 1, 0, {}
    lastMs, lastTime, lastFrame, cached, cachedAt = nil, nil, nil, nil, nil
end

-- Last rendered frame, not a smoothed average. HUD publication is limited to 4 Hz.
function FpsMetrics.current(now)
    local fresh = lastTime ~= nil and now >= lastTime and now - lastTime < 1000
    return { ready = fresh, fps = fresh and 1000 / lastMs or 0, frameMs = fresh and lastMs or 0 }
end

function FpsMetrics.beginCapture() capture = {} end

function FpsMetrics.endCapture()
    local result = FpsMetrics.aggregate(capture or {}); capture = nil; return result
end

function FpsMetrics.snapshot(now)
    local current = FpsMetrics.current(now)
    if cachedAt and now >= cachedAt and now - cachedAt < 1000 then
        cached.currentFps, cached.currentFrameMs, cached.currentReady = current.fps, current.frameMs, current.ready
        return cached
    end
    local values = {}
    local window = math.max(1, math.min(60, Config.WindowSeconds or 10)) * 1000
    for i = 1, count do
        local idx = (head + i - 2) % capacity + 1
        if now >= times[idx] and now - times[idx] <= window then values[#values + 1] = samples[idx] end
    end
    cached = FpsMetrics.aggregate(values); cachedAt = now
    cached.currentFps, cached.currentFrameMs, cached.currentReady = current.fps, current.frameMs, current.ready
    cached.windowSeconds = window / 1000
    return cached
end

function FpsMetrics.history(now, snapshot)
    local s = snapshot or FpsMetrics.snapshot(now)
    if s.ready then
        history[#history + 1] = s.fps; if #history > 60 then table.remove(history, 1) end
    end
    return FpsSettings.copy(history)
end
