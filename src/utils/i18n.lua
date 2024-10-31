local bunfs = require('../bundlefs.lua')
local i18n = {
  client = nil,
  avaliable_dir = {},
  default_locate = 'en_US'
}

function i18n.new(client)
  i18n.client = client
  i18n.read_dir()
  return i18n
end

function i18n.read_dir()
  local all_dir = function ()
    local params = { i18n.client._ptree, 'translation' }
    return bunfs.filter(table.unpack(params))
  end
  table.foreach(all_dir(), function (_, s_value)
    table.insert(i18n.avaliable_dir, s_value)
  end)
end

function i18n.get(locate, dir, key, value)
  local res = i18n.get_string(locate, dir, key, value)
  if res == nil then
    res = i18n.get_string(i18n.default_locate, dir, key, value)
  end
  return res
end

function i18n.get_string(locate, dir, key, value)
  local binf = package.cpath:match("%p[\\|/]?%p(%a+)")

  local pf_dir = table.concat({}, '/')
  if binf == "dll" then pf_dir = table.concat({ locate, dir }, '\\') end

  local params = { i18n.avaliable_dir, pf_dir }
  local exact_dir = bunfs.filter(table.unpack(params))[1]

  local translation_data = require(exact_dir)

  local res = translation_data[key]

  if value then res = string.format(res, table.unpack(value)) end
  return res
end

return i18n