Config = {
    Command = 'fps',
    Key = 'F10', -- '' desativa a tecla; /fps continua disponível.
    StorageKey = 'forge-fps:preferences:v1',
    -- Valores iniciais. As permissões finais vêm do servidor/painel administrativo.
    AllowBloom = true,
    AllowCinematicBlur = true, -- opcional; validar visibilidade/armas/cenas antes de liberar.
    MinimumBloom = 0.65,
    MinimumCinematicBlur = 0.75,
    -- Padrões de renderização para instalações novas. A política publicada no
    -- servidor prevalece e pode definir mínimos menores após avaliação do admin.
    TestEffects = {
        renderLodLights = true,
        renderCoronas = true,
        renderDistantLights = true,
        renderPuddles = true,
        renderVehicleLights = true,
    },
    BenchmarkSeconds = 10, -- por fase; original e candidato, com 2 s de acomodação.
    AutoCooldownSeconds = 20,
    WindowSeconds = 10,
}
