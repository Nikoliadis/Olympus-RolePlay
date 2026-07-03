fx_version 'cerulean'
game 'gta5'

name 'olympus_spawn'
description 'Olympus RolePlay — custom character creation & Job Center spawn'
author 'Olympus RolePlay'
version '1.0.0'

lua54 'yes'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js'
}

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'ox_lib',
    'qbx_core'
}
