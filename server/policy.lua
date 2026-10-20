local current=FpsPolicy.defaults()
local configured,reason=FpsPolicy.validate(FpsServerConfig.Rules,current)
if configured then current=configured else print('[forge-fps] Política do config ignorada: '..reason)end
local raw=LoadResourceFile(GetCurrentResourceName(),FpsServerConfig.PolicyFile)
if raw and #raw<20000 then
    local ok,data=pcall(json.decode,raw)
    if ok and type(data)=='table' and data.version==1 then
        local valid=FpsPolicy.validate(data.rules,current)
        if valid then current=valid else print('[forge-fps] Política salva inválida; usando configuração.')end
    else print('[forge-fps] Não foi possível ler a política salva; usando configuração.')end
end
local revision,lastRequest,lastSave=1,{},{}
local function ace(source,name)
    if type(name)~='string' or name==''then return false end
    local r=IsPlayerAceAllowed(source,name);return r==true or r==1
end
local function allowed(source)return ace(source,FpsServerConfig.Ace) or ace(source,FpsServerConfig.InheritAce)end
local function snapshot(source)
    local exclusive,baselines={},{}
    for key,entry in pairs(FpsServerConfig.Exclusive)do
        local item=FpsPolicy.items[key]
        if item and item.exclusive and entry.enabled==true then
            local n=entry.baseline
            if FpsPolicy.validBaseline(item,n)then exclusive[key]=true;baselines[key]=n end
        end
    end
    return {rules=current,revision=revision,admin=allowed(source),exclusive=exclusive,baselines=baselines}
end
RegisterNetEvent('forge-fps:policy:request',function()
    local src=source;if type(src)~='number' or src<=0 then return end
    local now=GetGameTimer();if lastRequest[src] and now-lastRequest[src]<1500 then return end;lastRequest[src]=now
    TriggerClientEvent('forge-fps:policy:updated',src,snapshot(src))
end)
RegisterNetEvent('forge-fps:policy:save',function(id,expected,rules)
    local src=source;if type(src)~='number' or src<=0 then return end
    if type(id)~='number' or id%1~=0 or id<1 or id>2147483647 then return end
    local function reply(ok,message)TriggerClientEvent('forge-fps:policy:reply',src,id,{ok=ok,message=message,policy=snapshot(src)})end
    if not allowed(src)then reply(false,'Você não tem permissão para administrar o Forge FPS.');return end
    local now=GetGameTimer();if lastSave[src] and now-lastSave[src]<1500 then reply(false,'Aguarde antes de publicar novamente.');return end;lastSave[src]=now
    if expected~=revision then reply(false,'Outro administrador publicou alterações. Atualize a política antes de salvar.');return end
    local valid,reason=FpsPolicy.validate(rules,current)
    if not valid then reply(false,reason);return end
    local ok,encoded=pcall(json.encode,{version=1,rules=valid})
    if not ok or #encoded>20000 then reply(false,'Política excede o tamanho permitido.');return end
    local writeOk,written=pcall(SaveResourceFile,GetCurrentResourceName(),FpsServerConfig.PolicyFile,encoded,#encoded)
    if not writeOk or not written then reply(false,'Não foi possível gravar a política. Nada foi aplicado.');return end
    current,revision=valid,revision+1
    for _,player in ipairs(GetPlayers())do local target=tonumber(player);if target then TriggerClientEvent('forge-fps:policy:updated',target,snapshot(target))end end
    reply(true,'Política publicada para os jogadores. Nenhum perfil foi forçado.')
    print(('[forge-fps] Política atualizada pelo administrador ID %s.'):format(src))
end)
AddEventHandler('playerDropped',function()lastRequest[source]=nil;lastSave[source]=nil end)
local pingRequests={}
RegisterNetEvent('forge-fps:ping:request',function()
    local src=source;if type(src)~='number' or src<=0 then return end
    local now=GetGameTimer();if pingRequests[src] and now-pingRequests[src]<2500 then return end;pingRequests[src]=now
    local value=GetPlayerPing(src)
    if type(value)=='number' and value>=0 then TriggerClientEvent('forge-fps:ping:reply',src,value)end
end)
AddEventHandler('playerDropped',function()pingRequests[source]=nil end)
