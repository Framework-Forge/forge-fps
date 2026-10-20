# Forge FPS 1.3.1 — revisão após teste em jogo

## O que mudou

- HUD usa o último `GetFrameTime`, publicado até quatro vezes por segundo, como **FPS atual**. A média da janela (normalmente 10 s) aparece identificada separadamente; painel, gráfico e automático continuam usando a média. Não suaviza o FPS atual para simular estabilidade. A janela e a frequência de atualização do contador externo podem ser diferentes, portanto não há promessa de números idênticos.
- A mesma janela é agregada/ordenada no máximo uma vez por segundo e reutilizada pelo gráfico. Amostras usam arrays numéricos em vez de criar uma tabela por quadro; há proteção opcional contra dupla amostragem de um mesmo frame. Sem HUD/painel/automação/alerta/teste, não coleta quadros nem agrega estatísticas.
- Com o painel fechado, mensagens de medição não carregam todo o estado dos controles; não gera histórico se o gráfico estiver desligado. O evento de bloqueio de NPCs não mantém uma rotina por quadro sozinho. Cada visualsetting é lida uma vez por aplicação, mantendo a checagem de propriedade e restauração.
- **LOD global e de objetos: mínimo obrigatório de 65%.** Políticas antigas com mínimo inferior são normalizadas em memória sem apagar permissões ou regravar `admin-policy.json`. Preferências antigas são migradas ao carregar; as demais configurações são preservadas.
- Presets mantêm os budgets de modelos/população na baseline e deixam LOD de objetos em 100%. Não ativam varredura de objetos locais. Os controles manuais continuam disponíveis sob autorização; LOD manual também não passa abaixo de 65%. A varredura explícita é espaçada em cinco segundos e evita reescrever valores iguais.
- Idioma automático pelo PR Bridge, sem modificar o Bridge: consulta local `GetCachedState('locale').data.name`, com os mesmos convars de fallback de seu módulo legado de locale. Normaliza pt/pt-BR → pt-br, en/variações → en-us, es/variações → es e fr/variações → fr; outros idiomas usam en-us. Reconsulta no máximo a cada cinco segundos ou ao abrir. Se o Bridge estiver reiniciando, mantém o último idioma conhecido. A antiga preferência manual é ignorada, não sobrescreve o idioma do servidor nem altera rascunhos ao atualizar.
- Ondas, pneus e pegadas permanecem disponíveis e respeitam as autorizações/baselines. Desativar os controles de rastros forçados não apaga rastros normais ou evidências. Não foi inserida uma limpeza destrutiva.

## Revisão do 17mov

Análise do comportamento das chamadas, sem copiar o código do produto:

| Recurso observado | Decisão no Forge |
| --- | --- |
| LOD fixo em 60%, chamado de lowTexture | Usar LOD real com piso de 65%; não é qualidade de texturas. |
| Desativar oclusão | Não incorporar. Desligar occluders pode aumentar o que precisa ser renderizado; a documentação oficial avisa sobre impacto em máquinas fracas. |
| Ocultar decals por quadro | Equivalente manual existente, condicionado ao administrador; pode esconder informação visual. |
| Alterar sombras e luzes | Equivalentes parametrizados existentes; não importar o reset global de sombras a cada clique em qualquer opção. |
| Gravar preferências e aplicar controles persistentes ao mudar opção | Já existente: persiste só ao salvar; setters persistentes só mudam quando o valor muda, com baseline explícita. |
| Limpar foco, timecycle, GPS, blur, partículas, sangue, sujeira, vidro; mudar chuva/vento | Não incorporar: conflitos com outros recursos, evidências e clima. Não é uma otimização neutra. |

Logo, a revisão não adiciona mais botões repetindo as mesmas natives. Corrige medição, reduz trabalho do próprio recurso e evita o conjunto agressivo de budgets/LOD nos presets.

## Validação e teste no FiveM

Verificados localmente: sintaxe Lua, validação/permissões, migração de pisos sem perda de regras, seis presets, idiomas automáticos, estatísticas, restauração, benchmark/cancelamento, UI compilada e quatro idiomas no navegador. Testes simulados não medem custo do motor GTA ou ganho real de FPS.

1. Reinicie somente `forge-fps` quando for testar. Não execute os boosters de referência ao mesmo tempo. O desenvolvimento não reiniciou recursos nem alterou arquivos de configuração/política do usuário.
2. Comece com Original. Para isolar custo, desligue ping/entidades/gráfico/alertas/automático. Teste também com a HUD toda desligada e use o contador externo/monitor de recursos do FiveM; isso evita confundir custo de medição com efeito gráfico.
3. Compare Original e os ajustes que já ajudaram (ondas/rastros) no mesmo local/câmera, após aquecimento do streaming. Repita ao menos três vezes com painel fechado. Considere média, 1% low e frametime; população e streaming podem variar durante o teste.
4. Verifique que 65% é o mínimo disponível no LOD e que os presets não reduzem budgets. Prefira escolher um preset e ajustar um efeito por vez, salvando somente o que ajudar no seu hardware.
5. Mude o idioma na ferramenta responsável do PR Bridge e reabra o painel; não deve existir seletor manual no Forge FPS. Nenhum restart/alteração do Bridge foi feito.

FPS livre continua oscilando conforme a cena. Este recurso não é limitador de quadros e não promete +10/+15 FPS, estabilidade fixa ou eliminação de gargalos de CPU, GPU, streaming, temperatura e outros scripts. O relato de ganho do usuário não foi reproduzido em execução nativa nesta revisão.

Fontes primárias: [GetFrameTime](https://github.com/citizenfx/natives/blob/master/MISC/GetFrameTime.md), [GetFrameCount](https://github.com/citizenfx/natives/blob/master/MISC/GetFrameCount.md) e [DisableOcclusionThisFrame](https://github.com/citizenfx/natives/blob/master/GRAPHICS/DisableOcclusionThisFrame.md).
