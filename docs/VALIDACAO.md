# Validação local — 20/10/2026

Versão: 1.3.1 — 20/10/2026. Interface compilada em `web/dist`. Nenhum restart, alteração de `server.cfg`, banco ou configuração real de jogador foi realizado. O `admin-policy.json`, `config.lua` e `server/config.lua` existentes do usuário foram preservados.

## Fechamento da revisão 1.3.1

- 76 controles, dez categorias, seis presets e 46 autorizações administrativas. Vinte parâmetros sem getter exigem baseline/controle exclusivo. Testes usam configurações conservadoras em memória, sem reverter as autorizações já alteradas pelo usuário.
- Lua: 1393 verificações por cenário (KVP novo/corrompido), 40 específicas de política, 38 de funcionalidades e 82 da revisão (janela média/atual, cache, duplicação de frame, LOD 65%, migração, presets, idioma via Bridge, ausência de leituras visuais duplicadas e loop de população). Incluem passos simulados do agendador; contagem não equivale a cenários independentes.
- Svelte check: 0 erros / 0 avisos. Build estático com o logo PNG original fornecido, sem alteração de imagem. JS aproximado 131 kB, CSS 17 kB, PNG 61 kB (antes de compressão).
- Browser sobre UI compilada: carregamento do logo, 76 controles, 46 regras administrativas, seis presets, publicação/revogação, estados de comparação, idioma automático sem gravação/seletor, labels/descrições traduzidos, layouts desktop e transparência inicial/fechada. HUD mostra 69 FPS atuais com média de 72; um update rápido de 50 não altera a média de 72.
- Conferência de tradução: todas as labels/descrições/opções do catálogo e textos estáticos da interface têm entradas para inglês, espanhol e francês; nomes de marca, siglas, códigos de native e nomes próprios de idiomas não são traduzidos.
- APIs opcionais ausentes ficam indisponíveis; em particular `ambientPedRange` depende da instalação. Não foi validado suporte de todas as natives no artifact GTA do usuário nem ganho/estabilidade de FPS em hardware real.

Os resultados das primeiras etapas abaixo são histórico. Para o roteiro atual, seguir [REVISAO-1.3.1.md](REVISAO-1.3.1.md).

| Verificação | Resultado |
| --- | --- |
| Sintaxe Lua 5.4 de manifesto/config/schema/cliente | Passou |
| Política: opções desconhecidas, NaN/infinito/faixas e bloqueio do bokeh | Passou |
| Estatísticas: FPS por tempo total, 1% low de frames lentos, p95, limite e expiração do buffer | Passou |
| Render: Original sem escrita, escala sem acumulação, captura/restauração e respeito a valor de outro recurso | Passou |
| Runtime simulado: abertura/foco, sessões vencidas, persistência, KVP corrompido, coleta ociosa e exports por origem | Passou |
| Benchmark simulado: duas fases, amostra, reversão, não persistência, cancelamento por movimento e outra NUI | Passou |
| Svelte check | 0 erros / 0 avisos |
| Build Vite | Passou; JS aproximado 66 kB, CSS 17 kB, antes de compressão |
| Navegador: perfis, rascunho/salvar, HUD, controles bloqueados, erros e resposta tardia | Passou |
| Navegador: overlay/fases/resultado de comparação | Passou com fronteira NUI simulada |
| Layouts 1280×720, 1600×900, 1920×1080 e 2560×1080 | Sem overflow horizontal dos controles; conteúdo com rolagem |
| Ativos de runtime | Sem CDN, fonte externa ou telemetria |
| 47 controles / oito categorias | Conferidos; busca, setas, segmentos e salvamento com schema Lua |
| Schema ampliado | Testes de tipo/faixa/NaN de todos os controles; KVP antigo recebe padrões novos sem escrita automática |
| Bloom por camadas | Independência e piso combinado de 65% passaram |
| Bokeh / renderização | Bloqueio por política, chave ausente, liberação explícita e restauração simulada passaram |
| HUD ampliado | Escala/opacidade/frametime/gráfico e persistência passaram no navegador |
| Aviso de FPS baixo | Opt-in, persistência, pausa externa e ausência de alteração gráfica passaram |
| Transparência da NUI | Imagens RGBA completamente transparentes ao iniciar e depois de fechar; raiz sem esquema dark |
| Auditoria npm das dependências fixadas nesta instalação | Nenhuma vulnerabilidade reportada nessa consulta |

As verificações de Lua usam natives simuladas; o navegador usa a UI Svelte realmente compilada e respostas NUI simuladas. Isso não comprova FPS em hardware real, suporte de todas as chaves visuais em todo artifact GTA nem neutralidade visual em cada servidor.

Runtime Lua: 1323 verificações em cada cenário (KVP novo e corrompido), incluindo passos do agendador simulado. Teste adicional de servidor/performance: permissões, revisão concorrente, limites, revogação, falha de gravação, controle exclusivo/baselines, floats, budgets inteiros e ordem interior/exterior. A transparência continua explícita no HTML antes do JavaScript e validada ao iniciar/fechar.

## Ampliação administrativa 1.2

- Aba Administração só aparece para o admin informado pelo servidor; gravação também confere ACE no servidor. Testado ACE herdado `forge-core.admin`, acesso negado a player comum e falhas de persistência sem alteração da política.
- 24 autorizações por opção; mínimos numéricos; publicação revisionada; atualização do cliente sem forçar preset. Todos os testes novos usaram dados em memória, sem criar `admin-policy.json` real.
- Oito controles por quadro e cinco persistentes exclusivos. Testadas restauração/suspensão, argumentos corretos e Original neutro. Não foi validado ganho de FPS ou equilíbrio visual no GTA.
- Browser: edição/publicação administrativa, liberação de densidade, mínimo, preferência local, revogação e perda da permissão administrativa passaram com fronteira NUI simulada.
- Camada de autorização não é anti-cheat contra clientes modificados. Não foi alterado Bridge, clima, Pause ou configuração real de ACE.

**Tela preta:** o sintoma específico do CEF/FiveM não foi reproduzido em Chromium headless. Foi removido o esquema dark da raiz e garantida transparência inicial, além do sincronismo de fechamento quando a NUI fica pronta. A correção foi entregue, mas a confirmação no jogo depende do teste do administrador; não declarar o defeito definitivamente resolvido somente pelo navegador.

## Pendente antes da liberação

Seguir [TESTES.md](TESTES.md) no FiveM. Confirmar disponibilidade/efeito do bloom no artifact instalado, visibilidade em combate/noite/chuva, convivência com Forge Pause/câmeras e repetir comparações na mesma cena em máquinas fracas e médias. Registrar “sem ganho consistente” se a diferença não se sustentar. O desfoque cinematográfico permanece bloqueado por padrão.
