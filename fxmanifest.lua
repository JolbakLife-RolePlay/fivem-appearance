fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Original Release ]]
-- author 'snakewiz'
-- description 'A flexible player customization script for FiveM.'
-- repository 'https://github.com/pedr0fontoura/fivem-appearance'
-- version '1.2.2'

--[[ Converted to Lua]]
-- author 'Linden'
-- description 'A flexible player customization script for FiveM.'
-- repository 'https://github.com/overextended/fivem-appearance/'
-- version '1.1.1'

name 'fivem-appearance'
author 'Mahan Moulaei'
discord 'Mahan#8183'
description 'JolbakLifeRP fivem-appearance'

version '0.0'

client_scripts {
	'client/constants.lua',
	'client/utils.lua',
	'client/customisation.lua',
	'client/nui.lua',
	'client/main.lua',
	'client/outfits.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

files {
	'web/build/index.html',
	'web/build/static/js/*.js',
	'locales/*.json'
}

ui_page 'web/build/index.html'

provides {
	'skinchanger',
	'esx_skin'
}
