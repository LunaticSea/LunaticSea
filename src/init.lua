local discordia = require('discordia')
local dir = require('./bundlefs.lua')
local package = require('../package.lua')
local lunaticdb = require('lunaticdb')

return function (test_mode)
	local client = discordia.Client({
		logFile = "lunatic.sea.log",
		gatewayFile = './/',
		gatewayIntents = 53608447,
		logEntryPad = 27
	})

	client._logd = require('./utils/logger.lua'):new(client)
	client._logd:info('Client', 'Booting up: ' .. package.name)
	client._is_test_mode = test_mode
	client._ptree = dir:new():get_all(test_mode)
	client._commands = {}
	client._total_commands = 0
	client._command_categories = {}
	client._c_alias = {}
	client._config = require('./utils/config.lua')
	client._i18n = require('./utils/i18n.lua'):new(client)
	client._db = {}

	require('./loader')(client)
	require('./utils/database'):new(client):load()

	-- client._db.hello_world:set('world', 'mom')
	-- p(client._db.hello_world:get('world'))

	if #client._config.bot.TOKEN == 0 then
		error('TOKEN not found!, please specify it on app.json (Example: example.app.json)')
	end

	client:run(client._config.bot.TOKEN)
end