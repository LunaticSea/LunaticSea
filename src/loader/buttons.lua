local bundlefs = require('../bundlefs.lua')
local button_loader = require('class')('ButtonLoader')

function button_loader:__init(client)
	self._client = client
	self._all_dir = {}
end

function button_loader:is_win()
	local BinaryFormat = package.cpath:match('%p[\\|/]?%p(%a+)')
	if not self._client.is_test_mode then
		return false
	end
	if BinaryFormat == 'dll' then
		return true
	end
	return false
end

function button_loader:run()
	self:load_file_dir()
	self:register()

	if self._client._total_commands > 0 then
		self._client.logd:info(
			'ButtonLoader',
			string.format('%s button Loaded!', self._client._total_commands)
		)
	else
		self._client.logd:warn('ButtonLoader', 'No button loaded, is everything ok?')
	end
end

function button_loader:register()
	table.foreach(self._all_dir, function(_, value)
		local button_data = require(value)()
		self._client._plButton[button_data.name] = button_data
	end)
end

function button_loader:load_file_dir()
	local all_dir = function()
		local params = { self._client.project_tree, 'src/buttons/' }
		if self:is_win() then
			params[2] = 'src\\buttons\\'
		end
		return bundlefs():filter(table.unpack(params))
	end
	table.foreach(all_dir(), function(_, s_value)
		table.insert(self._all_dir, s_value)
	end)
end

return button_loader
