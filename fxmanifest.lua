fx_version 'adamant'

game 'gta5'

description 'nz_garbagejob'
lua54 'yes'
version '1.0.2'
legacyversion '1.9.1'

shared_scripts{
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'config.lua',
	'locales/*.lua',
} 

client_scripts {
	'@es_extended/locale.lua',
	'client/main.lua'
}

server_scripts {
	'@es_extended/locale.lua',
	'server/main.lua'
}

dependencies {
	'es_extended',
}