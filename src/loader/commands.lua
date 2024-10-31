local dir = require('../bundlefs.lua')

local cmd_loader = {
  all_dir = {},
  client = nil
}

local function is_win()
  local BinaryFormat = package.cpath:match("%p[\\|/]?%p(%a+)")
  if not cmd_loader.client._is_test_mode then return false end
  if BinaryFormat == 'dll' then return true end
  return false
end

function cmd_loader.new(client)
  cmd_loader.client = client
  return cmd_loader
end

function cmd_loader.run()
  cmd_loader.load_file_dir()
  table.foreach(cmd_loader.all_dir, function (_, value)
    local cmd_data = require(value)
    local cmd_name = table.concat(cmd_data.info.name, '-')
    cmd_loader.client._commands[cmd_name] = cmd_data

    table.foreach(cmd_data.info.aliases, function (_, alias)
      cmd_loader.client._c_alias[alias] = cmd_name
    end)

    cmd_loader.client._logger:log(3, 'Loaded command: ' .. cmd_data.info.category .. '/' .. cmd_name)
  end)
end

function cmd_loader.load_file_dir()
  local all_dir = function ()
    local params = { cmd_loader.client._ptree, 'src/commands/' }
    if is_win() then params[2] = 'src\\commands\\' end
    return dir.filter(table.unpack(params))
  end
  table.foreach(all_dir(), function (_, s_value)
    table.insert(cmd_loader.all_dir, s_value)
  end)
end

return cmd_loader