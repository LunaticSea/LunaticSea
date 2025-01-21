local bundlefs = require('../bundlefs.lua')
local event_loader = require('class')('PlayerEventLoader')

function event_loader:__init(client)
	self._client = client
	self._all_dir = {}
	self._require = { 'node', 'player', 'track' }
	self._event_count = 0
end

function event_loader:is_win()
	local BinaryFormat = package.cpath:match('%p[\\|/]?%p(%a+)')
	if not self._client.is_test_mode then
		return false
	end
	if BinaryFormat == 'dll' then
		return true
	end
	return false
end

function event_loader:run()
	self:load_file_dir()
	table.foreach(self._all_dir, function(_, value)
		local func = require(value)
		local splited_dir_params = { value, '[^/]+.lua' }
		if self:is_win() then
			splited_dir_params[2] = '[^\\]+.lua'
		end
		local splited_dir = string.split(table.unpack(splited_dir_params))
		local e_name = string.split(splited_dir[1], '[^.]+')[1]
		self._client.lunalink:on(e_name, function(...)
			local success, internal_err = pcall(func, self._client, ...)
			if not success then
				self._client.logd:error(string.format('PlayerEvent:%s', e_name), internal_err)
			end
		end)
		-- self._client.logd:info('EventLoader', 'Loaded event: '.. e_name)
		self._event_count = self._event_count + 1
	end)
	self._client.logd:info('EventLoader', self._event_count .. ' player events loaded')
end

function event_loader:load_file_dir()
	for _, value in pairs(self._require) do
		local all_dir = function()
			local params = { self._client.project_tree, 'src/events/' .. value }
			if self:is_win() then
				params[2] = 'src\\events\\' .. value
			end
			return bundlefs():filter(table.unpack(params))
		end
		table.foreach(all_dir(), function(_, s_value)
			table.insert(self._all_dir, s_value)
		end)
	end
end

return event_loader
