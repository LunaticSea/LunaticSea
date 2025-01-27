return {
	name = 'LunaticSea',
	version = '1.0.0-dev',
	description = 'ByteBlaze in lua version. Include staandalone packages',
	tags = { 'lavalink', 'discordbot', 'discord' },
	license = 'AGPL-3.0',
	author = {
		name = 'RainyXeon',
		email = 'xeondev@xeondex.onmicrosoft.com',
	},
	homepage = 'https://github.com/RainyXeon/LunaticSea',
	dependencies = {
		'creationix/coro-http@v3.2.3',
		'creationix/coro-websocket@3.1.0',
		'luvit/luvit@2.18.1'
		-- 'luvit/require@2.2.3',
		-- 'luvit/process@2.1.3',
		-- 'luvit/dns@2.0.4',
		-- 'luvit/secure-socket@v1.2.3',
		-- 'luvit/json@v2.5.2',
		-- 'luvit/tap@v0.1.1',
		-- 'luvit/core@v2.0.4'
	},
	files = { '**.lua', '!test*', '!make.lua', '!dev.lua', '!modules*', 'manifest.json' },
}
