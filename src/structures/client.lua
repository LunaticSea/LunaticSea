local discordia = require('discordia')
local database = require('../utils/database')
local bot_loader = require('../loader')
local dir = require('../bundlefs.lua')
local package = require('../../package.lua')
local class = require('class')

local lunatic = class('LunaticSea', discordia.Client)

function lunatic:init(test_mode)
	discordia.Client.__init(self, {
		logFile = 'lunatic.sea.log',
		gatewayFile = './/',
		gatewayIntents = 53608447,
		logEntryPad = 28,
	})

	self.logd = require('../utils/logger.lua')(self)
	self.logd:info('Client', 'Booting up: ' .. package.name .. '@' .. package.version)
	self.is_test_mode = test_mode
	self.project_tree = dir():get_all(test_mode)
	self.config = require('../utils/config.lua')
	self.i18n = require('../utils/i18n.lua')(self)
	self.bot_owner = self.config.bot.OWNER_ID
	self.commands = {}
	self.total_commands = 0
	self.command_categories = {}
	self.alias = {}
	self.db = {}
	self.icons = self.config.icons

	database(self):load()
	bot_loader(self)

	if #self.config.bot.TOKEN == 0 then
		error('TOKEN not found!, please specify it on app.json (Example: example.app.json)')
	end
end

function lunatic:login()
	self:run(self.config.bot.TOKEN)
end

return lunatic
