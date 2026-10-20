<script>
  let {item,value,disabled=false,onchange,t=(value)=>value}= $props();
  const options=$derived(item.type==='boolean'?[{value:false,label:t('Desativado')},{value:true,label:t('Ativado')}]:item.options?.map(option=>({...option,label:t(option.label)}))||[]);
  const index=$derived(options.findIndex(option=>option.value===value));
  const ratio=$derived(item.type==='range'?(item.max>item.min?Math.max(0,Math.min(1,(value-item.min)/(item.max-item.min))):1):0);
  const label=$derived(item.type==='range'?(item.unit==='percent'?`${Math.round(value*100)}%`:item.unit==='fps'?`${Math.round(value)} FPS`:item.unit==='seconds'?`${Math.round(value)} s`:item.unit==='minutes'?`${Math.round(value)} min`:String(value)):(options[index]?.label||t('Original')));
  function step(direction){
    if(disabled)return;
    if(item.type==='range')onchange(Number(Math.max(item.min,Math.min(item.max,value+item.step*direction)).toFixed(4)));
    else onchange(options[(index+direction+options.length)%options.length].value);
  }
</script>

<div class="adjust-control" class:disabled>
  <button class="adjust-arrow" aria-label={`${t('Diminuir')} ${item.label}`} {disabled} onclick={()=>step(-1)}>‹</button>
  {#if item.type==='range'}
    <div class="segment-track">
      <div class="segments" aria-hidden="true">{#each Array(20) as _,i}<span class:filled={i<Math.round(ratio*20)}></span>{/each}</div>
      <input aria-label={item.label} type="range" min={item.min} max={item.max} step={item.step} {value} {disabled} oninput={e=>onchange(Number(e.currentTarget.value))}/>
    </div>
    <output class="adjust-value" aria-live="off">{label}</output>
  {:else if item.type==='boolean'}
    <button class="adjust-choice" role="switch" aria-checked={value} aria-label={item.label} {disabled} onclick={()=>step(1)}>{label}</button>
  {:else}
    <button class="adjust-choice" aria-label={`${item.label}: ${label}`} {disabled} onclick={()=>step(1)}>{#if item.key==='uiAccent'}<span class="color-swatch" style:background={value}></span>{/if}{label}</button>
  {/if}
  <button class="adjust-arrow" aria-label={`${t('Aumentar')} ${item.label}`} {disabled} onclick={()=>step(1)}>›</button>
</div>
