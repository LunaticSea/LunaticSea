local discordia = require('discordia')
local database = require('../utils/database')
local bot_loader = require('../loader')
local dir = require('../bundlefs.lua')
local package = require('../../package.lua')
local class = require('class')
local lunalink = require('./lunalink')

local lunatic, get = class('LunaticSea', discordia.Client)

function lunatic:__init(test_mode)
	discordia.Client.__init(self, {
		logFile = './//lunatic.sea.log',
		gatewayFile = './/',
		gatewayIntents = 53608447,
		logEntryPad = 0,
		logLevel = 0,
	})

	self._logd = require('../utils/logger.lua')(3, '%F %T', 'lunatic.sea.log', 28)
	self._logd:info('Client', 'Booting up: ' .. package.name .. '@' .. package.version)
	self._is_test_mode = test_mode
	self._project_tree = dir():get_all(test_mode)
	self._config = require('../utils/config.lua')
	self._i18n = require('../utils/i18n.lua')(self)
	self._bot_owner = self._config.bot.OWNER_ID
	self._commands = {}
	self._total_commands = 0
	self._command_categories = {}
	self._alias = {}
	self._database = {}
	self._icons = self._config.icons
	self._lunalink = lunalink(self).wrapper

	database(self):load()
	bot_loader(self)

	if #self._config.bot.TOKEN == 0 then
		error('TOKEN not found!, please specify it on app.json (Example: example.app.json)')
	end
end

function get:database()
	return self._database
end

function get:commands()
	return self._commands
end

function get:alias()
	return self._alias
end

function get:logd()
	return self._logd
end

function get:is_test_mode()
	return self._is_test_mode
end

function get:config()
	return self._config
end

function get:project_tree()
	return self._project_tree
end

function get:i18n()
	return self._i18n
end

function get:bot_owner()
	return self._bot_owner
end

function get:icons()
	return self._icons
end

function get:lunalink()
	return self._lunalink
end

function lunatic:login()
	self:run(self.config.bot.TOKEN)
end

return lunatic
