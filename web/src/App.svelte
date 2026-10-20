<script>
  import { onMount, onDestroy, tick } from 'svelte';
  import SettingControl from './SettingControl.svelte';
  import forgeLogo from './assets/forge-flame.png';
  import {createTranslator} from './i18n.js';
  import './catalog-i18n.js';
  const demo=typeof window.GetParentResourceName!=='function';
  const defaults={preset:'original',bloom:1,cinematicBlur:1,hud:false,automatic:false,target:60,hudPosition:'topright',hudScale:1,hudOpacity:.9,hudShowFrametime:true,hudShowLows:true,hudShowGraph:false,hudShowSamples:false,uiScale:1,uiBackdrop:.3,uiAccent:'#FF7A1A',uiChartRange:60,uiChartGlow:0,uiAnimations:false,uiHighContrast:false};
  const presets=[{id:'original',name:'Original',description:'Nenhum ajuste gráfico do Forge FPS.',bloom:1,cinematicBlur:1},{id:'light',name:'Leve',description:'Pós-processamento mais discreto.',bloom:.85,cinematicBlur:1},{id:'balanced',name:'Equilibrado',description:'Limites conservadores para começar.',bloom:.65,cinematicBlur:1}];
  let visible=$state(demo),tab=$state('overview'),busy=$state(false),status=$state(''),error=$state(false);
  let saved=$state({...defaults}),draft=$state({...defaults}),info=$state({presets,graphics:{bloom:{available:true},cinematicBlur:{available:false,reason:'Bloqueado pela política do servidor.'}},limits:{bloom:.65,cinematicBlur:.75},resolution:{width:1920,height:1080},benchmarkSeconds:10,session:0});
  let metrics=$state({ready:false,fps:0,low1:0,frameMs:0,p95:0,samples:0}),history=$state([]),result=$state(null);
  let hud=$state(false),position=$state('topright'),testing=$state(false),phase=$state('settle'),remaining=$state(0),effective=$state({...defaults}),suspended=$state(false);
  let container=$state(),resetDialog=$state();let epoch=0;
  let category=$state('graphics'),search=$state(''),lowFps=$state(false),lowFpsValue=$state(0);
  let policyDraft=$state({}),policyRevision=$state(0),policySearch=$state('');
  const categories=[{id:'graphics',label:'Pós-processamento'},{id:'testing',label:'Renderização · testes'},{id:'distance',label:'Distância / sombras'},{id:'population',label:'População'},{id:'memory',label:'Orçamento / modelos'},{id:'monitor',label:'Contador / HUD'},{id:'interface',label:'Interface'},{id:'automation',label:'Automação'}];
  let locale=$state('pt-br');
  let currentFrame=$state({ready:false,fps:0,frameMs:0});
  function acceptLocale(value){if(['pt-br','en-us','es','fr'].includes(value))locale=value;}
  const t=$derived(createTranslator(locale));
  const catalog=$derived((info.catalog||[]).map(item=>({...item,label:t(item.label),description:t(item.description),options:item.options?.map(option=>({...option,label:t(option.label)}))})));
  const shown=$derived(catalog.filter(item=>search?`${item.label} ${item.key}`.toLowerCase().includes(search.toLowerCase()):item.group===category));
  const ui=$derived({...defaults,...(visible?draft:saved)});
  const graphHistory=$derived(history.slice(-(ui.uiChartRange||60)));
  const dirty=$derived(JSON.stringify(saved)!==JSON.stringify(draft));
  const policyDirty=$derived(JSON.stringify(policyDraft)!==JSON.stringify(info.policy?.rules||{}));
  const graph=$derived(graphHistory.map((n,i)=>`${graphHistory.length>1?i/(graphHistory.length-1)*800:0},${130-Math.min(1,n/Math.max(60,...graphHistory))*110}`).join(' '));
  const activeName=$derived(info.presets.find(p=>p.id===saved.preset)?.name||'Personalizado');
  const number=(n,d=0)=>Number.isFinite(n)?n.toFixed(d):'—';
  let diagnostics=$state({}),audioContext;
  $effect(()=>{document.documentElement.lang=locale;});
  function clickSound(event){
    if(!visible||!ui.uiSounds||!event.target?.closest?.('button:not(:disabled)'))return;
    try{const Audio=window.AudioContext||window.webkitAudioContext;if(!Audio)return;audioContext||=new Audio();audioContext.resume().catch(()=>{});const oscillator=audioContext.createOscillator(),gain=audioContext.createGain();oscillator.frequency.value=520;gain.gain.setValueAtTime(.025,audioContext.currentTime);gain.gain.exponentialRampToValueAtTime(.001,audioContext.currentTime+.035);oscillator.connect(gain);gain.connect(audioContext.destination);oscillator.start();oscillator.stop(audioContext.currentTime+.04);}catch{/* Audio is optional. */}
  }
  onDestroy(()=>audioContext?.close().catch(()=>{}));
  function announce(message,failed=false){status=message;error=failed;}
  async function changeTab(id){tab=id;await tick();container?.querySelector('main')?.scrollTo(0,0);}
  function applyPayload(payload){
    acceptLocale(payload.locale);
    info={...info,...payload};saved={...defaults,...payload.settings};draft={...saved};metrics=payload.metrics||metrics;
    currentFrame={ready:!!metrics.currentReady,fps:metrics.currentFps||0,frameMs:metrics.currentFrameMs||0};
    effective=payload.effective||saved;result=payload.result||null;hud=saved.hud;position=saved.hudPosition;suspended=!!payload.suspended;
    diagnostics=payload.diagnostics||{};
    policyDraft=JSON.parse(JSON.stringify(payload.policy?.rules||{}));policyRevision=payload.policy?.revision||0;
    if(tab==='admin'&&!payload.policy?.admin)tab='settings';
  }
  async function api(name,value={}){
    if(demo){
      if(name==='ready'||name==='close')return{ok:true};
      const settings=name==='reset'?{...defaults}:name==='preset'?{...saved,...presets.find(p=>p.id===value.id)}:{...value.settings};
      delete settings.id;delete settings.name;delete settings.description;
      if(name==='preset')settings.preset=value.id;
      if(name==='benchmark')return{ok:false,message:'O teste real está disponível dentro do FiveM.'};
      return{ok:true,payload:{...info,settings},message:'Prévia local · nada foi enviado ao jogo.'};
    }
    const controller=new AbortController();const timeout=setTimeout(()=>controller.abort(),6000);
    try{
      const response=await fetch(`https://${window.GetParentResourceName()}/${name}`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({...value,session:info.session}),signal:controller.signal});
      if(!response.ok)throw new Error('Falha ao comunicar com o jogo.');return await response.json();
    }finally{clearTimeout(timeout);}
  }
  async function action(name,value={}){
    if(busy)return;busy=true;const ticket=epoch;
    try{
      const response=await api(name,value);if(ticket!==epoch)return;
      if(!response?.ok){announce(response?.message||'Não foi possível concluir a ação.',true);return;}
      if(response.payload)applyPayload(response.payload);
      announce(response.message||'Ajuste aplicado.');
      if(name==='close'){visible=false;epoch++;}
    }catch{if(ticket===epoch)announce('Não foi possível falar com o jogo. Tente novamente.',true);}
    finally{if(ticket===epoch)busy=false;else if(!visible)busy=false;}
  }
  async function receive(event){
    const m=event.data;if(!m||typeof m!=='object')return;
    acceptLocale(m.locale);
    if(m.action==='open'&&m.payload?.settings){epoch++;busy=false;applyPayload(m.payload);visible=true;testing=false;announce('Preferências locais · escolha um perfil para começar.');await tick();container?.focus();}
    if(m.action==='close'){epoch++;visible=false;busy=false;hud=!!m.hud;position=m.position||position;if(m.settings)saved={...defaults,...m.settings};}
    if(m.action==='hud'){hud=!!m.visible;position=m.position||position;if(m.settings)saved={...defaults,...m.settings};}
    if(m.action==='lowFps'){lowFps=!!m.visible;lowFpsValue=m.fps;}
    if(m.action==='state'&&visible&&!dirty)applyPayload(m.payload);
    if(m.action==='frame'&&m.metrics)currentFrame=m.metrics;
    if(m.action==='metrics'){diagnostics=m.diagnostics||{};metrics=m.metrics;if(m.history)history=m.history;hud=!!m.hud;position=m.position||position;effective=m.effective||effective;suspended=!!m.suspended;if(m.graphics)info={...info,graphics:m.graphics};}
    if(m.action==='testStart'){testing=true;visible=false;busy=false;remaining=m.seconds;phase='settle';}
    if(m.action==='testProgress'){phase=m.phase;remaining=m.remaining;}
    if(m.action==='testEnd'){testing=false;announce(m.message);}
    if(m.action==='policy'&&m.payload){applyPayload(m.payload);announce(m.message||'Política atualizada pelo servidor.');}
  }
  async function keyboard(event){
    if(event.key==='Escape'&&visible&&!resetDialog?.open){event.preventDefault();await action('close');}
    if(event.key==='Tab'&&visible&&!resetDialog?.open){
      const list=[...container.querySelectorAll('button:not(:disabled),input:not(:disabled),select:not(:disabled)')];
      const first=list[0],last=list.at(-1);if(event.shiftKey&&(document.activeElement===first||document.activeElement===container)){event.preventDefault();last?.focus();}else if(!event.shiftKey&&document.activeElement===last){event.preventDefault();first?.focus();}
    }
  }
  function adjust(key,value){
    draft={...draft,[key]:value,preset:catalog.find(item=>item.key===key)?.policy?'custom':draft.preset};
    if(key==='target')draft={...draft,autoFloor:Math.max(20,value-5),autoCeiling:value+10};
  }
  function controlState(item){const state=info.graphics[item.key]||{available:item.available,reason:item.reason};return {...state,reason:t(state.reason)};}
  function editPolicy(key,field,value){policyDraft={...policyDraft,[key]:{...policyDraft[key],[field]:value}};}
  onMount(()=>{api('ready').then(response=>{if(response?.payload&&!visible)applyPayload(response.payload);}).catch(()=>announce('Interface sem conexão com o jogo.',true));if(demo)announce('Prévia do painel · medições reais aparecem no FiveM.');});
