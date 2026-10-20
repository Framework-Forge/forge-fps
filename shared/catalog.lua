-- Own allowlist: reference scripts are never loaded.
FpsCatalog = {}
local function range(key, group, label, description, default, min, max, step, unit, policy)
    FpsCatalog[#FpsCatalog + 1] = {
        key = key,
        group = group,
        label = label,
        description = description,
        default = default,
        min =
            min,
        max = max,
        step = step,
        type = 'range',
        unit = unit,
        policy = policy
    }
end

local function choice(key, group, label, default, options)
    FpsCatalog[#FpsCatalog + 1] = {
        key = key,
        group = group,
        label = label,
        default = default,
        options = options,
        type =
        'choice'
    }
end
local function toggle(key, group, label, description, default)
    FpsCatalog[#FpsCatalog + 1] = {
        key = key,
        group = group,
        label = label,
        description = description,
        default = default,
        type =
        'boolean'
    }
end
range('bloom', 'graphics', 'Intensidade do bloom', 'Brilho cosmético geral; não desliga a iluminação.', 1.0, .65, 1, .01,
    'percent', 'bloom')
for _, v in ipairs({ { 'bloomSmall', 'pequeno' }, { 'bloomMedium', 'médio' }, { 'bloomLarge', 'grande' } }) do
    range(v[1], 'graphics', 'Bloom · raio ' .. v[2],
        'Camada independente. O resultado combinado respeita o piso de segurança.', 1.0, .65, 1, .01, 'percent', 'bloom')
end
range('cinematicBlur', 'graphics', 'Desfoque cinematográfico', 'Tamanho do bokeh. Depende da liberação do administrador.',
    1.0, .75, 1, .01, 'percent', 'cinematicBlur')
range('bokehAlpha', 'graphics', 'Intensidade do bokeh', 'Opacidade do desfoque. Não muda o foco de streaming.', 1.0, .75,
    1, .01, 'percent', 'cinematicBlur')
for _, v in ipairs({ { 'renderLodLights', 'Luzes de LOD' }, { 'renderCoronas', 'Coronas de luz' }, { 'renderDistantLights', 'Iluminação distante' }, { 'renderPuddles', 'Poças e reflexos' }, { 'renderVehicleLights', 'Luzes dos veículos' } }) do
    range(v[1], 'testing', v[2],
        'Teste de renderização: validar noite, chuva e combate antes de liberar. Nunca remove entidades ou muda clima.',
        1.0, .65, 1, .01, 'percent', v[1])
end
toggle('hud', 'monitor', 'Contador compacto', 'Medições reais, sem estimativas de hardware.', false)
choice('hudPosition', 'monitor', 'Posição do contador', 'topright',
    { { value = 'topleft', label = 'Superior esquerdo' }, { value = 'topright', label = 'Superior direito' }, { value = 'bottomleft', label = 'Inferior esquerdo' }, { value = 'bottomright', label = 'Inferior direito' } })
range('hudScale', 'monitor', 'Tamanho do contador', 'Não altera a resolução do jogo.', 1.0, .6, 1.6, .05, 'percent')
range('hudOpacity', 'monitor', 'Opacidade do contador', 'Transparência durante o jogo.', .9, .2, 1, .05, 'percent')
toggle('hudShowFrametime', 'monitor', 'Mostrar tempo de quadro', 'Tempo médio em milissegundos.', true)
toggle('hudShowLows', 'monitor', 'Mostrar 1% low', 'Média dos quadros mais lentos.', true)
toggle('hudShowGraph', 'monitor', 'Gráfico no contador', 'Atualizado uma vez por segundo.', false)
toggle('hudShowSamples', 'monitor', 'Mostrar amostras', 'Quantidade de quadros medidos.', false)
range('uiScale', 'interface', 'Escala do painel', 'Diminui o painel mantendo controles acessíveis.', 1.0, .75, 1, .05,
    'percent')
