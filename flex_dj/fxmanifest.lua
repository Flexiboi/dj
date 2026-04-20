fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'flex_dj'
description 'DJ / Music app'
version '0.0.1'

ui_page('ui/index.html') 

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/config.lua',
    'shared/sv_shared.lua',
    'client/bridge/**.lua',
    'server/bridge/**.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/dataview.lua',
    'client/gizmo.lua',
    'client/main.lua',
    'client/lights.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

files {
    'locales/*.json',
    '**/config.lua',
    'ui/**.png',
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'storage/**.json',
}

escrow_ignore {
    'shared/config.lua',
    'shared/sv_shared.lua',
    'client/bridge/**.lua',
    'server/bridge/**.lua',
    'storage/**',
    'storage/**.json',
}

dependencies {
    'ox_lib',
    'qbx_core'
}