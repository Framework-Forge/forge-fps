# Teste em jogo — Forge FPS 1.3.1

## Testes finais desta etapa

Seguir [REVISAO-1.3.1.md](REVISAO-1.3.1.md). Conferir os quatro idiomas pelo PR Bridge, logo oficial, seis presets e LOD mínimo de 65%. Confirmar que a HUD separa último quadro da média. Testar cada opção por vez antes de combinar Máximo permitido. Comparar com painel fechado, repetir a cena e observar 1% low/frametime, não apenas o FPS instantâneo.

Para água/luzes/geração ambiente, testar suspensão e retorno de Original com as baselines corretas. Parâmetros sem getter devem ficar bloqueados sem controle exclusivo. Não iniciar os boosters de referência junto. Não usar o recurso para apagar entidades, interferir no clima ou modificar resolução de texturas.

## Nova etapa: administração e ajustes avançados

1. Admin com `forge-core.admin` ou `forge.fps.admin`: abrir Administração. Player comum não deve ver a aba nem conseguir publicar pela chamada direta do evento.
2. Autorizar densidade com piso 50%, publicar e abrir o painel em outro cliente: mínimo 50%, ajuste local permitido. Revogar: parar a sobreposição e voltar ao neutro, sem apagar NPCs existentes.
3. Dois admins: o primeiro publica; o segundo com revisão antiga não pode sobrescrever. Recarregar e conferir as regras persistidas. Não simular falha de disco no servidor real; esse caso já foi testado em memória.
4. LOD e decals: avaliar combate/cobertura/evidências em ambiente de teste antes de liberar. Confirmar que sair/Original/suspensão interrompem as chamadas por quadro sem limpar entidades ou marcas.
5. Controles exclusivos: sem `Exclusive.enabled`, devem permanecer bloqueados mesmo que uma regra permita. Só testar após identificar os recursos que já controlam cada parâmetro e declarar baseline correta. Ao suspender/restaurar, conferir essa baseline, não presumir captura do original.
6. Bloom zero só após autorização dos mínimos correspondentes. Barra no mínimo inicial representa 65%, não efeito desligado. Automático já no piso não gera redução adicional.
7. Comparar Original/personalizado com painel fechado. Registrar média, 1% low e frametime. Densidade pode demorar a mudar a população; não usar um teste curto como prova de ganho sustentado. Nenhuma opção é um limitador de FPS.

## Prioridade desta revisão

- Iniciar o recurso sem abrir `/fps`: o mundo deve continuar visível, sem fundo preto/cursor. Abrir, fechar e repetir; testar também com HUD desligado/ligado e após reinício autorizado.
- Conferir os 34 controles nas cinco categorias; buscar pelo nome ou código. Setas e teclado devem ajustar, segmentos devem acompanhar e valores devem aparecer preenchidos/em negrito.
- Alterar bloom por camadas, salvar/reabrir, descartar e restaurar Original. Repetir com controles gráficos combinados: piso não pode cair abaixo de 65%.
- HUD: quatro cantos, escala/opacidade, frametime, 1% low, gráfico e amostras. Interface: escala, contraste, destaque, fundo e janela do gráfico. Fechar sem salvar precisa descartar a prévia.
- Automação: limites inferior/superior coerentes, cooldown e aviso com persistência. Aviso não deve aplicar um perfil. Desligar HUD, automático e aviso deve desativar a coleta por quadro quando o painel fechar.
- `Config.AllowCinematicBlur` e `Config.TestEffects` continuam bloqueados por padrão. Só testar liberação em ambiente controlado; comparar chuva/noite/sirene/faróis/combate antes de pensar em liberar aos players. Chave não suportada deve mostrar indisponível, nunca causar spam no console.
- Ao sair de câmera/painel externo, suspensões devem ser liberadas por origem sem sobrescrever efeito de outro recurso. Nenhuma alteração no PR Bridge, Forge Pause ou clima é necessária.

## Roteiro geral

Não iniciar os recursos de referência. Carregar apenas o novo `forge-fps` quando autorizado pelo responsável do servidor.

1. Abrir `/fps`, fechar por ESC e F10; verificar cursor/controles liberados. Abrir outro menu, confirmar que não rouba seu foco.
2. Primeiro uso: perfil Original, sem alterações visuais. Escolher Leve e Equilibrado. Conferir que nenhum objeto/NPC/jogador/veículo/cobertura, luz, sombra, fumaça ou clima desapareceu. Testar dia/noite/chuva, indoors/outdoors e armas com mira.
3. Personalizar bloom, salvar, reabrir/reconectar e conferir o mesmo valor. Descartar um rascunho não deve aplicar. Restaurar padrão precisa desligar contador e automático.
4. HUD em quatro cantos; conferir resolução 720p, 1080p, 1440p e ultrawide, sem sobrepor a HUD da cidade. Desligar contador e automático: verificar custo ocioso no monitor de recursos, sem afirmar custo zero.
5. Benchmark parado: 10 s de original e 10 s de candidato, mais acomodação. Comparar original/ajustado, low1 e média. Resultado volta ao anterior; aceitar exige ação própria. Repetir pelo menos três vezes na mesma cena e registrar resultados reais.
6. Cancelar benchmark por ESC, `/fps`, movimento >3 m, giro >15°, disparo, morte e abertura de outra NUI/câmera. Confirmar retorno ao ajuste anterior sem gravar candidata.
7. Abrir Forge Pause e mapa 3D; confirmar suspensão dos efeitos do FPS durante a câmera e retorno após fechar. Não altera bucket, clima ou relógio.
8. Num recurso de teste autorizado, suspender por export em duas origens; liberar uma não deve liberar a outra. Parar a origem deve limpar só a própria suspensão.
9. Outro script alterar um efeito enquanto o Forge FPS o controla: garantir que restaurar/parar o FPS não sobrescreve o valor mais recente. Nenhum getter significa não habilitar o efeito, não fingir sucesso.
10. Parar somente o recurso FPS durante perfil/benchmark/painel: conferir restauração dos efeitos ainda próprios e liberação do foco apenas quando ele pertence ao painel.

## Evidência a coletar

GPU/CPU/resolução e configuração gráfica do GTA informadas manualmente; local/horário/clima, perfil, FPS médio/1% low/frametime, três repetições e observações de visibilidade. Não usar estimativas de hardware da UI. Se a diferença variar de sinal ou for pequena, registrar “sem ganho consistente”.

O administrador deve decidir a liberação de bloom/desfoque após essa avaliação. O código não oferece garantia de aumento de FPS ou certificação anti-vantagem.
