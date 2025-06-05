fx_version 'cerulean'
game 'gta5'

author 'KraLArmyFx'
description 'Automatically deletes vehicles that have been unoccupied and inactive for a long time'
version '1.0.0'
lua54 'yes'

shared_scripts {
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
