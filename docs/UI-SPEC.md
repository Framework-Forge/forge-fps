# Contrato visual — Forge FPS 1.3.1

## Revisão 1.3.1

Logo oficial PNG enviado pelo usuário, importado pelo Svelte e empacotado pelo Vite, sem redesenho. Seis cards de preset, com força limitada pela política administrativa e LOD nunca abaixo de 65%. Quatro idiomas completos (`pt-br`, `en-us`, `es`, `fr`) selecionados automaticamente pelo PR Bridge; identificação somente leitura na sidebar, sem seletor manual. Componentes de ajustes continuam com setas, vinte segmentos e valores preenchidos/negrito. Dez categorias e busca traduzida, preservando código técnico estável da opção. HUD separa FPS do último quadro (até 4 Hz) da média da janela (1 Hz); não inventa dados de hardware. Sons locais opcionais, sem arquivos de áudio remotos.

## Revisão 1.2 — autorização administrativa

47 controles em oito categorias, dos quais 24 sujeitos à política do servidor. Administração é a quarta seção, visível somente ao admin informado pelo servidor. Autorizações e mínimos têm rascunho/publicação separados das preferências pessoais. Atualizações de política invalidam preferências revogadas. Alterar categoria/seção mantém controles e cores; ao trocar seção a rolagem volta ao topo. Busca própria para permissões. Parâmetros sem getter ficam bloqueados até autorização de controle exclusivo no servidor; a interface nunca chama orçamento de modelos de “qualidade de textura”.

## Revisão 1.1 — controles solicitados pelo usuário

- 34 controles, cinco categorias e busca por código/nome; o cliente Lua envia os descritores, não há opções inventadas no frontend.
- Componente Svelte próprio: setas laterais, vinte segmentos laranja/cinza, valor preenchido em negrito/itálico e seletor de opções centralizado. Faixas continuam acessíveis por teclado com input range transparente sobre os segmentos. Estados desativados explicam o bloqueio.
- Descrições em uma coluna e controle na outra; empilha em telas menores. HUD e interface têm prévia local de aparência; gráficos só mudam ao salvar.
- `html`, `body` e `#app` sempre transparentes, inclusive antes do JavaScript; sem color-scheme dark na raiz. Escurecimento existe somente no overlay aberto. Nunca usar fundo opaco na página inteira para simular tema escuro.
- Tipos de teste de renderização claramente separados dos controles cosméticos; nenhum toggle na NUI libera a política administrativa.

## Base visual

Stack: Svelte 5 + Vite, saída estática empacotada para a NUI. Sem React em runtime, sem CDN, fontes externas, imagens das bases, blur de fundo ou animações contínuas. O Forge UI Kit atualmente é React; seus padrões visuais foram adaptados em componentes Svelte próprios.

Referência consultada: [Forge UI Kit](https://framework-forge.github.io/site/), código [src/index.css](https://github.com/Framework-Forge/site/blob/main/src/index.css) e componentes Button, Toggle e StatCard. Tokens: laranja `#FF7A1A`, hover `#FF8C2A`, fundo `#0A0A0C`, superfícies `#121214`/`#18181C`, bordas `#1F1F24`, texto secundário `#8E8E9F`, sucesso `#10B981`, aviso `#F59E0B`, erro `#EF4444`. Tipografia usa as famílias do kit se instaladas, com fallback system-ui offline. Não copia o site inteiro para a NUI.

Layout: painel até 1250 × 820 px, limitado à tela, sidebar de 222 px, três seções. Escala 8/12/16/24/32 px, cantos 8/10/16 px. Cards baixos e bordas discretas. Uma ação principal por bloco; fluxo completo por teclado, foco visível, ESC, confirmação para restaurar padrão. Área de conteúdo rola sem deslocar cabeçalho/rodapé. Resoluções-alvo 1280×720, 1600×900, 1920×1080 e ultrawide.

## Estados

- Fechado: nenhum painel NUI, timers de gráfico e animações ausentes; HUD apenas se o jogador escolheu.
- Sem amostras: `—` e “Aguardando amostras do jogo”. Nunca inventar FPS/hardware.
- Alterado: “Rascunho não salvo”; salvar aplica/persiste, descartar retorna ao estado publicado local.
- Aplicando: controles relevantes desabilitados e resposta de sucesso/erro explícita.
- Bloqueado: controle inativo com razão (política, native indisponível ou conflito com outro recurso).
- Benchmark: painel oculto e foco liberado; overlay pequeno, cancelamento por ESC ou /fps. Amostra insuficiente não oferece aplicar como resultado validado.
- Resultado: original/ajustado e diferença observada, com texto explícito de reversão. Nunca “ganho garantido”.
- Rede NUI falhou: aviso e nova tentativa, sem declarar persistência.
- Resposta antiga: sessão/epoch impedem reabrir tela encerrada.

## Verificação

Verificar navegação, teclado, modais, bloqueios, persistência simulada, mensagens da Lua e ausência de erros em Chromium. Testes de navegador não comprovam ganho de FPS ou visibilidade no GTA. Este contrato é específico do recurso Forge FPS.
