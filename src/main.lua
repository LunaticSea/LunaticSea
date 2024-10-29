local discordia = require('discordia')
local dir = require('./bundlefs.lua')
local package = require('../package.lua')

return function (test_mode)
	local client = discordia.Client({
		logFile = "lunatic.sea.log",
		gatewayFile = './/',
	})

	client._logger:log(3, 'Booting up: ' .. package.name)
	client._is_test_mode = test_mode
	client._ptree = dir.get_all(test_mode)
	client._commands = {}
	client._c_alias = {}
	client._config = require('./utils/config.lua')

	require('./loader/main.lua')(client)

	if (#client._config.bot.TOKEN == 0) then
		error('TOKEN not found!, please specify it on app.json (Example: example.app.json)')
	end

	client:run("Bot " .. client._config.bot.TOKEN)
end