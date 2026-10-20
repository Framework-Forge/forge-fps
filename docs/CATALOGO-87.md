# Destino das 87 opções da referência

Versão Forge FPS 1.3.1. Contagem conferida em `Config.Settings` da cópia local de Oxlyn: **87**, sem contar categorias e perfis. A referência só foi lida; não é carregada nem distribuída como dependência.

O Forge FPS tem **76 controles próprios**, além dos seis presets no painel e quatro idiomas automáticos. Há 46 autorizações administrativas e vinte parâmetros que também exigem controle exclusivo/baseline. A revisão 1.3.1 retirou o seletor manual de idioma. Não é uma equivalência 1:1 com os 87 IDs da referência; cada linha abaixo registra a adaptação ou exclusão.

Não são 87 gráficos implementados: a tabela identifica exatamente o que foi adaptado, condicionado ou excluído. “Excluído” não significa que exista uma native destrutiva escondida aguardando desbloqueio. Não há cópia dos módulos dos boosters.

## Gráficos (15)

| ID na referência | Destino no Forge FPS |
| --- | --- |
| `shadowMode` | Implementado como escolha de amostragem experimental, com strings oficiais e controle exclusivo; não é “desligar todas as sombras”. |
| `shadowDistance` | Implementado como escala experimental de cascatas; autorização e controle exclusivo com baseline. |
| `lodScale` | Implementado por quadro, com mínimo administrativo nunca inferior a 65%. |
| `pedLodBudget` | Adaptado para `pedPopulationBudget` (orçamento de população, não LOD de cada ped), com controle exclusivo. |
| `vehLodBudget` | Adaptado para `vehiclePopulationBudget`, com controle exclusivo. |
| `reduceModelBudget` | Dois controles próprios: `reducePedModels` e `reduceVehicleModels`, com controle exclusivo. |
| `disableDecals` | Adaptado como `hideDecals`: oculta renderização por quadro sob autorização; não limpa/apaga marcas. |
| `vehicleTrails` | Implementado como forçar rastros; desligar a força não apaga rastros normais. Controle exclusivo. |
| `footstepTracks` | Implementado como forçar pegadas, com controle exclusivo; não limpa marcas. |
| `oceanScaler` | Implementado com escala relativa, captura e restauração de ondas. Pode afetar barcos. |
| `flatWater` | Implementado pelo mesmo controle de ondas, com captura/restauração. |
| `motionBlur` | Implementado para o próprio ped, com controle exclusivo/baseline. Não confundir com desfoque global. |
| `screenBlur` | Não implementado: não interfere no blur de outros menus/cenas. |
| `filmGrain` | Implementado como parâmetro de override de ruído, com controle exclusivo. Efeito precisa de validação no artifact. |
| `entityLod` | Adaptado: só objetos locais próximos, não networked e não missão, com captura/restauração; nunca jogadores/veículos. |

## Iluminação (4)

| ID na referência | Destino no Forge FPS |
| --- | --- |
| `artificialLights` | Implementado sob autorização/controle exclusivo. Sirene é o som falso ambiente, não sirenes individuais. |
| `artificialLightsVeh` | Implementado sob autorização/controle exclusivo. Sirene é o som falso ambiente, não sirenes individuais. |
| `vehicleDistantLights` | Implementado sob autorização/controle exclusivo. Sirene é o som falso ambiente, não sirenes individuais. |
| `distantSirens` | Implementado sob autorização/controle exclusivo. Sirene é o som falso ambiente, não sirenes individuais. |

## População (16)

