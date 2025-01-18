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

	self._logd = require('../services/logger_service.lua')(5, '%F %T', 'lunatic.sea.log', 30)
	self._logd:info('Client Bootloader', 'Booting up: ' .. package.name .. '@' .. package.version)

	self._logd:info('Client Bootloader', 'Loading all client properties...')
	-- Boolean and counter
	self._total_commands = 0
	self._is_test_mode = test_mode

	-- Config file
	self._config = require('../utils/config')
	if #self._config.bot.TOKEN == 0 then
		error('TOKEN not found!, please specify it on app.json (Example: example.app.json)')
	end

	-- Fast access
	self._bot_owner = self._config.bot.OWNER_ID
	self._icons = self._config.icons

	-- Tables
	self._db = {}
	self._alias = {}
	self._commands = {}
	self._plButton = {}
	self._lavalink_using = {}
	self._selectMenuOptions = {}
	self._command_categories = {}

	-- Cache
	self._sentQueue = ll.Cache()
	self._leaveDelay = ll.Cache()
	self._nplayingMsg = ll.Cache()

	-- Foregin package
	self._lunalink = lunalink(self).wrapper
	self._project_tree = dir():get_all(test_mode)
	self._i18n = require('../services/localization_service.lua')(self)

	-- Filter data
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

	self._logd:info('Client Bootloader', 'Loading anti crash feature...')
	process:on('error', function (err)
		self._logd:error(err)
	end)

	process:on('uncaughtException', function (err)
		self._logd:error(err)
	end)

	self._logd:info('Client Bootloader', 'Loading database...')
	database(self):load()

	self._logd:info('Client Bootloader', 'Loading all events and commands...')
	bot_loader(self)
end

function get:plButton()
	return self._plButton
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
