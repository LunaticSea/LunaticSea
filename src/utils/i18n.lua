local bunfs = require('../bundlefs.lua')
local i18n, get = require('class')('i18n')

function i18n:init(client)
	self._client = client
	self._avaliable_dir = {}
	self._default_locate = 'en_US'
	self._all_locates = {}
	self._binf = package.cpath:match('%p[\\|/]?%p(%a+)')
	self:read_dir()
end

function get:client() return self._client end

function get:default_locate() return self._default_locate end

function get:all_locates() return self._all_locates end

function i18n:read_dir()
	local all_dir = function()
		return bunfs():filter(self._client.project_tree, 'translation')
	end
	table.foreach(all_dir(), function(_, s_value)
		local pattern = 'arisu_(.+)/'
		if self._binf == 'dll' and self._client.is_test_mode then
			pattern = 'arisu_(.+)\\'
		end
		local locate_name = string.match(s_value, pattern)
		self._all_locates[locate_name] = locate_name
		table.insert(self._avaliable_dir, s_value)
	end)
end

function i18n:get_locates()
	local res = {}
	for _, value in pairs(self._all_locates) do
		table.insert(res, value)
	end
	return res
end

function i18n:get(locate, dir, key, value)
	local res = self:get_string(locate, dir, key, value)
	if res == nil then
		res = self:get_string(self._default_locate, dir, key, value)
	end
	return res
end

function i18n:get_string(locate, dir, key, value)
	local pf_dir = table.concat({ locate, dir }, '/')
	if self._binf == 'dll' and self._client.is_test_mode then
		pf_dir = table.concat({ locate, dir }, '\\')
	end

	local exact_dir = bunfs():filter(self._avaliable_dir, pf_dir)[1]
	local translation_data = require(exact_dir)
	local res = translation_data[key]

	if value then
		res = string.format(res, table.unpack(value))
	end
	return res
end

return i18n
