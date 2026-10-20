# Administração do Forge FPS · 1.3.1

O administrador decide quais opções os players podem configurar e até onde podem reduzi-las. Liberar uma opção **não aplica um perfil automaticamente**. O padrão continua conservador; as opções avançadas novas iniciam bloqueadas.

## Pelo painel

1. Abra `/fps` ou F10 e entre em **Administração**.
2. Ative a autorização da opção desejada e ajuste o mínimo permitido.
3. Clique em **Publicar permissões**. O servidor valida a permissão, os tipos, os limites e a revisão antes de gravar `admin-policy.json`.
4. Players recebem a nova política. Opção revogada volta ao estado neutro; valores abaixo do novo piso são limitados. Isso não grava por conta própria o KVP de cada jogador.

Permissões reconhecidas: ACE `forge.fps.admin` **ou** `forge-core.admin`, o mesmo ACE herdado pelo Forge Pause desta base. Não há alteração no Bridge/framework. Se a permissão acabou de mudar, use **Atualizar permissões**.

Exemplo opcional para um grupo já existente na sua configuração:

```cfg
add_ace group.admin forge.fps.admin allow
```

O grupo precisa realmente estar atribuído aos administradores. A regra acima não foi inserida automaticamente. Administrar só no cliente não basta: a gravação também confere o jogador no servidor. Isso controla o recurso legítimo, não é um anti-cheat contra clientes modificados.

## Onde ficam os padrões

`server/config.lua` é carregado somente no servidor. `Rules` pode definir autorizações iniciais. Uma política publicada em `admin-policy.json` prevalece sobre os padrões do arquivo. O JSON só é criado ao publicar de verdade; nenhum arquivo de dados de teste foi colocado na instalação.

```lua
Rules = {
    pedDensity = {allowed=true, min=0.5},
    vehicleDensity = {allowed=true, min=0.5},
    lodScale = {allowed=true, min=0.7},
}
```

Esses exemplos não são recomendação universal de equilíbrio. Teste cobertura, combate, trânsito, noite e interiores na sua base antes de liberar.

## Controles disponíveis

São **76 controles** em dez categorias; **46** dependem da política administrativa. Os outros 30 são HUD, interface e automação. O idioma agora é automático via PR Bridge. Há seis presets, incluindo Ultra leve, Notebook e Máximo permitido; todos respeitam as autorizações e pisos. Presets não ativam budgets reduzidos nem LOD de objetos locais. Veja a [revisão 1.3.1](REVISAO-1.3.1.md).

| Grupo novo | Aplicação | Restrição |
| --- | --- | --- |
| LOD | Distância/detalhe do cenário, por quadro | Pode alterar cobertura e visibilidade; mínimo obrigatório 65%, inclusive ao ler política antiga |
| NPCs/trânsito/estacionados/aleatórios | Multiplicadores de densidade ambiente, por quadro | Não apaga entidades já existentes; valores de 0 a 100% |
| Cenários interiores/exteriores | Multiplicadores separados, por quadro | A ordem da native é interior e depois exterior |
| Decals | Oculta a renderização neste quadro | Não apaga marcas, mas pode esconder evidências; só liberar conscientemente |
| Modelos de NPCs/veículos | Modo reduzido de orçamento | Exige controle exclusivo e baseline |
| Orçamentos de população | Nível inteiro 0–3 | Não é qualidade de textura; exige controle exclusivo |
| Sombras em cascata | Escala experimental do parâmetro de cascatas | Não é um seletor completo de qualidade de sombras; exige controle exclusivo |

Textura, MSAA e resolução reais permanecem no GTA. Não há um botão “texturas baixas” que apenas mude densidade/LOD e finja ser a mesma coisa.

## Parâmetros sem getter: controle exclusivo

Vinte parâmetros persistentes não oferecem getter para capturar o estado anterior, incluindo orçamento, luzes, geradores, rastros forçados, motion blur do ped, ruído e amostragem de sombras. Exigem autorização adicional em `FpsServerConfig.Exclusive`, `enabled=true` e baseline declarada. Escolhas como shadowMode exigem uma baseline válida da enumeração, não um número inventado.

Exemplo: se o responsável confirmou que nenhum outro recurso gerencia esse parâmetro e que o estado correto de retorno é `false`:

```lua
reducePedModels = {enabled=true, baseline=false}
```

Depois, ainda é necessário autorizar a opção no painel. A baseline é o valor declarado pelo administrador, **não** uma leitura da configuração original do GTA. Não habilite se outro recurso também administra o parâmetro. Quando o Forge FPS aplica um desses ajustes e depois é suspenso, retorna a essa baseline; quando não aplicou nada, não escreve um reset global.

Densidades/LOD/decals expiram por quadro: parar de chamar a native interrompe a sobreposição. NPCs que já nasceram não são apagados para simular reversão instantânea. Visualsettings com getter continuam usando captura/restauração condicionada ao valor ainda pertencente ao recurso.

## Bloom, automático e oscilação

O piso inicial continua em 65%, mas o administrador agora pode autorizar mínimos menores, inclusive 0%, por controle. Para desligar completamente uma camada, o piso combinado do bloom geral e daquela camada precisa permitir 0%. O painel mostra o mínimo autorizado para distinguir “barra no mínimo” de “efeito zerado”.

O automático muda somente bloom, até o mínimo permitido, com histerese e intervalo. Quando já está no piso, não há margem adicional. Um salto observado de 90 para 108 FPS não demonstra sozinho que o automático causou o ganho. O recurso não trava FPS; a meta é uma referência de ajuste, não um limitador.

Compare FPS médio, 1% low e frametime com o painel fechado, no mesmo local. Densidade muda a geração futura da população; uma comparação curta pode não estabilizar o cenário e não prova ganho sustentado. Não há garantia de FPS fixo ou de melhora em todo hardware.

## Fontes técnicas

- [LOD por quadro](https://github.com/citizenfx/natives/blob/master/STREAMING/OverrideLodscaleThisFrame.md).
- [Densidade de NPCs](https://github.com/citizenfx/natives/blob/master/PED/SetPedDensityMultiplierThisFrame.md) e [ordem dos cenários interior/exterior](https://github.com/citizenfx/natives/blob/master/PED/SetScenarioPedDensityMultiplierThisFrame.md).
- [Ocultação de decals por quadro](https://github.com/citizenfx/natives/blob/master/GRAPHICS/SetDisableDecalRenderingThisFrame.md).
- [Orçamento de população de NPCs](https://github.com/citizenfx/natives/blob/master/STREAMING/SetPedPopulationBudget.md), [modo reduzido de modelos](https://github.com/citizenfx/natives/blob/master/STREAMING/SetReducePedModelBudget.md) e [escala experimental de sombras](https://github.com/citizenfx/natives/blob/master/GRAPHICS/CascadeShadowsSetCascadeBoundsScale.md).
