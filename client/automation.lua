FpsAutomation={}
local lastActivity,lastPos,lastRot=0,nil,nil
function FpsAutomation.effective(settings,paused,opened,testing)
    local value=FpsSettings.copy(settings);local reason
    if opened or testing or paused then lastActivity=GetGameTimer();return value end
    if not settings.afkSaver and not settings.interiorSaver then return value end
    local now=GetGameTimer();local ped=PlayerPedId()
    if settings.afkSaver then
        local pos,rot=GetEntityCoords(ped),GetGameplayCamRot(2)
        local moved=not lastPos or (pos.x-lastPos.x)^2+(pos.y-lastPos.y)^2+(pos.z-lastPos.z)^2>.01
        local turned=not lastRot or math.abs((rot.z-lastRot.z+180)%360-180)>.5 or math.abs(rot.x-lastRot.x)>.5
        local input=false
        if type(GetTimeSinceLastInput)=='function'then local ok,n=pcall(GetTimeSinceLastInput,0);input=ok and n<1500 end
        if moved or turned or input or IsPedShooting(ped)then lastActivity=now end;lastPos,lastRot=pos,rot
        if now-lastActivity>=settings.afkMinutes*60000 then reason='afk'end
    end
    if settings.interiorSaver and type(GetInteriorFromEntity)=='function' and GetInteriorFromEntity(ped)~=0 then reason='interior'end
    if reason and settings.preset~='original' and FpsSettings.allowed(FpsPolicy.items.bloom)then value.bloom=FpsPolicy.minimum('bloom')end
    return value,reason
end
