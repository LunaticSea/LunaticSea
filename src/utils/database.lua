local lunaticdb = require('lunaticdb')
local database = require('class')('database')

function database:init(client)
	self.client = client
	self.req_db =
		{
			'autoreconnect',
			'playlist',
			'code',
			'premium',
			'setup',
			'language',
			'prefix',
			'songNoti',
			'preGuild',
			'blacklist',
			'maxlength'
		}
end

function database:load()
	local db_driver_name = self.client.config.utilities.DATABASE.driver
	local db_driver = lunaticdb.driver[db_driver_name]
	local db_driverconfig = self.client.config.utilities.DATABASE[db_driver_name]
	return self:small_db_load(db_driver, db_driverconfig)
end

function database:small_db_load(driver, config)
	for _, value in pairs(self.req_db) do
		self.client.db[value] = lunaticdb.core({ db_name = value }):load(driver, config)
	end
end

return database
