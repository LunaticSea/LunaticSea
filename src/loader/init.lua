return function(client)
	require('./event.lua'):new(client):run()
	require('./commands.lua'):new(client):run()
end
