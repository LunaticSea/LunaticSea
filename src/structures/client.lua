local discordia = require('discordia')
local database = require('../services/database_service.lua')
local bot_loader = require('../loader')
local dir = require('../bundlefs.lua')
local package = require('../../package.lua')
local class = require('class')
local lunalink = require('./lunalink')
local ll = require('lunalink')

local lunatic, get = class('LunaticSea', discordia.Client)

function lunatic:__init(test_mode)
	discordia.Client.__init(self, {
		logFile = './//lunatic.sea.log',
		gatewayFile = './/',
		gatewayIntents = 53608447,
		logEntryPad = 0,
		logLevel = 0,
	})

	self._logd = require('../services/logger_service.lua')(4, '%F %T', 'lunatic.sea.log', 28)
	self._logd:info('Client', 'Booting up: ' .. package.name .. '@' .. package.version)
	self._is_test_mode = test_mode
	self._project_tree = dir():get_all(test_mode)
	self._config = require('../utils/config.lua')
	self._i18n = require('../services/localization_service.lua')(self)
	self._bot_owner = self._config.bot.OWNER_ID
	self._commands = {}
	self._total_commands = 0
	self._command_categories = {}
	self._alias = {}
	self._db = {}
	self._icons = self._config.icons
	self._lunalink = lunalink(self).wrapper
	self._lavalink_using = {}
	self._nplayingMsg = ll.Cache()
	self._leaveDelay = ll.Cache()
	self._sentQueue = ll.Cache()
	self._selectMenuOptions = {}

	process:on('error', function (err)
		self._logd:error(err)
	end)

	process:on('uncaughtException', function (err)
		self._logd:error(err)
	end)

	for key, _ in pairs(ll.constants.FilterData) do
		local firstUpperCase = key:gsub("^%l", string.upper)
		table.insert(self._selectMenuOptions, {
			label = firstUpperCase,
			value = key,
			description = key == "clear"
				and 'Reset all current filter'
				or string.format("%s filter for better audio experience!", firstUpperCase),
		})
	end

	local _, db_err = pcall(database(self).load)
	if db_err then self._logd:error('Client', db_err) end

	local _, loader_err = pcall(bot_loader, self)
	if loader_err then self._logd:error('Client', loader_err) end

	if #self._config.bot.TOKEN == 0 then
		error('TOKEN not found!, please specify it on app.json (Example: example.app.json)')
	end
end

function get:selectMenuOptions()
	return self._selectMenuOptions
end

function get:sentQueue()
	return self._sentQueue
end

function get:nplayingMsg()
	return self._nplayingMsg
end

function get:leaveDelay()
	return self._leaveDelay
end

function get:db()
	return self._db
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