| ID na referência | Destino no Forge FPS |
| --- | --- |
| `pedDensity` | Implementado por quadro, sob autorização e mínimo administrativo; não apaga entidades existentes. |
| `vehicleDensity` | Implementado por quadro, sob autorização e mínimo administrativo; não apaga entidades existentes. |
| `parkedDensity` | Implementado por quadro, sob autorização e mínimo administrativo; não apaga entidades existentes. |
| `randomVehDensity` | Implementado por quadro, sob autorização e mínimo administrativo; não apaga entidades existentes. |
| `scenarioDensity` | Dois controles: `scenarioInside` / `scenarioOutside`, ordem correta interior/exterior na native. |
| `ambientVehRange` | Implementado com verificação de native. Se a função não existir, mostra indisponível; não inventa hash. |
| `ambientPedRange` | Implementado com verificação de native. Se a função não existir, mostra indisponível; não inventa hash. |
| `distantCars` | Implementado para geração/renderização ambiente com controle exclusivo; sem apagar entidades existentes. |
| `randomCops` | Implementado para geração/renderização ambiente com controle exclusivo; sem apagar entidades existentes. |
| `garbageTrucks` | Implementado para geração/renderização ambiente com controle exclusivo; sem apagar entidades existentes. |
| `randomBoats` | Implementado para geração/renderização ambiente com controle exclusivo; sem apagar entidades existentes. |
| `randomTrains` | Implementado para geração/renderização ambiente com controle exclusivo; sem apagar entidades existentes. |
| `lowPriorityVehGens` | Implementado para geração/renderização ambiente com controle exclusivo; sem apagar entidades existentes. |
| `dispatchServices` | Excluído: preserva NPCs/trânsito/spawns/serviços do servidor. |
| `blockPedSpawns` | Implementado cancelando somente criação de população ambiente; não impede jogador/script de criar ped de missão. |
| `blockParkedSpawns` | Adaptado para densidade de estacionados zero por quadro, sem apagar os já existentes. |

## Motor de renderização (6)

| ID na referência | Destino no Forge FPS |
| --- | --- |
| `renderLodLights` | Implementado como teste, bloqueado por padrão: `renderLodLights`. |
| `renderCoronas` | Implementado como teste, bloqueado por padrão: `renderCoronas`. |
| `renderDistantLights` | Implementado como teste, bloqueado por padrão: `renderDistantLights`. |
| `renderPuddles` | Implementado como teste, bloqueado por padrão: `renderPuddles`. |
| `renderPostFx` | Adaptado: bloom geral/três camadas + dois controles de bokeh; não é uma redução indiscriminada de todo pós-processamento. |
| `renderVehicleLights` | Implementado como teste, bloqueado por padrão: `renderVehicleLights`. |

## Clima e efeitos (5)

| ID na referência | Destino no Forge FPS |
| --- | --- |
| `forceClearWeather` | Excluído: preserva clima/chuva/vento/partículas e seus eventos. |
| `killRain` | Excluído: preserva clima/chuva/vento/partículas e seus eventos. |
| `killWind` | Excluído: preserva clima/chuva/vento/partículas e seus eventos. |
| `particleCleanup` | Excluído: preserva clima/chuva/vento/partículas e seus eventos. |
| `particleRadius` | Excluído: preserva clima/chuva/vento/partículas e seus eventos. |

## Limpeza (9)

| ID na referência | Destino no Forge FPS |
| --- | --- |
| `cleanupEnabled` | Excluído: não apaga entidades, projéteis ou evidências do RP. |
| `cleanupInterval` | Excluído: não apaga entidades, projéteis ou evidências do RP. |
| `cleanupRadius` | Excluído: não apaga entidades, projéteis ou evidências do RP. |
| `clearProjectiles` | Excluído: não apaga entidades, projéteis ou evidências do RP. |
| `clearGlass` | Excluído: não apaga entidades, projéteis ou evidências do RP. |
| `clearDecals` | Excluído: não apaga entidades, projéteis ou evidências do RP. |
| `clearObjects` | Excluído: não apaga entidades, projéteis ou evidências do RP. |
| `clearDeadPeds` | Excluído: não apaga entidades, projéteis ou evidências do RP. |
| `clearEmptyVehicles` | Excluído: não apaga entidades, projéteis ou evidências do RP. |

## HUD (9)

