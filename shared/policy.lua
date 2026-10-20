-- Data-only policy validation shared by server and client. No network writes here.
FpsPolicy = { current = nil, revision = 0, admin = false, exclusive = {}, baselines = {}, ready = false }
local indexed = {}; for _, item in ipairs(FpsCatalog) do indexed[item.key] = item end
FpsPolicy.items = indexed
local function copy(v)
    if type(v) ~= 'table' then return v end; local r = {}; for k, x in pairs(v) do r[k] = copy(x) end; return r
end
local function finite(n) return type(n) == 'number' and n == n and n ~= math.huge and n ~= -math.huge end
function FpsPolicy.defaults()
    local r = {}
    for _, item in ipairs(FpsCatalog) do
        if item.policy then
            local enabled = item.policy == 'bloom' and Config.AllowBloom == true
                or item.policy == 'cinematicBlur' and Config.AllowCinematicBlur == true
                or (Config.TestEffects and Config.TestEffects[item.key] == true) or false
            local min = item.defaultMin or item.min
            if item.policy == 'bloom' then
                min = math.max(item.min, Config.MinimumBloom)
            elseif item.policy == 'cinematicBlur' then
                min = math.max(item.min, Config.MinimumCinematicBlur)
            end
            r[item.key] = { allowed = enabled, min = min }
        end
    end
    return r
end

function FpsPolicy.validate(proposed, base)
    if type(proposed) ~= 'table' then return nil, 'Política inválida.' end
    local result = copy(base or FpsPolicy.defaults())
    local count = 0
    for key, rule in pairs(proposed) do
        count = count + 1; local item = indexed[key]
        if count > 64 or not item or not item.policy or type(rule) ~= 'table' then return nil,
                'Ajuste de política desconhecido.' end
        for field in pairs(rule) do if field ~= 'allowed' and field ~= 'min' then return nil,
                    'Campo de política desconhecido.' end end
        if type(rule.allowed) ~= 'boolean' then return nil, 'Autorização inválida: ' .. item.label end
        if item.type == 'range' then
            if not finite(rule.min) or rule.min < (item.legacyMin or item.min) or rule.min > item.max or (item.step % 1 == 0 and rule.min % 1 ~= 0) then return
                nil, 'Limite inválido: ' .. item.label end
        elseif rule.min ~= nil then
            return nil, 'Esta opção não possui limite numérico.'
        end
        -- Migrate a published 1.3 LOD floor in memory, without resetting permissions
        -- or silently rewriting the administrator's file.
        result[key] = { allowed = rule.allowed, min = rule.min and math.max(item.min, rule.min) or nil }
    end
    return result
end

function FpsPolicy.validBaseline(item,n)
    if item.type=='boolean'then return type(n)=='boolean' end
    if item.type=='range'then return finite(n) and n>=item.min and n<=item.max and (item.step%1~=0 or n%1==0)end
    for _,option in ipairs(item.options or {})do if option.value==n then return true end end
    return false
end

function FpsPolicy.rule(key)
    local item = indexed[key]; if not item then return { allowed = false } end
    if not item.policy then return { allowed = true, min = item.min } end
    local rule = (FpsPolicy.current or FpsPolicy.defaults())[key] or { allowed = false, min = item.min }
    local r = copy(rule)
    if item.exclusive and not FpsPolicy.exclusive[key] then
        r.allowed = false; r.reason = 'Exige autorização de controle exclusivo em server/config.lua.'
    end
    return r
end

function FpsPolicy.minimum(key)
    local item = indexed[key]; return FpsPolicy.rule(key).min or (item and item.min)
end

function FpsPolicy.receive(payload)
    if type(payload) ~= 'table' or not finite(payload.revision) or payload.revision % 1 ~= 0 or payload.revision < FpsPolicy.revision then return false end
    if payload.exclusive ~= nil and type(payload.exclusive) ~= 'table' then return false end
    if payload.baselines ~= nil and type(payload.baselines) ~= 'table' then return false end
    local valid = FpsPolicy.validate(payload.rules)
    if not valid then return false end
    local exclusive, baselines = {}, {}
    for key, value in pairs(payload.exclusive or {}) do if indexed[key] and indexed[key].exclusive and value == true then exclusive[key] = true end end
    for key in pairs(exclusive) do
        local item = indexed[key]; local n = (payload.baselines or {})[key]
        if FpsPolicy.validBaseline(item,n) then
            baselines[key] = n
        else
            exclusive[key] = nil
        end
    end
    FpsPolicy.current, FpsPolicy.revision, FpsPolicy.admin, FpsPolicy.exclusive, FpsPolicy.ready = valid,
        payload.revision, payload.admin == true, exclusive, true
    FpsPolicy.baselines = baselines
    return true
end
