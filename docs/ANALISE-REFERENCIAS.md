# Análise comparativa das referências de FPS

Data: 19/10/2026. Escopo: cópias locais `17mov_FpsBooster` e `oxlyn-fpsboost` em `[base de dados]`. Análise estática, sem iniciar ou executar essas bases. Este documento compara a implementação recebida, não todas as versões comerciais/originais. Não foi feito benchmark das bases no GTA; não é possível declarar qual gera mais FPS a partir da leitura.

As cópias contêm banners de redistribuição/leak. Sua licença e integridade não foram presumidas. O Forge FPS é implementação nova: não importa scripts, assets, fontes ou dependências dessas referências. Os arquivos de referência permanecem intactos e ficam fora do manifesto/arquivos distribuídos. `telemetry.json` não foi usado como fonte de dados pessoais.

## Resumo: qual referência é melhor em quê?

| Critério | 17mov (cópia fornecida) | Oxlyn (cópia fornecida) | Escolha Forge |
| --- | --- | --- | --- |
| Simplicidade de entrada | Menu de toggles, comando/tecla, UI antiga/nova | Painel maior, muitas categorias | Simplicidade do fluxo do 17mov, UI própria |
| Arquitetura/manutenção | Cliente único com nomes ofuscados/decompilados | Estado, render, métricas, limpeza, automação e UI separados | Modularidade do Oxlyn como ideia |
| Diagnóstico | Não há coletor real de FPS no cliente recebido | Frametime, FPS, percentis, histórico e sessões | Métricas reais, janela curta e limitada |
| Teste antes/depois | Ausente | Baseline, acomodação, teste, reversão/aceitação | Comparação própria, detecção de mudança de cena |
| Persistência | Um KVP JSON | KVP de perfis, overrides, sessões | Um KVP versionado e validado |
| Risco competitivo | Remoção de partículas/chuva, sombras e luzes | Do cosmético ao mundo vazio e remoção de entidades | Não adotar ações de risco |
| Custo do monitor | Simples, mas vários loops fixos | Monitor mais completo, envio de UI até 50 ms, telemetria e estimativas | Coleta por frame só quando necessária; UI até 1 Hz |
| Restauração | Incompleta, sem cleanup de stop no cliente | Existe, mas restaura muitos valores fixos globais | Captura/compare/restaura só o que é nosso |

Conclusão: **Oxlyn é a referência funcional mais completa** para diagnóstico, organização e experiência de comparação. **17mov é útil pela simplicidade de interação**. Isso não torna os modos gráficos agressivos de nenhum deles adequados para uma cidade RP justa.

## 1. Catálogo — 17mov

Fontes: `Config.lua`, `client.lua`, `web/driver.html`, `web/oldui` e `web/newui`.

| Função/opção | Implementação observada | Avaliação / decisão |
| --- | --- | --- |
| Seleção de UI | `useModernUI` e mensagem para driver/iframe | Ideia de compatibilidade; não portar duas UIs |
| Abrir menu | Comando configurável, F11 e evento `fpsBooster:OpenMenu` | Adotar comando/tecla próprios, sem executar comando externo |
| Persistir toggles | `17mov_FpsSettings` via KVP | Útil, mas leitura deve tratar JSON inválido |
| `peds`, `vehicles`, `objects` | Declarados na configuração/UI, sem ramo funcional correspondente no cliente recebido | Não anunciar como efeito comprovado |
| `particles` | `RemoveParticleFxInRange` a cada 100 ms, raio 25 | Excluir: pode remover fumaça/efeitos de combate |
| `rain` | Chuva e vento zerados a cada segundo | Excluir: quebra sincronização e visibilidade |
| `shadows` | CascadeShadows/RopeDrawShadow, valores 0/1 | Excluir: retirada completa e restauração não baseada em snapshot |
| `lights` | Blackout, distância de lanterna/luzes e distantlights | Excluir: altera informação visual do mundo |
| `broken` | Limpa todo vidro quebrado | Excluir: altera estado/evidência visual, não há ganho demonstrado |
| `unnecessary` | Limpa brief/GPS/prints/replay/leaderboards, foco/HD e timecycles | Excluir: não é “limpeza de RAM”; interfere em menus, câmeras e clima |
| `ped` | Limpa sangue, umidade, sujeira e dano visível | Excluir: interfere em evidência e aparência RP |
| `lowTexture` | LOD 0.6, desativa oclusão e decals por frame | Nome enganoso: não muda qualidade de textura; oclusão desativada pode piorar custo. Não portar |
| Export `setSetting` | Muda tabela e imprime variável global `value`, não o parâmetro informado | Bug de log e ausência de validação/apply/persist equivalente ao menu. Criar APIs novas |
| NUI callbacks | `changeOption`/`exitMenu` não respondem com callback no código recebido | Corrigir no projeto próprio: toda chamada responde |

