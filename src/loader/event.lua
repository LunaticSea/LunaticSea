local fsex = require('../utils/fsex.lua')
local split = require('../utils/split.lua')
local event_loader = {
  all_dir = {},
  require = {'discordia', 'client'},
  client = nil
}

function event_loader.new(client)
  event_loader.client = client
  return event_loader
end

function event_loader.run()
  event_loader.load_file_dir()
  table.foreach(event_loader.all_dir, function (_, value)
    local func = require(value)
    local splited_dir = split(value, '[^\\]+.lua')
    local e_name = split(splited_dir[1], '[^.]+')[1]
    event_loader.client:on(e_name, function (...)
      func(event_loader.client, ...)
    end)
    print('Loaded '.. e_name)
  end)
end

function event_loader.load_file_dir()
  for _, value in pairs(event_loader.require) do
    local all_dir = fsex.readdir_recursive({ module.dir, '..', 'events', value })
    table.foreach(all_dir, function (_, s_value)
      table.insert(event_loader.all_dir, s_value)
    end)
  end
end

return event_loader