return function (test_mode)
	require('./utils/luaex.lua')
	local bot = require('./structures/client')
	local lunatic = bot(test_mode)
	local test_plugin = require('test_plugin')(lunatic)
	p(test_plugin.fingerprint)
	lunatic:login()
end