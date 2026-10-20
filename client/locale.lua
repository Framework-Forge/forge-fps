-- Read-only consumer of the existing PR Bridge settings contract. Never sets it.
FpsLocale = {}
local current, checkedAt = 'pt-br', nil
local function normalize(name)
    if type(name) ~= 'string' or name == '' then return end
    name = name:lower():gsub('_', '-')
    if name == 'ptbr' or name:match('^pt') then return 'pt-br' end
    if name:match('^es') then return 'es' end
    if name:match('^fr') then return 'fr' end
    return 'en-us'
end
function FpsLocale.resolve(force)
    local now = GetGameTimer()
    if not force and checkedAt and now >= checkedAt and now - checkedAt < 5000 then return current end
    checkedAt = now
    if type(GetResourceState) == 'function' and GetResourceState('pr_bridge') ~= 'started' then return current end
    local ok, record = pcall(function() return exports.pr_bridge:GetCachedState('locale') end)
    local name = ok and type(record) == 'table' and type(record.data) == 'table' and record.data.name or nil
    if not name and type(GetConvar) == 'function' then
        name = GetConvar('pr_bridge:locale', GetConvar('locale', GetConvar('qb_locale', 'pt-br')))
    end
    current = normalize(name) or current
    return current
end