| ID na referência | Destino no Forge FPS |
| --- | --- |
| `hudEnabled` | Implementado como `hud`. |
| `hudPosition` | Implementado. |
| `hudScale` | Implementado. |
| `hudOpacity` | Implementado. |
| `hudShowFrametime` | Implementado. |
| `hudShowLows` | Implementado. |
| `hudShowPing` | Implementado: ping real do próprio jogador no servidor, sob demanda e rate limit. |
| `hudShowGraph` | Implementado. |
| `hudShowEntities` | Implementado: contagens locais de pools, atualização espaçada de cinco segundos somente quando solicitada. |

## Interface (13)

| ID na referência | Destino no Forge FPS |
| --- | --- |
| `uiAccent` | Adaptado: três cores predefinidas. |
| `uiAutoScale` | Layout responsivo sempre ativo; escala manual em `uiScale`. |
| `uiScale` | Implementado (75–100%). |
| `uiBlur` | Excluído: não usar backdrop-filter na NUI (custo/composição). |
| `uiBackdrop` | Implementado; só quando painel aberto. |
| `ui3d` | Excluído: decoração 3D da interface, não é otimização do jogo. |
| `uiAnimations` | Implementado: entrada discreta, sem animação contínua. |
| `uiFloat` | Excluído: decoração contínua não melhora FPS. |
| `uiSounds` | Implementado: clique Web Audio local, opcional. |
| `uiChartGlow` | Implementado, desligado por padrão. |
| `uiChartRange` | Adaptado: 15/30/60 atualizações de 1 segundo. |
| `uiLocale` | Substituído por leitura automática do idioma do PR Bridge: pt-br, en-us, es e fr. Não é mais um controle manual salvo. |
| `uiShowEstimates` | Excluído: sem estimativas de CPU/GPU/RAM/temperatura. |

## Automação (10)

| ID na referência | Destino no Forge FPS |
| --- | --- |
| `autoBoost` | Implementado como `automatic`, somente bloom. |
| `autoBoostFloor` | Implementado como `autoFloor`. |
| `autoBoostCeiling` | Implementado como `autoCeiling`. |
| `autoBoostCooldown` | Implementado como `autoCooldown`. |
| `alertLowFps` | Implementado; aviso local, não força perfil. |
| `alertThreshold` | Implementado + persistência em `alertDuration`. |
| `pauseSaver` | Adaptado: oculta HUD e interrompe coleta na pausa nativa; não é limitador de FPS. Suspensão de efeitos externos permanece obrigatória. |
| `afkSaver` | Implementado como redução somente de bloom ao piso; detector de posição/câmera/entrada e retorno ao ativo. Não é limitador/anti-AFK. |
| `afkMinutes` | Implementado, 1–30 minutos. |
| `interiorSaver` | Implementado somente para bloom ao piso; não desliga cena/interior. |

## Controles novos, sem equivalente direto

Bloom geral/camadas independentes, tamanho/intensidade do bokeh, amostras do HUD, contraste do painel, meta de referência e persistência do aviso. Não somar linhas desta tabela ao número de controles reais: vários itens são adaptados para um mesmo mecanismo seguro.

## Critérios de implementação

- Original não escreve efeitos gráficos, mesmo com testes liberados.
- Pisos iniciais: bloom 65%, bokeh 75%, renderização 65%; o servidor pode autorizar limites menores.
- Só parâmetros explicitamente listados; nada de nome de native/chave vindo da NUI.
- Visualsettings usam getters e propriedade; floats nas escalas, inteiros nos budgets. Parâmetros sem getter só com controle exclusivo e baseline, nunca tratados como captura do original. Densidades/LOD/decals expiram por quadro.
- As funções de visualsettings seguem a [implementação oficial do FiveM](https://github.com/citizenfx/fivem/blob/master/code/components/extra-natives-five/src/VisualSettingsNatives.cpp); suporte a cada chave ainda depende da instalação do jogo.
- Nenhum ganho de FPS foi comprovado no GTA localmente; medir antes/depois no mesmo lugar.