range('uiBackdrop', 'interface', 'Escurecer fundo do painel', 'Só afeta a interface aberta; transparente ao fechar.', .3,
    0, .65, .05, 'percent')
choice('uiAccent', 'interface', 'Cor de destaque', '#FF7A1A',
    { { value = '#FF7A1A', label = 'Laranja Forge' }, { value = '#38BDF8', label = 'Azul' }, { value = '#34D399', label = 'Verde' } })
choice('uiChartRange', 'interface', 'Janela do gráfico', 60,
    { { value = 15, label = '15 segundos' }, { value = 30, label = '30 segundos' }, { value = 60, label = '60 segundos' } })
range('uiChartGlow', 'interface', 'Brilho do gráfico', 'Somente sobre a linha do gráfico.', 0.0, 0, 1, .1, 'percent')
toggle('uiAnimations', 'interface', 'Animações do painel', 'Respeita a preferência de movimento reduzido do sistema.',
    false)
toggle('uiHighContrast', 'interface', 'Textos com mais contraste', 'Clareia descrições e textos de apoio.', false)
toggle('automatic', 'automation', 'Ajuste automático conservador', 'Somente bloom; não reduz cenário ou população.',
    false)
range('target', 'automation', 'Meta de referência', 'Centraliza os limites automáticos. Não é limitador de FPS.', 60, 30,
    144, 1, 'fps')
range('autoFloor', 'automation', 'Limite inferior automático', 'Após 5 atualizações abaixo deste FPS, reduz um passo.',
    45, 20, 140, 1, 'fps')
range('autoCeiling', 'automation', 'Limite superior automático',
    'Após 10 atualizações acima deste FPS, recupera qualidade.', 90, 25, 240, 1, 'fps')
range('autoCooldown', 'automation', 'Intervalo de ajuste automático', 'Tempo mínimo entre passos.',
    math.max(15, math.min(120, Config.AutoCooldownSeconds or 30)), 15, 120, 5, 'seconds')
toggle('alertLowFps', 'automation', 'Aviso de FPS baixo', 'Aviso local; não altera gráficos por conta própria.', false)
range('alertThreshold', 'automation', 'Limite do aviso', 'FPS abaixo do qual o aviso será considerado.', 30, 15, 120, 1,
    'fps')
range('alertDuration', 'automation', 'Persistência do aviso', 'Evita avisos por quedas passageiras.', 5, 2, 15, 1,
    'seconds')

-- Advanced controls: all require a server policy; Original always uses neutral values.
range('lodScale', 'distance', 'Distância de detalhes (LOD)',
    'Reduz detalhe/distância do cenário. Pode afetar cobertura e leitura visual.', 1.0, .65, 1, .05, 'percent', 'lodScale')
