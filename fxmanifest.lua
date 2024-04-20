-- Do not change anything in this file if you do not know what you are doing!

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Tuncion'
description 'Ingame Fraction Integration for FiveM Helper Discord Bot: https://fivem-helper.eu/'
version '1.0.0'

client_scripts {
    'bridge/**/client.lua',
    'client/main.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'settings/config.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'settings/API.lua',
    'bridge/**/server.lua',
    'server/main.lua'
}

escrow_ignore {
    'settings/',
}

dependencies {
    'ox_lib'
}
