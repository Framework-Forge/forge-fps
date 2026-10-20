FpsDiagnostics={}
local ping,pingAt,lastRequest,entities,entitiesAt=nil,0,-10000,nil,-10000
RegisterNetEvent('forge-fps:ping:reply',function(n)
    if type(n)=='number' and n==n and n>=0 and n<60000 then ping,pingAt=n,GetGameTimer()end
end)
function FpsDiagnostics.snapshot(settings,visible)
    local now=GetGameTimer();local enabled=visible or settings.hud
    if enabled and settings.hudShowPing and now-lastRequest>=3000 then TriggerServerEvent('forge-fps:ping:request');lastRequest=now end
    if enabled and settings.hudShowEntities and type(GetGamePool)=='function' and now-entitiesAt>=5000 then
        local counts={};local valid=true
        for key,pool in pairs({peds='CPed',vehicles='CVehicle',objects='CObject'})do local ok,items=pcall(GetGamePool,pool);if ok and type(items)=='table'then counts[key]=#items else valid=false end end
        entities=valid and counts or nil;entitiesAt=now
    end
    return {ping=settings.hudShowPing and now-pingAt<10000 and ping or nil,entities=settings.hudShowEntities and now-entitiesAt<15000 and entities or nil}
end
