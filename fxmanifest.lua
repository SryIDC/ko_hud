fx_version 'cerulean'
game 'gta5'

dependency 'qbx_seatbelt'

ui_page 'web/index.html'

shared_scripts { '@ox_lib/init.lua' }

files {
    'zips.json',
    'zones.json',
    'web/*.html',
    'web/*.js',
    'web/*.css',
    'web/*.png'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'config.lua',
    'cl_main.lua'
}
server_script 'server.lua'
lua54 'yes'