Observações: configurações carregadas não passam pela mesma aplicação estática de sombras do callback; o loop “lights” não tem caminho de restauração em stop. Não há base para prometer ganho fixo. Nenhuma vantagem técnica em copiar o código ofuscado recebido.

## 2. Catálogo — Oxlyn

Fontes principais: `config.lua`, `client/{state,boost,fps,metrics,preview,adaptive,cleanup,hud,main}.lua`, `server/main.lua`, `shared/bridge.lua` e `html/js/{app,settings,charts,util}.js`.

| Grupo | Recursos/IDs catalogados | Melhor ideia / decisão Forge |
| --- | --- | --- |
| Perfis | `off`, `light`, `balanced`, `performance`, `extreme`, `potato`; perfis pessoais, overrides, limites/restrições | Perfis claros são úteis; não adotar modos que esvaziam o mundo |
| Sombras/detalhe | `shadowMode`, `shadowDistance`, `lodScale`, `entityLod`, `pedLodBudget`, `vehLodBudget`, `reduceModelBudget` | Não reduzir alcance de entidades/coberturas nem remover sombras por jogador |
| Superfícies/efeitos | `disableDecals`, `vehicleTrails`, `footstepTracks`, `oceanScaler`, `flatWater`, `motionBlur`, `screenBlur`, `filmGrain` | Não alterar água, rastros/evidências nem efeitos controlados por outros scripts |
| Luzes | `artificialLights`, `artificialLightsVeh`, `vehicleDistantLights`, `distantSirens` | Manter luzes, faróis e sinais de veículos/serviços |
| População | `pedDensity`, `vehicleDensity`, `parkedDensity`, `randomVehDensity`, `scenarioDensity`, `ambientVehRange`, `ambientPedRange`, `distantCars`, `randomCops`, `garbageTrucks`, `randomBoats`, `randomTrains`, `lowPriorityVehGens`, `dispatchServices`, `blockPedSpawns`, `blockParkedSpawns` | Excluir controles locais: população/despacho são política da cidade, não preferência gráfica |
| Visualsettings | `renderLodLights`, `renderCoronas`, `renderDistantLights`, `renderPuddles`, `renderPostFx`, `renderVehicleLights`; cache de valores originais | A ideia de capturar/restaurar é boa. Forge usa allowlist pequena de pós-processamento, sem luzes/poças/sirene |
| Clima/partículas | `forceClearWeather`, `killRain`, `killWind`, `particleCleanup`, `particleRadius` | Excluir; nem o modo de PC fraco recebe clima “melhor” |
| Limpeza | `cleanupEnabled`, `cleanupInterval`, `cleanupRadius`, `clearProjectiles`, `clearGlass`, `clearDecals`, `clearObjects`, `clearDeadPeds`, `clearEmptyVehicles` | A proteção por missão/anexo/modelo/controle ajuda, mas não prova que objeto é descartável. Não adotar remoção |
| FPS/frametime | Histograma de frametimes, médias, 1%/0,1% low, mediana, estabilidade, histórico e downsample | Excelente referência conceitual; implementar estatística própria limitada, sem copiar o algoritmo |
| Métricas do jogo | Pools, jogadores próximos, resolução, recursos iniciados, Lua heap e ping | Resolução/frametime são úteis. Não mostrar jogadores próximos num painel de FPS; evitar varreduras de pools |
| Métricas estimadas | CPU/GPU/RAM/VRAM heurísticas derivadas de frametime/entidades/recursos/resolução | Não são sensores. Não usar porcentagens como se fossem leituras reais |
| Benchmark | `RunPreview`, `KeepPreviewResult`, `CancelPreview`: baseline, settling, teste e reversão | Adotar ideia e acrescentar cancelamento por mudança de cenário, amostra mínima e sessões |
| Automático | `autoBoost`, `autoBoostFloor`, `autoBoostCeiling`, `autoBoostCooldown`, `alertLowFps`, `alertThreshold` | Histerese/cooldown úteis; Forge automático só ajusta bloom nos mesmos limites |
| Economia contextual | `pauseSaver`, `afkSaver`, `afkMinutes`, `interiorSaver` | Não adotar mundo vazio em AFK/interior. Em outra câmera/menu, suspender nossos ajustes |
| HUD | `hudEnabled`, `hudPosition`, `hudScale`, `hudOpacity`, `hudShowFrametime`, `hudShowLows`, `hudShowPing`, `hudShowGraph`, `hudShowEntities` | HUD opcional pequeno; sem renderização contínua de gráficos no navegador |
| Personalização UI | `uiAccent`, `uiAutoScale`, `uiScale`, `uiBlur`, `uiBackdrop`, `ui3d`, `uiAnimations`, `uiFloat`, `uiSounds`, `uiChartGlow`, `uiChartRange`, `uiLocale`, `uiShowEstimates` | Legibilidade/escala são úteis; eliminar efeitos decorativos caros, CDN e “flutuação” |
| Operação | Comandos, aliases, exports `GetFps`/`GetStats`/`GetMetrics`/`GetPreset`/`SetSetting`/`GetSetting` | APIs próprias e pequenas; nada de aceitar qualquer native/setting pelo navegador |
| Servidor/admin | Telemetria persistida por identificador, lista de players, forçar preset, `fpsreport`, `fpstelemetry`, exports de performance | Fora da primeira versão: diagnóstico local, sem dados pessoais/telemetria, sem forçar perfil de outro player |
| Framework | Detecção ESX/QB/QBX e fallbacks | Não duplicar bridge/framework; Forge FPS local não precisa consultar o núcleo |

