fx_version 'cerulean'
game 'gta5'

name 'olympus_jobcenter'
description 'Olympus RolePlay — Job Center (επιλογή δουλειάς)'
author 'Olympus RolePlay'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/jobs.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'qbx_core'
}
