return {
	name = 'LunaticSea',
	codename = 'selene',
	version = '1.0.0-dev',
	description = 'A versatile and powerful music bot for Discord that brings rhythm and melody to your server! Now in lua',
	tags = { 'lavalink', 'discordbot', 'discord' },
	license = 'AGPL-3.0',
	author = {
		name = 'RainyXeon',
		email = 'rainyxeon@gmail.com',
	},
	homepage = 'https://github.com/RainyXeon/LunaticSea',
	dependencies = {
		'creationix/coro-http@v3.2.3',
		'creationix/coro-websocket@3.1.0',
		'luvit/luvit@2.18.1',
		'luvit/secure-socket@v1.2.3',
		'truemedian/rethink-luvit@v0.2.0',
		'james2doyle/ms@v0.0.2'
	},
	files = { '**.lua', '!test*', '!make.lua', '!dev.lua', '!modules*', 'manifest.json' },
}
