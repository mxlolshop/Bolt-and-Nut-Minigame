fx_version 'cerulean'
game 'gta5'

description 'mxBoltGame'
version '1.0'

ui_page 'html/index.html'

client_scripts { 
	'client/*' 
}

shared_scripts { 
	"config.lua" 
}

files {
	'html/index.html',
	'html/css/*.css',
	'html/js/*.js',
	'html/js/*.map',
	'html/img/*.gif',
	'html/img/*.png',
}

lua54 'yes'

escrow_ignore {
	'client/*',
	"config.lua",
}