</script>

<svelte:window onmessage={receive} onkeydown={keyboard} onpointerdown={clickSound}/>

{#if visible}
  <div class="backdrop" style:background={`rgba(0,0,0,${ui.uiBackdrop})`} style:--space-orange-primary={ui.uiAccent} style:--chart-glow={`${ui.uiChartGlow*8}px`}>
    <div class="panel" class:high-contrast={ui.uiHighContrast} class:animated={ui.uiAnimations} style:transform={`scale(${ui.uiScale})`} role="dialog" aria-modal="true" aria-labelledby="fps-title" tabindex="-1" bind:this={container}>
      <aside class="sidebar">
        <div class="brand"><img class="brand-logo" src={forgeLogo} alt={t("Forge")}/><div>{t("FORGE")}<span>{t("PLAYER TOOLS")}</span></div></div>
        <p class="eyebrow">{t("SEU JOGO, MAIS FLUIDO")}</p>
        <nav aria-label={t("Seções do Forge FPS")}>
          {#each [{id:'overview',icon:'◉',label:t("Visão geral")},{id:'settings',icon:'☷',label:'Ajustes'},{id:'guide',icon:'◇',label:t("Uso responsável")},...(info.policy?.admin?[{id:'admin',icon:'⚙',label:t("Administração")}]:[])] as item}
            <button class:active={tab===item.id} onclick={()=>changeTab(item.id)} aria-current={tab===item.id?'page':undefined}><span aria-hidden="true">{item.icon}</span>{t(item.label)}</button>
          {/each}
        </nav>
        <p class="auto-language">{t('Idioma automático · PR Bridge')}<small>{locale.toUpperCase()}</small></p>
        <div class="policy"><span class="status-dot"></span>{t("Política do servidor")}<p>{t("Opções avançadas dependem do administrador. Sem apagar objetos ou mudar o clima.")}</p><button class="ghost" onclick={()=>action('adminPolicyRefresh')} disabled={busy}>{t("Atualizar permissões")}</button></div>
        <div class="sidebar-bottom"><small>{t("FORGE FPS")} <span>{info.version||'1.3.1'}</span></small><button class="ghost" onclick={()=>action('close')} disabled={busy}><kbd>{t("ESC")}</kbd> {t("Voltar ao jogo")}</button></div>
      </aside>
      <div class="workspace">
        <header><div><span class="eyebrow">{tab==='admin'?t("CONTROLE ADMINISTRATIVO"):t("DESEMPENHO LOCAL")}</span><h1 id="fps-title">{t("Menos excesso.")}<br class="mobile-break"> {t("Mais fluidez.")}</h1><p>{t("Ajustes com medida, sem desmontar a cidade.")}</p></div><div class="header-end"><span class="badge">{demo?t("PRÉVIA"):tab==='admin'?t("NO SERVIDOR"):suspended?'SUSPENSO':t("NO SEU COMPUTADOR")}</span><button class="close" aria-label={t("Fechar painel")} onclick={()=>action('close')} disabled={busy}>{t("×")}</button></div></header>
        <main>
          {#if tab==='overview'}
            <div class="metrics" aria-label={t("Medições de desempenho")}>
              {#each [{label:t("FPS médio"),value:metrics.fps,unit:'FPS',note:`${t('Média da janela:')} ${metrics.windowSeconds||10} s`,decimals:0},{label:t("Consistência · 1% low"),value:metrics.low1,unit:'FPS',note:t("Média dos quadros mais lentos"),decimals:0},{label:t("Tempo de quadro"),value:metrics.frameMs,unit:'ms',note:t("Menor é melhor"),decimals:2}] as item}
                <article class="stat"><span>{item.label}</span><strong>{metrics.ready?number(item.value,item.decimals):'—'}<small>{item.unit}</small></strong><p>{metrics.ready?item.note:t("Aguardando amostras do jogo")}</p></article>
              {/each}
            </div>
            <p class="subtle">{t('A HUD mostra o último quadro, atualizado até 4 vezes por segundo. O painel e o gráfico mostram a média da janela; contadores com janelas diferentes não precisam coincidir.')}</p>
            <section class="chart-card"><div class="section-heading"><div><h2>{t("O ritmo do seu jogo")}</h2><p>{t("FPS médio · últimas")} {ui.uiChartRange} {t("atualizações")}</p></div><span class="subtle">{metrics.samples||0} {t("quadros na janela")}</span></div>
              {#if history.length>1}<svg viewBox="0 0 800 140" role="img" aria-label={t("Histórico de FPS")}><path d="M 0 40 H 800 M 0 85 H 800 M 0 130 H 800" class="gridline"/><polyline points={graph}/></svg>{:else}<div class="chart-empty">{t("As medições aparecem aqui enquanto o painel ou o contador estiver ativo.")}</div>{/if}
            </section>
            <div class="section-heading profile-title"><div><h2>{t("Escolha seu ponto de partida")}</h2><p>{t("Perfis enxutos. Nenhum promete ganho fixo de FPS.")}</p></div><span class="subtle">{t("Em uso:")} {t(activeName)}</span></div>
            <p class="subtle">{t('LOD nunca abaixo de 65%. Presets preservam os orçamentos de modelos e não varrem objetos locais.')}</p>
            <div class="profiles">
              {#each info.presets as p,i}<button class="profile" class:selected={saved.preset===p.id} aria-pressed={saved.preset===p.id} disabled={busy} onclick={()=>action('preset',{id:p.id})}><span class="profile-top"><span class="profile-number">0{i+1}</span><span class="radio-dot"></span></span><strong>{t(p.name)}</strong><p>{t(p.description)}</p><span class="profile-link">{t(saved.preset===p.id?'Perfil ativo':'Aplicar perfil')} <span>↗</span></span></button>{/each}
            </div>
            <div class="notice"><span aria-hidden="true">◇</span><p>{t("Seu desempenho depende do hardware, da região e dos scripts do servidor. Os ajustes daqui são cosméticos e o ganho pode ser pequeno ou nulo.")}</p><button class="ghost" onclick={()=>tab='settings'}>{t("Personalizar →")}</button></div>
          {:else if tab==='settings'}
            <section class="settings-catalog">
              <div class="section-heading"><div><h2>{t("Seu ajuste, ponto a ponto")}</h2><p>{catalog.length} {t("controles · setas para ajustar · barra para escolher")}</p></div><button class="secondary" onclick={()=>resetDialog.showModal()} disabled={busy}>{t("Restaurar padrão")}</button></div>
              <div class="category-tabs" aria-label={t("Categorias de ajustes")}>
                {#each [...categories,{id:'lighting',label:t("Iluminação")},{id:'effects',label:t("Efeitos / água")}] as group}<button class:active={category===group.id&&!search} onclick={()=>{category=group.id;search='';}}>{t(group.label)}<small>{catalog.filter(item=>item.group===group.id).length}</small></button>{/each}
              </div>
              <input class="settings-search" aria-label={t("Buscar ajuste")} placeholder={t("Buscar por nome ou código…")} bind:value={search}/>
              {#if ['testing','distance','population','memory'].includes(category)&&!search}<p class="testing-notice">{t("Opções avançadas dependem da política do servidor. Podem alterar visibilidade/população e não são neutras para competição.")} {category==='memory'?t("Orçamento de modelos não é resolução de texturas. As texturas reais continuam nas configurações do GTA."):''}</p>{/if}
              <div class="settings-list">
                {#each shown as item (item.key)}
                  {@const state=controlState(item)}
                  <div class="setting-row" class:locked={!state.available}>
                    <div class="setting-description"><strong>{item.label}</strong><p>{item.description||t("Preferência local, salva neste computador.")}</p><small>{item.key}{item.policy?t(" · controlado pelo servidor"):''}{item.type==='range'&&item.unit==='percent'?` · ${t("mínimo autorizado:")} ${Math.round(item.min*100)}%`:''}</small>{#if !state.available}<span class="warning">{state.reason||t("Efeito indisponível.")}</span>{/if}</div>
                    <SettingControl {t} {item} value={draft[item.key]??item.default} disabled={busy||!state.available} onchange={value=>adjust(item.key,value)}/>
                  </div>
                {:else}<p class="empty-settings">{demo?t("Abra o recurso no FiveM para carregar o catálogo do cliente."):t("Nenhum ajuste corresponde à busca.")}</p>{/each}
              </div>
              <p class="catalog-note">{t("Original não aplica ajustes. Mudar uma opção avançada cria um perfil personalizado. Bloom geral solicitado:")} {Math.round((effective.bloom??1)*100)}{t("%; o resultado combinado respeita os mínimos de cada camada. No mínimo autorizado, o automático não tem margem adicional de redução.")} {suspended?t("Ajustes suspensos durante outra câmera/menu."):''}</p>
            </section>
            {#if draft.autoFloor>=draft.autoCeiling}<p class="warning">{t("O limite inferior automático deve ser menor que o superior.")}</p>{/if}
            <div class="settings-actions"><button class="primary" disabled={busy||!dirty||draft.autoFloor>=draft.autoCeiling} onclick={()=>action('save',{settings:draft})}>{busy?'Salvando…':t("Salvar ajustes")}</button><button class="secondary" disabled={busy} onclick={()=>{draft={...saved};announce('Rascunho descartado.');}}>{t("Descartar rascunho")}</button><span class="subtle">{t("Preferências locais. Gráficos aplicados somente ao salvar.")}</span></div>
          {:else if tab==='admin'&&info.policy?.admin}
            <section class="settings-catalog"><div class="section-heading"><div><h2>{t("O servidor define os limites")}</h2><p>{t("Revisão")} {policyRevision} {t("· permitir não força o ajuste no player.")}</p></div><button class="secondary" disabled={busy} onclick={()=>action('adminPolicyRefresh')}>{t("Atualizar política")}</button></div>
              <p class="testing-notice">{t("Alterações afetam a permissão de todos os jogadores. Opções revogadas deixam de ser aplicadas. Para parâmetros sem getter, o responsável precisa autorizar controle exclusivo e declarar a restauração em server/config.lua.")}</p>
              <input class="settings-search" aria-label={t("Buscar permissão")} placeholder={t("Buscar permissão por nome ou código…")} bind:value={policySearch}/>
              <div class="settings-list">{#each catalog.filter(item=>item.policy&&`${item.label} ${item.key}`.toLowerCase().includes(policySearch.toLowerCase())) as item (item.key)}
                {@const rule=policyDraft[item.key]||{allowed:false,min:item.min}}
                {@const exclusiveBlocked=item.exclusive&&!info.policy.exclusive?.[item.key]}
                <div class="setting-row"><div class="setting-description"><strong>{item.label}</strong><p>{item.description}</p><small>{item.key} · {item.group}</small>{#if exclusiveBlocked}<span class="warning">{t("Exige controle exclusivo em server/config.lua.")}</span>{/if}</div><div class="policy-controls">
                  <SettingControl {t} item={{type:'boolean',key:item.key,label:`${t("Autorizar")} ${item.label}`}} value={rule.allowed} disabled={busy||exclusiveBlocked} onchange={value=>editPolicy(item.key,'allowed',value)}/>
                  {#if item.type==='range'}<small>{t("Mínimo permitido ao player")}</small><SettingControl {t} item={{...item,label:`${t("Mínimo de")} ${item.label}`,min:item.hardMin??0}} value={rule.min??item.min} disabled={busy||!rule.allowed||exclusiveBlocked} onchange={value=>editPolicy(item.key,'min',value)}/>{/if}
                </div></div>
              {/each}</div>
              <div class="settings-actions"><button class="primary" disabled={busy||!policyDirty} onclick={()=>action('adminPolicySave',{rules:policyDraft,revision:policyRevision})}>{t("Publicar permissões")}</button><button class="secondary" disabled={busy} onclick={()=>{policyDraft=JSON.parse(JSON.stringify(info.policy.rules));announce('Rascunho administrativo descartado.');}}>{t("Descartar política")}</button></div>
            </section>
          {:else}
            <div class="guide-grid"><section class="card"><span class="eyebrow">{t("CENÁRIO PRESERVADO")}</span><h2>{t("Desempenho não precisa")}<br>{t("virar vantagem.")}</h2><p>{t("Este recurso não apaga jogadores, veículos, props, colisão ou evidências e não muda o clima. O administrador pode liberar redução de população, LOD, sombras, decals e orçamento de modelos; essas opções podem dar vantagem visual e devem ser avaliadas antes da liberação.")}</p><p>{t("O servidor define permissões e limites; Original não aplica ajustes. Parâmetros sem getter exigem controle exclusivo e uma baseline declarada. Texturas, resolução e MSAA continuam no menu do GTA.")}</p><h3>{t("Por que não há 87 ajustes gráficos?")}</h3><p>{t("A referência possui 87 opções, incluindo interface, HUD e ações destrutivas. Este painel tem")} {catalog.length} {t("controles implementados, sem excluir entidades do mundo.")}</p><h3>{t("FPS e estabilidade")}</h3><p>{t("Não há limitador de FPS neste recurso. Oscilação não é eliminada por esconder a medição. Compare o FPS médio, o 1% low e o tempo de quadro com o painel fechado, no mesmo cenário. No mínimo permitido, o automático não reduz mais o bloom.")}</p><h3>{t("O que ajustar no próprio GTA")}</h3><ul><li>{t("Reduza resolução e antisserrilhamento, comparando a legibilidade.")}</li><li>{t("Evite ultrapassar a memória de vídeo disponível.")}</li><li>{t("Feche gravações e aplicativos desnecessários.")}</li><li>{t("Texturas, MSAA e resolução não são modificados por este painel.")}</li></ul></section>
              <section class="card"><h2>{t("Compare no mesmo lugar")}</h2><p>{t("O teste mede o visual original e depois o seu ajuste atual, por")} {info.benchmarkSeconds} {t("segundos cada, com acomodação entre as fases.")}</p><p>{t("O painel desaparece durante a coleta. Não ande, gire a câmera ou atire: mudanças de cenário cancelam a comparação. O ajuste anterior sempre volta no fim.")}</p><p class="warning">{t("Resultado local e pontual. Repita o teste antes de concluir que um perfil melhora seu FPS.")}</p><button class="primary" disabled={busy} onclick={()=>action('benchmark',{settings:draft})}>{t("Comparar ajuste atual")}</button>
                {#if result}<div class="test-result"><h3>{result.valid?t("Comparação concluída"):t("Amostra insuficiente")}</h3><p>{t("Original:")} {number(result.before.fps,1)} {t("FPS · Ajuste:")} {number(result.after.fps,1)} {t("FPS")}</p><strong>{result.delta>=0?'+':''}{number(result.delta,1)} {t("FPS observados")}</strong><p>{t("Configuração anterior restaurada.")}</p>{#if result.valid}<button class="secondary" disabled={busy} onclick={()=>action('save',{settings:result.candidate})}>{t("Usar ajuste testado")}</button>{/if}</div>{/if}
              </section></div>
          {/if}
        </main>
        <footer><span class:error role="status">{t(busy?'Aplicando…':status)}</span><span>{t(tab==='admin'&&policyDirty?'● Política não publicada':dirty?'● Rascunho não salvo':`${info.resolution.width} × ${info.resolution.height}`)}</span></footer>
      </div>
      <dialog bind:this={resetDialog}><h2>{t("Restaurar o Forge FPS?")}</h2><p>{t("Volta ao perfil original e desliga o contador e o ajuste automático. Não modifica as configurações nativas do GTA.")}</p><div class="settings-actions"><button class="secondary" onclick={()=>resetDialog.close()}>{t("Cancelar")}</button><button class="primary" onclick={()=>{resetDialog.close();action('reset');}}>{t("Restaurar padrão")}</button></div></dialog>
    </div>
  </div>
{/if}
{#if hud&&!visible&&!testing}<aside class="fps-hud {position}" style:transform={`scale(${ui.hudScale})`} style:opacity={ui.hudOpacity} style:--space-orange-primary={ui.uiAccent} aria-label={t("Contador Forge FPS")}><div class="hud-numbers"><span class="status-dot"></span><strong>{currentFrame.ready?number(currentFrame.fps):'—'}</strong><span>{t('FPS atual')}</span>{#if ui.hudShowFrametime}<i></i><span>{currentFrame.ready?number(currentFrame.frameMs,1):'—'} {t("ms")}</span>{/if}{#if ui.hudShowLows}<i></i><span>1%: {metrics.ready?number(metrics.low1):'—'}</span>{/if}{#if ui.hudShowSamples}<span>{metrics.samples||0} {t("quadros")}</span>{/if}</div><div class="hud-extra"><span>{t('Média da janela:')} {metrics.ready?number(metrics.fps):'—'} FPS · {metrics.windowSeconds||10} s</span>{#if ui.hudShowPing}<span>Ping: {diagnostics.ping??'—'} ms</span>{/if}{#if ui.hudShowEntities}<span>{t('Entidades locais')}: {diagnostics.entities?`${diagnostics.entities.peds} / ${diagnostics.entities.vehicles} / ${diagnostics.entities.objects}`:'—'}</span>{/if}</div>{#if ui.hudShowGraph&&graphHistory.length>1}<svg viewBox="0 0 800 140" aria-label={t("Histórico compacto de FPS")}><polyline points={graph}/></svg>{/if}</aside>{/if}
{#if lowFps&&!visible&&!testing}<aside class="low-fps-warning" role="status">{t("FPS baixo persistente ·")} {number(lowFpsValue)} {t("FPS")}<br><small>{t("Compare os ajustes no mesmo lugar antes de alterar o perfil.")}</small></aside>{/if}
{#if testing}<aside class="benchmark-hud"><span class="eyebrow">{t("COMPARAÇÃO LOCAL")}</span><strong>{phase==='original'?t("Medindo original"):phase==='candidate'?t("Medindo ajuste"):t("Acomodando o cenário")} · {remaining}{t("s")}</strong><p>{t("Não mova a câmera ou o personagem. ESC ou /fps cancela.")}</p></aside>{/if}