### Pontos concretos de atenção

- O perfil `light` já limpa projéteis/vidros e reduz população. O rótulo “seguro” não basta para atestar neutralidade competitiva.
- `cleanup.canDelete` aceita entidade de rede quando há controle; “ter controle” não significa autorização para apagar o estado compartilhado de outro script. Objetos não networked também podem ser importantes em MLO/RP.
- No stop, o boost restaura diversos estados fixos (`true`, `1.0`, budgets `3` e dispatch ligado), que podem contrariar política de outro recurso.
- O guard `frameWorkNeeded` visível considera apenas densidade de peds. Um guard geral deve refletir todos os efeitos por frame necessários; não assumir que todo toggle declarado está sempre aplicado.
- `GetGamePool` e coleta de recursos não devem rodar sem necessidade; telemetria é habilitada por padrão nessa cópia. UI tick de 50 ms e HUD de 120 ms são custos dispensáveis para a nossa primeira versão.
- Coerção de valores precisa rejeitar NaN/infinito, além de limitar faixa. Dados vindos da NUI não devem ser tratados como válidos por serem locais.
- A comparação antes/depois é útil, mas mudanças na câmera, movimento, tráfego e temperatura do hardware tornam um teste pontual insuficiente para provar causalidade.

## 3. O que foi implementado do zero

