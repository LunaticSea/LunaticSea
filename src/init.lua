require('./utils/luaex.lua')
local discordia = require('discordia')
local dir = require('./bundlefs.lua')
local package = require('../package.lua')

-- Bot start
return function(test_mode)
	local client = discordia.Client({
		logFile = 'lunatic.sea.log',
		gatewayFile = './/',
		gatewayIntents = 53608447,
		logEntryPad = 27,
	})

	client._logd = require('./utils/logger.lua'):new(client)
	client._logd:info('Client', 'Booting up: ' .. package.name .. '@' .. package.version)
	client._is_test_mode = test_mode
	client._ptree = dir:new():get_all(test_mode)
	client._config = require('./utils/config.lua')
	client._i18n = require('./utils/i18n.lua'):new(client)
	client._bot_owner = client._config.bot.OWNER_ID
	client._commands = {}
	client._total_commands = 0
	client._command_categories = {}
	client._c_alias = {}
	client._db = {}
	client._icons = client._config.icons

	require('./utils/database'):new(client):load()
	require('./loader')(client)

	if #client._config.bot.TOKEN == 0 then
		error('TOKEN not found!, please specify it on app.json (Example: example.app.json)')
	end

	client:run(client._config.bot.TOKEN)
	client:on('ready', function()
		require('./services/deploy_service'):new(client):register()
	end)
end
