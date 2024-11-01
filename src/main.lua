local discordia = require('discordia')
require("discordia-interactions")
local dir = require('./bundlefs.lua')
local package = require('../package.lua')

return function (test_mode)
	local client = discordia.Client({
		logFile = "lunatic.sea.log",
		gatewayFile = './/',
	})

	client._logd = require('./utils/logger.lua'):new(client)
	client._logd:info('Client', 'Booting up: ' .. package.name)
	client._is_test_mode = test_mode
	client._ptree = dir.get_all(test_mode)
	client._commands = {}
	client._c_alias = {}
	client._config = require('./utils/config.lua')
	client._i18n = require('./utils/i18n.lua').new(client)

	require('./loader/main.lua')(client)

	if (#client._config.bot.TOKEN == 0) then
		error('TOKEN not found!, please specify it on app.json (Example: example.app.json)')
	end

	client:run("Bot " .. client._config.bot.TOKEN)
end