1. Svelte 5 compilado, visual do Forge UI Kit e português brasileiro; sem runtime React, gráficos fictícios, fontes remotas ou blur da NUI.
2. Perfis Original/Leve/Equilibrado e ajuste pessoal, sempre na mesma allowlist. Padrão Original, sem alterações gráficas no primeiro uso.
3. Bloom com piso 65%; bokeh cinematográfico bloqueado por padrão e piso 75% se liberado pelo administrador. Nenhuma API genérica para “desbloquear” parâmetros perigosos.
4. FPS médio calculado por quadros/tempo, frametime e 1% low da média dos quadros mais lentos. Buffer circular limitado, histórico curto, UI a 1 Hz e coleta por frame sob demanda.
5. Comparação original/ajuste, acomodação, painel oculto, cancelamento por movimento/câmera/disparo/menu/morte, retorno automático e aceitação explícita posterior.
6. Persistência local versionada, validação de schema/faixas/tipos e callbacks NUI com sessão. Sem banco, servidor de telemetria ou coleta de hardware.
7. Restauração só dos valores ainda pertencentes ao Forge FPS; suspensão em câmeras/menus de outros recursos e export por origem para suspensão explícita.

## 4. Limites honestos

### Conclusão da etapa 1.3 — 20/10/2026

Ampliado para 77 controles, seis presets e quatro idiomas, com logo original do usuário. As exclusões antigas de população/luzes/água/rastros forçados foram reavaliadas sob a autorização administrativa posterior; a tabela atual em [CATALOGO-87.md](CATALOGO-87.md) prevalece sobre as decisões históricas abaixo. Limpeza destrutiva, clima, dados fictícios e overrides sem restauração definida continuam fora. Roteiro final: [RELEASE-1.3.md](RELEASE-1.3.md).

### Autorização posterior — versão 1.2

O usuário autorizou ajustes potencialmente vantajosos desde que o administrador controle a liberação. A análise anterior registra a decisão da primeira versão; o estado atual está em [CATALOGO-87.md](CATALOGO-87.md) e [ADMINISTRACAO.md](ADMINISTRACAO.md). Agora são 47 controles, política validada no servidor, densidades/LOD/decals por quadro e cinco parâmetros exclusivos com baseline declarada. Não há limpeza destrutiva nem falsa configuração de texturas.

### Ampliação 1.1

Contagem confirmada: `Config.Settings` da referência Oxlyn tem 87 entradas, mas várias são HUD/UI/automação ou remoção de informação do mundo. A versão 1.1 amplia para 34 controles próprios, incluindo 11 gráficos (quatro liberados por padrão e sete condicionados à política). A tabela completa de destino está em [CATALOGO-87.md](CATALOGO-87.md). As exclusões destrutivas continuam sem implementação; não basta mudar um booleano para executá-las. Testes de luzes/poças foram implementados separadamente, bloqueados por padrão, e não são classificados como neutros competitivamente.

O script não muda configurações de textura/MSAA/resolução nem “libera RAM”, não melhora CPU por apagar o mundo e não faz milagre em máquina limitada. Os poucos ajustes cosméticos podem gerar **ganho pequeno ou zero**. Esse é um compromisso deliberado com a exigência de não retirar informação do cenário. Mesmo alterações cosméticas devem ser avaliadas pelo administrador em combate, chuva/noite, interiores e equipamentos diferentes. Não há garantia universal de igualdade visual, nem mecanismo anti-cheat neste recurso.

Referências técnicas primárias: [Svelte](https://svelte.dev/docs/svelte/overview), [GetVisualSettingFloat](https://github.com/citizenfx/fivem/blob/master/ext/native-decls/GetVisualSettingFloat.md), [SetVisualSettingFloat](https://github.com/citizenfx/fivem/blob/master/ext/native-decls/SetVisualSettingFloat.md) e [Forge UI Kit](https://github.com/Framework-Forge/site).