FpsCatalog[#FpsCatalog].legacyMin = .1
for _, v in ipairs({
    { 'pedDensity',    'Densidade de NPCs' }, { 'vehicleDensity', 'Densidade de trânsito' },
    { 'parkedDensity', 'Veículos estacionados' }, { 'randomVehDensity', 'Veículos aleatórios' },
    { 'scenarioInside', 'NPCs de cenário · interiores' }, { 'scenarioOutside', 'NPCs de cenário · exteriores' },
}) do
    range(v[1], 'population', v[2],
        'Afeta geração de população ambiente; não apaga entidades existentes nem controla jogadores.', 1.0, 0, 1, .05,
        'percent', v[1])
end
toggle('hideDecals', 'distance', 'Ocultar decals neste quadro',
    'Oculta a renderização de marcas/sangue; não os apaga. Pode gerar vantagem visual.', false)
FpsCatalog[#FpsCatalog].policy = 'hideDecals'
for _, v in ipairs({ { 'reducePedModels', 'Orçamento reduzido · modelos de NPCs' }, { 'reduceVehicleModels', 'Orçamento reduzido · modelos de veículos' } }) do
    toggle(v[1], 'memory', v[2],
        'Modo de orçamento de modelos; não é um seletor de texturas. Exige controle exclusivo autorizado pelo administrador.',
        false)
    FpsCatalog[#FpsCatalog].policy = v[1]; FpsCatalog[#FpsCatalog].exclusive = true
end
for _, v in ipairs({ { 'pedPopulationBudget', 'Orçamento de população · NPCs' }, { 'vehiclePopulationBudget', 'Orçamento de população · veículos' } }) do
    range(v[1], 'memory', v[2],
        'Nível de orçamento do motor (0–3). Exige controle exclusivo; não equivale à resolução de texturas.', 3, 0, 3, 1,
        'level', v[1])
    FpsCatalog[#FpsCatalog].exclusive = true
end
range('shadowDistance', 'distance', 'Escala de sombras em cascata',
    'Parâmetro experimental de alcance das sombras. Exige controle exclusivo e avaliação visual.', 1.0, .1, 1, .05,
    'percent', 'shadowDistance')
FpsCatalog[#FpsCatalog].exclusive = true
for _, item in ipairs(FpsCatalog) do
    if item.group == 'graphics' or item.group == 'testing' then
        item.defaultMin = item.min; item.min = 0.0
    end
end

-- Completion pass. Every world-changing control starts denied in the server policy.
local function advancedBool(key, group, label, description, default, exclusive, optimize)
    toggle(key, group, label, description, default)
    local item = FpsCatalog[#FpsCatalog]; item.policy = key; item.exclusive = exclusive; item.optimize = optimize
end
for _, v in ipairs({ { 'ambientVehRange', 'Alcance de geração de veículos' }, { 'ambientPedRange', 'Alcance de geração de NPCs' } }) do
    range(v[1], 'population', v[2], 'Multiplicador ambiente por quadro. Não altera jogadores ou entidades de missão.',
        1.0, .1, 1, .05, 'percent', v[1])
end
for _, v in ipairs({ { 'distantCars', 'Carros distantes decorativos' }, { 'randomCops', 'Polícia ambiente aleatória' }, { 'garbageTrucks', 'Caminhões de lixo ambientes' }, { 'randomBoats', 'Barcos ambientes' }, { 'randomTrains', 'Trens ambientes' }, { 'lowPriorityVehGens', 'Geradores de veículos secundários' } }) do
    advancedBool(v[1], 'population', v[2],
        'Controla geração/renderização ambiente do motor; não apaga entidades. Exige controle exclusivo.', true, true,
        false)
end
advancedBool('blockPedSpawns', 'population', 'Bloquear novos NPCs ambientes',
    'Cancela somente o evento de criação de população ambiente. Não apaga NPCs nem bloqueia jogadores.', false, false,
    true)
advancedBool('blockParkedSpawns', 'population', 'Bloquear novos estacionados',
    'Força a densidade de estacionados a zero por quadro; não apaga veículos existentes.', false, false, true)
advancedBool('artificialLights', 'lighting', 'Iluminação artificial',
    'Desligar pode apagar luzes e texturas emissivas da cidade. Exige controle exclusivo.', true, true, false)
advancedBool('artificialLightsVeh', 'lighting', 'Veículos afetados pelo blackout',
    'Participação dos veículos no blackout; só tem efeito quando o blackout está ativo.', false, true, true)
advancedBool('vehicleDistantLights', 'lighting', 'Luzes distantes de veículos',
    'Pode reduzir leitura visual à distância. Não mexe em luzes individuais de missão.', true, true, false)
advancedBool('distantSirens', 'lighting', 'Sirenes ambientes distantes',
    'Controla sons falsos de sirene ambiente, não a sirene de cada veículo. Ganho de FPS não garantido.', true, true,
    false)
advancedBool('vehicleTrails', 'effects', 'Forçar rastros de pneus',
    'A native força rastros em todas as superfícies. Desativar não significa apagar os rastros normais.', false, true,
    false)
advancedBool('footstepTracks', 'effects', 'Forçar pegadas',
    'Força a exibição de pegadas. Desativar não limpa marcas existentes.', false, true, false)
range('oceanScaler', 'effects', 'Intensidade das ondas',
    'Escala relativa à intensidade capturada do mar. Pode afetar gameplay de barcos.', 1.0, 0, 1, .05, 'percent',
    'oceanScaler')
advancedBool('flatWater', 'effects', 'Mar sem ondas locais',
    'Usa o mesmo controle de ondas, com captura e restauração. Afeta a região próxima ao jogador.', false, false, true)
advancedBool('motionBlur', 'graphics', 'Motion blur do personagem',
    'Controla somente o motion blur do próprio ped; não é o desfoque global do GTA.', true, true, false)
range('filmGrain', 'graphics', 'Granulação (override)',
    'Intensidade do override de ruído; exige controle exclusivo e baseline.', 1.0, 0, 1, .05, 'percent', 'filmGrain')
FpsCatalog[#FpsCatalog].exclusive = true
choice('shadowMode', 'distance', 'Amostragem de sombras', 'CSM_ST_SOFT16',
    { { value = 'CSM_ST_POINT', label = 'Ponto' }, { value = 'CSM_ST_LINEAR', label = 'Linear' }, { value = 'CSM_ST_TWOTAP', label = 'Duas amostras' }, { value = 'CSM_ST_BOX3x3', label = 'Caixa 3×3' }, { value = 'CSM_ST_SOFT16', label = 'Suave 16' } })
FpsCatalog[#FpsCatalog].description =
'Amostragem experimental de sombras; não desliga todas as sombras. Exige controle exclusivo.'
FpsCatalog[#FpsCatalog].policy = 'shadowMode'; FpsCatalog[#FpsCatalog].exclusive = true; FpsCatalog[#FpsCatalog].optimize =
'CSM_ST_POINT'
range('entityLod', 'distance', 'LOD de objetos ambientes locais',
    'Só objetos não networked, não missão e próximos; preserva jogadores/veículos e restaura o LOD capturado.', 1.0, .65,
    1, .05, 'percent', 'entityLod')
FpsCatalog[#FpsCatalog].legacyMin = .1
toggle('hudShowPing', 'monitor', 'Mostrar ping',
    'Latência real fornecida pelo servidor; consulta somente quando este contador está ativo.', false)
toggle('hudShowEntities', 'monitor', 'Mostrar entidades carregadas',
    'Contagem real dos pools locais; atualização espaçada, não número de entidades do servidor.', false)
toggle('uiSounds', 'interface', 'Sons da interface', 'Cliques discretos gerados localmente; sem download de áudio.',
    false)
toggle('pauseSaver', 'automation', 'Economia na pausa',
    'Suspende os ajustes e a coleta de quadros durante a pausa nativa. Não é limitador de FPS.', true)
toggle('afkSaver', 'automation', 'Economia AFK',
    'Reduz apenas bloom ao piso quando parado e sem entrada por alguns minutos. Não altera população automaticamente.',
    false)
range('afkMinutes', 'automation', 'Tempo para AFK',
    'A automação retorna à preferência salva quando houver movimento, câmera ou entrada.', 5, 1, 30, 1, 'minutes')
toggle('interiorSaver', 'automation', 'Economia em interiores',
    'Reduz somente bloom ao piso em interiores; não muda iluminação ou entidades por conta própria.', false)
for _, item in ipairs(FpsCatalog) do
    if item.key == 'reducePedModels' or item.key == 'reduceVehicleModels' or item.key == 'hideDecals' then item.optimize = true end
    -- Explicit custom testing only: don't scan object pools or switch model budgets
    -- merely because a player chooses a stronger preset.
    if item.group == 'memory' or item.key == 'entityLod' then item.manualOnly = true end
end
