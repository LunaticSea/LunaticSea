return function (test_mode)
	require('./utils/luaex.lua')
	local bot = require('./structures/client')
	local lunatic = bot(test_mode)
	lunatic:login()
end