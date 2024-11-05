local bundlefs = require('../bundlefs.lua')

local cmd_loader = {
  all_dir = {},
  client = nil
}

function cmd_loader:is_win()
  local BinaryFormat = package.cpath:match("%p[\\|/]?%p(%a+)")
  if not self.client._is_test_mode then return false end
  if BinaryFormat == 'dll' then return true end
  return false
end

function cmd_loader:new(client)
  self.client = client
  return self
end

function cmd_loader:run()
  cmd_loader:load_file_dir()
  table.foreach(self.all_dir, function (_, value)
    local cmd_data = require(value)
    local cmd_name = table.concat(cmd_data.info.name, '-')
    self.client._commands[cmd_name] = cmd_data

    table.foreach(cmd_data.info.aliases, function (_, alias)
      self.client._c_alias[alias] = cmd_name
    end)

    if not self.client._command_categories[cmd_data.info.category] then
      self.client._command_categories[cmd_data.info.category] = #self.client._command_categories
    end

    self.client._logd:info('CommandLoader', 'Loaded command: ' .. cmd_data.info.category .. '/' .. cmd_name)

    self.client._total_commands = self.client._total_commands + 1
  end)
end

function cmd_loader:load_file_dir()
  local all_dir = function ()
    local params = { self.client._ptree, 'src/commands/' }
    if self:is_win() then params[2] = 'src\\commands\\' end
    return bundlefs:new():filter(table.unpack(params))
  end
  table.foreach(all_dir(), function (_, s_value)
    table.insert(self.all_dir, s_value)
  end)
end

return cmd_loader