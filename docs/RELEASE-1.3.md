# Forge FPS 1.3.0 — roteiro para testes

Histórico da entrega 1.3.0. A [revisão 1.3.1](REVISAO-1.3.1.md) substitui o seletor de idioma por detecção automática, estabelece piso de LOD de 65% e revisa presets/medição. Para os testes atuais, siga a revisão.

## Entregue nesta etapa

- Logo oficial fornecido pelo usuário, sem redesenhar ou alterar a imagem.
- Idiomas `pt-br`, `en-us`, `es` e `fr`: navegação, catálogo, descrições, presets, permissões, estados e avisos. Seleção com prévia; **Salvar ajustes** grava o idioma localmente. Fechar sem salvar descarta o rascunho, inclusive o idioma.
- Seis presets: Original, Leve, Equilibrado, Ultra leve, Notebook e Máximo permitido. Os três novos atuam nas opções autorizadas; não liberam permissões. Máximo permitido usa os pisos publicados pelo administrador. Nenhum promete FPS fixo ou ganho em todo hardware.
- 77 controles em dez categorias; 46 opções sujeitas à política administrativa. Novas opções de geração ambiente, luzes, sombras, rastros forçados, ondas e LOD limitado a objetos ambientes locais.
- Ping real consultado no servidor sob demanda; contagem real de pools locais, no máximo a cada cinco segundos quando solicitada. Não estima CPU/GPU/RAM/VRAM.
- Sons discretos locais; economia AFK/interiores apenas no bloom. Economia na pausa interrompe a coleta e oculta o contador na pausa nativa; a suspensão de efeitos durante outras cenas continua obrigatória.
- Preferências anteriores, permissões publicadas e configurações do administrador preservadas. Nenhum reset de `admin-policy.json`.

## O que continua intencionalmente fora

Não são 87 funções gráficas: a referência mistura interface, automação e ações sem reversão segura. A tabela [CATALOGO-87.md](CATALOGO-87.md) registra cada destino.

- Apagar objetos, veículos, peds, projéteis ou evidências; limpar partículas por raio. Implementar isso exige autorização específica e regras de propriedade/impacto diferentes das opções visuais. Não existe uma limpeza destrutiva escondida aguardando um toggle.
- Forçar clima limpo, remover chuva ou vento: não competir com o sincronizador de clima do servidor.
- Desligar blur global de outros recursos, forçar perda de foco de streaming, estimativas de hardware fictícias e decoração 3D/blur da interface que aumente seu custo.
- `ambientPedRange` só é utilizável se a native correspondente existir na instalação. Caso ausente, o painel mostra indisponível em vez de executar um hash adivinhado. O mesmo tratamento vale para todas as natives/chaves opcionais.
- Qualidade real de texturas, MSAA e resolução continuam no menu do GTA; budgets e LOD não são a mesma coisa.
- Dispatch de emergência nativo continua fora: seus serviços podem ter estados diferentes e serem controlados por outros recursos. Não aplica um reset global de todos os serviços.

## Como começar

1. Reinicie apenas `forge-fps` quando você decidir testar; o desenvolvimento não reiniciou nada.
2. Abra `/fps`. Confira logo e os quatro idiomas. Salve um idioma, feche/reabra e teste persistência.
3. Selecione Original e registre FPS médio, 1% low e frametime com painel fechado. Compare com os demais no mesmo local, câmera e condições. No caso de população, aguarde a geração de novas entidades estabilizar; não conclua ganho com um teste curto.
4. Em Administração, autorize somente o que pretende testar e publique os mínimos. Teste Ultra leve, Notebook e Máximo permitido antes/depois da autorização: opções bloqueadas não podem mudar.
5. **Vinte parâmetros sem getter** exigem ainda `Exclusive.enabled=true` e baseline em `server/config.lua`. Os quinze controles novos desse tipo começam bloqueados. As cinco autorizações anteriores do usuário não foram redefinidas. Leia [ADMINISTRACAO.md](ADMINISTRACAO.md) antes de autorizar outros.
6. Teste dia/noite/chuva/interiores/combate/veículos, inclusive scripts de blackout e mar. Iluminação e ondas podem mudar gameplay. Se outro recurso controla esses parâmetros, mantenha-os bloqueados ou use suspensão explícita.
7. Ative ping e entidades separadamente e confira a latência/custo da própria medição. São informações reais e podem atrasar alguns segundos; não são otimizações gráficas.
8. Teste economia AFK e retorno por entrada/movimento/câmera; economia em interiores só pode mudar bloom. Nenhuma delas é limitador de FPS, anti-AFK do servidor ou alteração de população automática.
9. Revogue uma opção durante o uso em outro cliente; deve retornar ao neutro/baseline. Original, restauração e suspensão não podem deixar overrides do recurso ativos.

## Limites de restauração

Visualsettings e ondas usam captura e restauração condicionada ao último valor escrito. LOD de objetos é limitado a objetos próximos, não missão e fora da rede: nunca peds, veículos ou entidades de jogador; a varredura é limitada e restaura valores capturados quando ainda pertencem ao recurso. Não cria garantia absoluta de que um objeto sem tag de missão seja dispensável; por isso a opção depende do administrador.

Parâmetros sem getter retornam à baseline explicitamente declarada, não a uma leitura inexistente do estado anterior. Os geradores de população afetam criações futuras; não apagam entidades já existentes para fingir reversão instantânea. Rastros forçados são controles de força da native, não promessas de remoção dos rastros normais.

## Validação

Sintaxe Lua, schema, permissões, presets, restauração, argumentos das natives, orçamentos inteiros, baselines, testes de automação/diagnóstico e interface compilada verificados localmente com dados simulados. Traduções conferidas no catálogo e navegador nos quatro idiomas, com verificações de persistência e layout. Nenhum ganho de FPS, disponibilidade de todas as natives ou neutralidade visual foi comprovado no GTA nesta etapa; cabe ao teste em jogo.

Fontes primárias: [amostragem de sombras](https://github.com/citizenfx/natives/blob/master/GRAPHICS/CascadeShadowsSetShadowSampleType.md), [ondas: leitura](https://github.com/citizenfx/natives/blob/master/WATER/GetDeepOceanScaler.md) e [escrita](https://github.com/citizenfx/natives/blob/master/WATER/SetDeepOceanScaler.md), [LOD: leitura](https://github.com/citizenfx/natives/blob/master/ENTITY/GetEntityLodDist.md) e [escrita](https://github.com/citizenfx/natives/blob/master/ENTITY/SetEntityLodDist.md), [geração de população](https://docs.fivem.net/docs/scripting-reference/events/list/populationPedCreating/), [blackout](https://github.com/citizenfx/natives/blob/master/GRAPHICS/SetArtificialLightsState.md) e [sirene ambiente](https://github.com/citizenfx/natives/blob/master/AUDIO/DistantCopCarSirens.md).
