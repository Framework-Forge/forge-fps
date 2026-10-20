fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'forge-fps'
author 'Forge Project - by: PierreMoraes'
description 'Desempenho local, medição real e ajustes conservadores'
version '1.3.1'

shared_scripts {
    'config.lua',
    'shared/catalog.lua',
    'shared/policy.lua',
    'shared/settings.lua'
}

server_scripts {
    'server/config.lua',
    'server/policy.lua'
}

client_scripts {
    'client/graphics.lua',
    'client/extras.lua',
    'client/performance.lua',
    'client/metrics.lua',
    'client/diagnostics.lua',
    'client/automation.lua',
    'client/locale.lua',
    'client/main.lua'
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/assets/*'
}
