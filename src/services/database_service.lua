local lunaticdb = require('lunaticdb')
local database = require('class')('DatabaseService')

function database:__init(client)
	self._client = client
	self._req_db =
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
	local db_driver_name = self._client.config.utilities.DATABASE.driver
	local db_driver = lunaticdb.driver[db_driver_name]
	local db_driverconfig = self._client.config.utilities.DATABASE[db_driver_name]
	return self:small_db_load(db_driver, db_driverconfig)
end

function database:small_db_load(driver, config)
	for _, value in pairs(self._req_db) do
		self._client._db[value] = lunaticdb.core({ db_name = value }):load(driver, config)
	end
end

return database
