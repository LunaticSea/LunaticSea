local lunaticdb = require('lunaticdb')
local database = require('class'):create()

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
	local db_driver_name = self.client._config.utilities.DATABASE.driver
	if db_driver_name == 'csv' then
	  local config = self.client._config.utilities.DATABASE[db_driver_name]
		return self:small_db_load(lunaticdb.driver.csv)
	end
end

function database:small_db_load(driver, config)
	for _, value in pairs(self.req_db) do
		self.client._db[value] = lunaticdb.core:new({ 
		  db_name = value,
		  driver = driver,
		  driver_options = config
		}):load()
	end
end

return database
