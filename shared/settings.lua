FpsSettings = {}
FpsSettings.defaults = { preset = 'original', bloom = 1.0, cinematicBlur = 1.0, hud = false, automatic = false, target = 60, hudPosition =
'topright' }
for _, item in ipairs(FpsCatalog) do FpsSettings.defaults[item.key] = item.default end
FpsSettings.presets = {
    { id = 'original', name = 'Original', description = 'Nenhum ajuste gráfico do Forge FPS.',                bloom = 1.0, cinematicBlur = 1.0 },
    { id = 'light',  name = 'Leve',      description = 'Redução discreta de pós-processamento cosmético.',    bloom = 0.85, cinematicBlur = 0.9 },
    { id = 'balanced', name = 'Equilibrado', description = 'Limite conservador, sem remover elementos do cenário.', bloom = 0.65, cinematicBlur = 0.75 },
    {id='ultralight',name='Ultra leve',description='Reduções mais fortes nas opções autorizadas.',bloom=.35,cinematicBlur=.4,strength=.65},
    {id='notebook',name='Notebook',description='Prioriza redução de custo gráfico, dentro da política do servidor.',bloom=.15,cinematicBlur=.2,strength=.85},
    {id='maximum',name='Máximo permitido',description='Mínimos autorizados, sem desbloquear opções nem prometer FPS fixo.',bloom=0.0,cinematicBlur=0.0,strength=1.0},
}
function FpsSettings.copy(value)
    if type(value) ~= 'table' then return value end
    local result = {}; for k, v in pairs(value) do result[k] = FpsSettings.copy(v) end; return result
end

function FpsSettings.allowed(item)
    if FpsPolicy then return FpsPolicy.rule(item.key or item.policy).allowed == true end
    if item.policy == 'bloom' then return Config.AllowBloom == true end
    if item.policy == 'cinematicBlur' then return Config.AllowCinematicBlur == true end
    if item.policy then return Config.TestEffects and Config.TestEffects[item.policy] == true end
    return true
end

function FpsSettings.minimum(item)
    if FpsPolicy then return FpsPolicy.minimum(item.key or item.policy) end
    if item.policy == 'bloom' then return math.min(1, math.max(.65, Config.MinimumBloom)) end
    if item.policy == 'cinematicBlur' then return math.min(1, math.max(.75, Config.MinimumCinematicBlur)) end
    return item.defaultMin or item.min
end

function FpsSettings.neutral(item)
    if item.exclusive and FpsPolicy and FpsPolicy.baselines[item.key] ~= nil then return FpsPolicy.baselines[item.key] end
    return item.default
end

function FpsSettings.catalog()
    local result = FpsSettings.copy(FpsCatalog)
    for _, item in ipairs(result) do
        item.available = FpsSettings.allowed(item); item.hardMin = item.min; item.min = FpsSettings.minimum(item)
        item.default = FpsSettings.neutral(item)
        if not item.available then item.reason = 'Bloqueado pela política do servidor.' end
        if FpsPolicy then
            local rule = FpsPolicy.rule(item.key); item.reason = rule.reason or item.reason
            item.exclusiveGranted = FpsPolicy.exclusive[item.key] == true
        end
    end
    return result
end

function FpsSettings.validate(value, normalize)
    if type(value) ~= 'table' then return nil, 'Configuração inválida.' end
    for key in pairs(value) do if key ~= 'uiLocale' and FpsSettings.defaults[key] == nil then return nil,
                'Opção não permitida: ' .. tostring(key) end end
    local result = FpsSettings.copy(FpsSettings.defaults)
    for k, v in pairs(value) do if k ~= 'uiLocale' then result[k] = v end end
    if result.preset ~= 'custom' then
        local found = false; for _, p in ipairs(FpsSettings.presets) do if result.preset == p.id then found = true end end
        if not found then return nil, 'Perfil desconhecido.' end
    end
    for _, item in ipairs(FpsCatalog) do
        if value[item.key] == nil and item.exclusive then result[item.key] = FpsSettings.neutral(item) end
        local n = result[item.key]
        if item.type == 'range' then
            if normalize and item.legacyMin and type(n) == 'number' and n >= item.legacyMin and n < item.min then
                n = item.min
            end
            if type(n) ~= 'number' or n ~= n or n < item.min or n > item.max then return nil,
                    'Valor fora dos limites: ' .. item.label end
            if n < FpsSettings.minimum(item) and n ~= FpsSettings.neutral(item) then
                if normalize then n = FpsSettings.minimum(item) else return nil, 'Limite administrativo: ' .. item.label end
            end
            if item.step % 1 == 0 and n % 1 ~= 0 then return nil, 'Use um número inteiro: ' .. item.label end
            result[item.key] = n + 0.0
        elseif item.type == 'boolean' then
            if type(n) ~= 'boolean' then return nil, 'Estado inválido: ' .. item.label end
        else
            local found = false; for _, option in ipairs(item.options) do if n == option.value then found = true end end
            if not found then return nil, 'Opção inválida: ' .. item.label end
        end
        if item.policy and (not FpsSettings.allowed(item) or result.preset == 'original') then result[item.key] =
            FpsSettings.neutral(item) end
    end
    if result.autoFloor >= result.autoCeiling then return nil,
            'O limite inferior automático deve ser menor que o superior.' end
    return result
end

function FpsSettings.preset(id, current)
    for _, p in ipairs(FpsSettings.presets) do
        if p.id == id then
            local value = FpsSettings.copy(current or FpsSettings.defaults)
            for _, item in ipairs(FpsCatalog) do if item.policy then value[item.key] = FpsSettings.neutral(item) end end
            value.preset,value.bloom,value.cinematicBlur=p.id,p.bloom,p.cinematicBlur
            if p.strength then
                for _,item in ipairs(FpsCatalog)do if item.policy and not item.manualOnly and FpsSettings.allowed(item)then
                    local neutral=FpsSettings.neutral(item)
                    if item.type=='range'then
                        local floor=FpsSettings.minimum(item)
                        local n=neutral+(floor-neutral)*p.strength
                        if p.id=='maximum'then n=floor end
                        if item.step%1==0 then n=math.floor(n+.5)end
                        value[item.key]=math.max(floor,n)+0.0
                    elseif item.optimize~=nil then value[item.key]=item.optimize
                    elseif item.type=='boolean'then value[item.key]=neutral end
                end end
            end
            return FpsSettings.validate(value, true)
        end
    end
    return nil, 'Perfil desconhecido.'
end
