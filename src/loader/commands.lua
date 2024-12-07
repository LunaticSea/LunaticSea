local bundlefs = require('../bundlefs.lua')
local cmd_loader = require('class')('cmd_loader')

function cmd_loader:init(client)
	self.client = client
	self.all_dir = {}
end

function cmd_loader:is_win()
	local BinaryFormat = package.cpath:match('%p[\\|/]?%p(%a+)')
	if not self.client.is_test_mode then
		return false
	end
	if BinaryFormat == 'dll' then
		return true
	end
	return false
end

function cmd_loader:run()
	self:load_file_dir()
	self:register()

	if self.client.total_commands > 0 then
		self.client.logd:info(
			'CommandLoader',
			string.format('%s command Loaded!', self.client.total_commands)
		)
	else
		self.client.logd:warn('CommandLoader', 'No command loaded, is everything ok?')
	end
end

function cmd_loader:register()
	table.foreach(self.all_dir, function(_, value)
		local cmd_data = require(value)()
		local cmd_name = table.concat(cmd_data.name, '-')

		self.client.commands[cmd_name] = cmd_data

		table.foreach(cmd_data.aliases, function(_, alias)
			self.client.alias[alias] = cmd_name
		end)

		if not self.client.command_categories[cmd_data.category] then
			self.client.command_categories[cmd_data.category] = #self.client.command_categories
		end

		-- self.client.logd:info('CommandLoader', 'Loaded command: ' .. cmd_data.category .. '/' .. cmd_name)

		self.client.total_commands = self.client.total_commands + 1
	end)
end

function cmd_loader:load_file_dir()
	local all_dir = function()
		local params = { self.client.project_tree, 'src/commands/' }
		if self:is_win() then
			params[2] = 'src\\commands\\'
		end
		return bundlefs():filter(table.unpack(params))
	end
	table.foreach(all_dir(), function(_, s_value)
		table.insert(self.all_dir, s_value)
	end)
end

return cmd_loader
