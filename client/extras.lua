FpsExtras={}
local status,objects,blocked={},{},{}
local ocean,lastScan
local function near(a,b,r)return (a.x-b.x)^2+(a.y-b.y)^2+(a.z-b.z)^2<=r*r end
local function readOcean()
    if type(GetDeepOceanScaler)~='function' or type(SetDeepOceanScaler)~='function'then return end
    local ok,n=pcall(GetDeepOceanScaler);if ok and type(n)=='number' and n==n and n>=0 and n<=100 then return n+0.0 end
end
local function equal(a,b)return a and b and math.abs(a-b)<.0001 end
local function validObject(entity,entry)
    return DoesEntityExist(entity) and GetEntityModel(entity)==entry.model and not NetworkGetEntityIsNetworked(entity) and not IsEntityAMissionEntity(entity)
end
local function restoreObject(entity,entry)
    if validObject(entity,entry) and GetEntityLodDist(entity)==entry.last then pcall(SetEntityLodDist,entity,entry.original)end
end
function FpsExtras.restore()
    if ocean and equal(readOcean(),ocean.last)then pcall(SetDeepOceanScaler,ocean.original+0.0)end;ocean=nil
    for entity,entry in pairs(objects)do restoreObject(entity,entry)end;objects={};lastScan=nil
end
function FpsExtras.configure(settings,explicit)
    if explicit then blocked={}end;status={}
    local water=readOcean()
    for _,key in ipairs({'oceanScaler','flatWater'})do
        local allowed=FpsSettings.allowed(FpsPolicy.items[key])
        status[key]={available=allowed and water~=nil and not blocked.ocean,reason=not allowed and 'Bloqueado pela política do servidor.' or water==nil and 'Native indisponível nesta instalação.' or blocked.ocean and 'Outro recurso alterou este efeito; ajuste suspenso.' or ''}
    end
    if ocean and not equal(water,ocean.last)then ocean=nil;blocked.ocean=true;for _,key in ipairs({'oceanScaler','flatWater'})do status[key]={available=false,reason='Outro recurso alterou este efeito; ajuste suspenso.'}end end
    local scale=1.0
    if settings.preset~='original'then
        if status.oceanScaler.available then scale=settings.oceanScaler end
        if status.flatWater.available and settings.flatWater then scale=0.0 end
    end
    if scale<1 and water~=nil and not blocked.ocean then
        ocean=ocean or {original=water,last=water};local target=ocean.original*scale+0.0
        if not equal(water,target)then if pcall(SetDeepOceanScaler,target)then ocean.last=target else blocked.ocean=true end end
    elseif ocean then if equal(water,ocean.last)then pcall(SetDeepOceanScaler,ocean.original+0.0)end;ocean=nil end
    local supported=type(GetGamePool)=='function' and type(GetEntityLodDist)=='function' and type(SetEntityLodDist)=='function' and type(NetworkGetEntityIsNetworked)=='function' and type(IsEntityAMissionEntity)=='function'
    local allowed=FpsSettings.allowed(FpsPolicy.items.entityLod)
    status.entityLod={available=allowed and supported,reason=not allowed and 'Bloqueado pela política do servidor.' or not supported and 'Native indisponível nesta instalação.' or ''}
    local lod=settings.preset~='original' and status.entityLod.available and settings.entityLod or 1.0
    if lod==1 then for entity,entry in pairs(objects)do restoreObject(entity,entry)end;objects={};return end
    local now=GetGameTimer();if lastScan and now-lastScan<5000 then return end;lastScan=now
    local center=GetEntityCoords(PlayerPedId());local seen={};local count,visited=0,0
    local ok,pool=pcall(GetGamePool,'CObject');if not ok then return end
    -- Bounded scan; never players, vehicles, networked or mission entities.
    for _,entity in ipairs(pool)do
        visited=visited+1;if count>=128 or visited>512 then break end
        if DoesEntityExist(entity) and not NetworkGetEntityIsNetworked(entity) and not IsEntityAMissionEntity(entity) and near(GetEntityCoords(entity),center,150)then
            count=count+1;local current=GetEntityLodDist(entity);local entry=objects[entity]
            if entry and (not validObject(entity,entry) or current~=entry.last)then objects[entity]=nil;blocked[entity]=true;entry=nil end
            if not blocked[entity] and current>0 then
                entry=entry or {model=GetEntityModel(entity),original=current,last=current};local target=math.max(1,math.floor(entry.original*lod+.5))
                if current==target or pcall(SetEntityLodDist,entity,target)then entry.last=target;objects[entity]=entry;seen[entity]=true end
            end
        end
    end
    for entity,entry in pairs(objects)do if not seen[entity]then restoreObject(entity,entry);objects[entity]=nil end end
end
function FpsExtras.status()return FpsSettings.copy(status)end
