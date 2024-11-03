local split = require('../utils/split.lua')
local bundlefs = require('../bundlefs.lua')

local event_loader = {
  all_dir = {},
  require = {'client', 'guild'},
  client = nil
}

function event_loader:is_win()
  local BinaryFormat = package.cpath:match("%p[\\|/]?%p(%a+)")
  if not self.client._is_test_mode then return false end
  if BinaryFormat == 'dll' then return true end
  return false
end

function event_loader:new(client)
  self.client = client
  return self
end

function event_loader:run()
  self:load_file_dir()
  table.foreach(self.all_dir, function (_, value)
    local func = require(value)
    local splited_dir_params = { value, '[^/]+.lua' }
    if event_loader:is_win() then splited_dir_params[2] = '[^\\]+.lua' end
    local splited_dir = split(table.unpack(splited_dir_params))
    local e_name = split(splited_dir[1], '[^.]+')[1]
    self.client:on(e_name, function (...)
      func(self.client, ...)
    end)
    self.client._logd:info('EventLoader', 'Loaded event: '.. e_name)
  end)
end

function event_loader:load_file_dir()
  for _, value in pairs(self.require) do
    local all_dir = function ()
      local params = { self.client._ptree, 'src/events/' .. value }
      if event_loader:is_win() then params[2] = 'src\\events\\' .. value end
      return bundlefs:new():filter(table.unpack(params))
    end
    table.foreach(all_dir(), function (_, s_value)
      table.insert(self.all_dir, s_value)
    end)
  end
end

return event_loader