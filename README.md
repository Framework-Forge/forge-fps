# Forge FPS · 1.3.1

Painel local em **Svelte 5**, com o padrão visual do [Forge UI Kit](https://framework-forge.github.io/site/). Implementação própria; as bases fornecidas foram apenas analisadas e não são carregadas. Sem dependência de banco ou mudanças no PR Bridge; o idioma acompanha a configuração existente do Bridge por leitura do export `GetCachedState('locale')`.

## Instalação e uso

O pacote já inclui a interface compilada em `web/dist`. Adicione ao `server.cfg` quando for testar:

```cfg
ensure forge-fps
```

Abra com **`/fps`** ou **F10** (configurável em `config.lua`; a tecla pode ser remapeada nas configurações FiveM). Não execute os dois boosters de referência junto. A pasta `[base de dados]` não pertence ao pacote publicado: não a inclua na release nem a inicie como categoria de recursos. Nenhum recurso foi reiniciado nem o `server.cfg` foi alterado automaticamente.

O perfil inicial **Original** não altera os gráficos. Leve e Equilibrado reduzem somente pós-processamento cosmético dentro dos limites conservadores. Ajustes personalizados precisam de **Salvar ajustes**. Preferências são locais neste computador, em KVP versionado do recurso, não por personagem/servidor nem em banco. **Restaurar padrão** retorna ao perfil Original, desligando contador e automático.

### O que está disponível

- Seis perfis: Original, Leve, Equilibrado, Ultra leve, Notebook e Máximo permitido; os três últimos usam as opções autorizadas e respeitam os mínimos do servidor.
- 76 controles em dez categorias, com busca, setas, barras segmentadas e valores em negrito. O seletor manual de idioma foi retirado; o schema Lua é a fonte do catálogo enviado à interface.
- LOD global e LOD de objetos nunca abaixo de 65%, inclusive com política antiga. Presets não reduzem os orçamentos de modelos nem ativam varredura de objetos locais; esses testes permanecem manuais e dependentes do administrador.
- 11 controles gráficos: bloom geral + três camadas, tamanho/intensidade do bokeh e cinco grupos experimentais de renderização. Quatro controles de bloom liberados por padrão; bokeh e experimentais dependem da política publicada pelo administrador.
- Pisos iniciais de bloom 65% e bokeh 75%; o administrador pode autorizar mínimos menores, inclusive zero. O painel informa quando o efeito não existe ou está em conflito.
- HUD: FPS do último quadro (`1000 / frametime`) publicado no máximo a cada 250 ms, com a média da janela identificada separadamente. Painel: FPS médio, tempo médio de quadro, 1% low e histórico das últimas 60 atualizações. Contadores com janelas distintas não precisam coincidir. Sem porcentagens fictícias de CPU/GPU/memória.
- Contador em quatro cantos, escala/opacidade, frametime, 1% low, gráfico, amostras, ping real e contagens locais de entidades sob demanda.
- Escala/contraste/destaque do painel, fundo ajustável e gráfico de 15/30/60 atualizações. Prévia de aparência local; descartar/fechar não publica o rascunho.
- Ajuste automático com limites inferior/superior e cooldown configuráveis, **somente no bloom**. Aviso opcional de FPS baixo persistente, sem aplicar perfil por conta própria.
- Comparação antes/depois, com acomodação entre fases, painel oculto, retorno automático e aplicação posterior explícita.
- Suspensão quando outra câmera/menu toma a cena; visualsettings restauradas por propriedade e parâmetros sem getter somente sob controle exclusivo com baseline declarada.
- Administração de permissões por opção e mínimo, com validação/persistência no servidor, revisões concorrentes e revogação para os clientes. Reconhece `forge.fps.admin` ou `forge-core.admin`.
- Densidades/geradores de população, LOD, decals, orçamentos, luzes, água e amostragem de sombras sob autorização. Vinte parâmetros sem getter exigem controle exclusivo e baseline declarada.
- Economia AFK/interiores no bloom, sons opcionais e interface automática em português brasileiro, inglês americano, espanhol e francês. O logo usa a imagem oficial enviada pelo usuário.

### Justiça visual e limitações

Não há remoção direta de entidades/props/vegetação/colisão, mudança de clima, limpeza de partículas/evidências/rastros/projéteis. LOD, população, renderização de decals e escala experimental de sombras podem ser autorizados pelo administrador; não são neutros competitivamente. Não limpa o mapa, “libera RAM”, aumenta alcance visual nem altera o relógio. Não interfere no Renewed-Weathersync.

Luzes de LOD, coronas, iluminação distante, poças e luzes dos veículos estão implementados como **testes bloqueados por padrão**. A liberação final ocorre na aba Administração, validada no servidor; `Config.TestEffects` é apenas padrão inicial. Eles podem afetar visibilidade e não são considerados neutros para competição. `Config.AllowCinematicBlur` é o padrão inicial dos dois controles de bokeh; a política publicada prevalece. Avalie noite/chuva/combate antes de liberar aos players. Original nunca aplica esses grupos, mesmo quando liberados.

As **87 opções** da referência não são 87 controles gráficos: incluem HUD, interface, automação e funções incompatíveis com a política. Veja [CATALOGO-87.md](docs/CATALOGO-87.md). Não há controles fictícios fingindo implementar funções excluídas.

**Ganhos podem ser pequenos ou nulos**, sobretudo em gargalos de CPU/servidor. Máximo permitido usa os limites administrativos, não um desbloqueio indiscriminado. Ajustes de bloom/bokeh são cosméticos, mas ainda precisam da avaliação de visibilidade do administrador em armas, interiores, chuva/noite e placas gráficas distintas. Não é anti-cheat nem garantia universal de igualdade visual. Não altera textura, MSAA, resolução ou configurações de driver; essas opções continuam no próprio GTA.

## Comparação de desempenho

Em **Uso responsável → Comparar ajuste atual**, fique parado e mantenha a câmera. O teste mede o original e o candidato por 10 s cada, com 2 s de acomodação antes de cada fase. ESC ou `/fps` cancela; movimento maior que 3 m, giro maior que 15°, disparo, morte ou outra câmera/menu também cancelam. O personagem não é teleportado nem congelado.

Ao concluir/cancelar, a configuração anterior volta sem gravar a candidata. Só **Usar ajuste testado** aplica e salva. O resultado requer ao menos 60 quadros em cada fase. O 1% low é `1000 / média dos 1% frametimes mais lentos`; FPS médio é `quadros / tempo total`. Inclui travadas válidas até 10 s, em vez de esconder frames ruins. A janela é limitada a 4096 quadros; a coleta de comparação tem limite de 10000 por fase. Um teste pontual não isola temperatura, streaming, tráfego e outros scripts: repita a mesma rota/cena e use também o monitor de recursos FiveM.

## Integração com outros recursos

Exports **cliente**:

```lua
exports['forge-fps']:Open()
local preferences = exports['forge-fps']:GetSettings() -- cópia
local performance = exports['forge-fps']:GetMetrics() -- amostras locais; ready=false se não houver coleta

-- Exemplo: outra câmera/cena já controla o visual.
exports['forge-fps']:SetSuspended(true)
-- Ao encerrar essa cena:
exports['forge-fps']:SetSuspended(false)
```

Cada recurso tem sua própria suspensão; um não libera a suspensão de outro. Parar o recurso de origem remove sua suspensão. O modo automático não é uma política de população e nunca muda preferências de outro jogador. Não há export genérico para executar natives ou alterar opções proibidas. Em sobreposição visual intencional de outro recurso, prefira a suspensão explícita; o Forge FPS não consegue coordenar todo recurso desconhecido.

## Interface e desenvolvimento

`web/src` contém o código Svelte original. Para recompilar (Node compatível com Vite 8):

```powershell
Set-Location -LiteralPath 'E:\[FIVEM]\Forge-Core\resources\[forge]\forge-fps\web'
npm ci --ignore-scripts
npm run check
npm run build
```

`npm run dev` oferece prévia em `127.0.0.1`; nela não são inventadas medições nem executado benchmark. O FiveM usa apenas o resultado estático compilado, sem precisar Node/npm no servidor. Sem fontes/CDNs ou chamadas HTTP de telemetria em runtime. Não distribua `node_modules` ou `[base de dados]`.

## Documentação e validação

- [Catálogo e comparação detalhada das duas referências](docs/ANALISE-REFERENCIAS.md).
- [Destino das 87 opções da referência](docs/CATALOGO-87.md).
- [Administração, novos ajustes e controle exclusivo](docs/ADMINISTRACAO.md).
- [Novidades, limites e testes da versão 1.3](docs/RELEASE-1.3.md).
- [Revisão 1.3.1: medição, custo, qualidade e 17mov](docs/REVISAO-1.3.1.md).
- [Contrato de interface](docs/UI-SPEC.md).
- [Roteiro de testes no FiveM](docs/TESTES.md).
- [Resultado das verificações locais](docs/VALIDACAO.md).

As verificações automatizadas locais cobrem Lua, política/validação, restauração, sessões NUI e navegador. **Não equivalem a teste nativo de FPS no GTA**. A primeira versão mantém o comportamento conservador para os testes do administrador antes de liberar aos jogadores.
