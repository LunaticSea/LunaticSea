local split = require('../utils/split.lua')
local dir = require('../dir.lua')
local Dotenv = require('Dotenv')
Dotenv.load_env()

local event_loader = {
  all_dir = {},
  require = {'discordia', 'client'},
  client = nil
}

local function is_win()
  local BinaryFormat = package.cpath:match("%p[\\|/]?%p(%a+)")
  if Dotenv.get_value("TEST_MODE") ~= 'true' then return false end
  if BinaryFormat == 'dll' then return true end
  return false
end

function event_loader.new(client)
  event_loader.client = client
  return event_loader
end

function event_loader.run()
  event_loader.load_file_dir()
  table.foreach(event_loader.all_dir, function (_, value)
    local func = require(value)
    local splited_dir_params = { value, '[^/]+.lua' }
    if is_win() then splited_dir_params[2] = '[^\\]+.lua' end
    local splited_dir = split(table.unpack(splited_dir_params))
    local e_name = split(splited_dir[1], '[^.]+')[1]
    event_loader.client:on(e_name, function (...)
      func(event_loader.client, ...)
    end)
    print('Loaded '.. e_name)
  end)
end

function event_loader.load_file_dir()
  for _, value in pairs(event_loader.require) do
    local all_dir = function ()
      local params = { event_loader.client._ptree, 'src/events/' .. value }
      if is_win() then params[2] = 'src\\events\\' .. value end
      return dir.filter(table.unpack(params))
    end
    table.foreach(all_dir(), function (_, s_value)
      table.insert(event_loader.all_dir, s_value)
    end)
  end
end

return event_loader