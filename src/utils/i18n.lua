local bunfs = require('../bundlefs.lua')
local i18n = require('class'):create()

function i18n:init(client)
  self.client = client
  self.avaliable_dir = {}
  self.default_locate = 'en_US'
  self.all_locates = {}
  self.binf = package.cpath:match("%p[\\|/]?%p(%a+)")
  self:read_dir()
end

function i18n:read_dir()
  local all_dir = function ()
    local params = { self.client._ptree, 'translation' }
    return bunfs:new():filter(table.unpack(params))
  end
  table.foreach(all_dir(), function (_, s_value)
    local pattern = 'arisu_(.+)/'
    if self.binf == "dll" then pattern = 'arisu_(.+)\\' end
    local locate_name = string.match(s_value, pattern)
    self.all_locates[locate_name] = locate_name
    table.insert(self.avaliable_dir, s_value)
  end)
end

function i18n:get_locates()
  local res = {}
  for _, value in pairs(self.all_locates) do
    table.insert(res, value)
  end
  return res
end

function i18n:get(locate, dir, key, value)
  local res = self:get_string(locate, dir, key, value)
  if res == nil then
    res = self:get_string(self.default_locate, dir, key, value)
  end
  return res
end

function i18n:get_string(locate, dir, key, value)
  local pf_dir = table.concat({}, '/')
  if self.binf == "dll" then pf_dir = table.concat({ locate, dir }, '\\') end

  local params = { self.avaliable_dir, pf_dir }
  local exact_dir = bunfs:filter(table.unpack(params))[1]

  local translation_data = require(exact_dir)

  local res = translation_data[key]

  if value then res = string.format(res, table.unpack(value)) end
  return res
end

return i18n