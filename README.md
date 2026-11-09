# Forge FPS

Painel de desempenho local para FiveM com métricas reais de FPS/frametime, presets conservadores, HUD, benchmark antes/depois, automações e política administrativa server-side.

> **Documentação completa:** acesse o site oficial da Forge e abra **Scripts → forge-fps**.

## Recursos principais

- 76 controles organizados em 10 categorias.
- 6 presets: Original, Leve, Equilibrado, Ultra leve, Notebook e Máximo permitido.
- FPS, frametime, 1% low, histórico, ping real e contagens locais de entidades.
- Benchmark comparativo Original × ajuste candidato.
- Preferências locais persistentes por KVP.
- Política administrativa com ACE, permissões por opção e mínimos configuráveis.
- 20 parâmetros com controle exclusivo e baseline declarada pelo servidor.
- 4 exports client para integração com outros resources.
- Interface Svelte 5 em português, inglês, espanhol e francês.
- Integração de locale com o PR Bridge quando disponível.

## Instalação

```cfg
ensure forge-fps
```

Abra o painel com:

```text
/fps
```

ou pela tecla padrão **F10**.

## Administração

Permissões padrão:

```text
forge.fps.admin
forge-core.admin
```

A política publicada é persistida em `admin-policy.json` e define quais ajustes os jogadores podem utilizar e seus limites mínimos.

## Integração

```lua
exports['forge-fps']:Open()

local settings = exports['forge-fps']:GetSettings()
local metrics = exports['forge-fps']:GetMetrics()

exports['forge-fps']:SetSuspended(true)
exports['forge-fps']:SetSuspended(false)
```

## Documentação

A referência completa contém arquitetura, todas as categorias de configuração, presets, métricas, benchmark, permissões administrativas, política server-side, controle exclusivo, eventos, callbacks NUI, exports, desenvolvimento e regras de justiça visual.

**Site oficial:** https://framework-forge.github.io/site/

**Repositório:** https://github.com/Framework-Forge/forge-fps

---

Forge Project • Open Source • Brasil
