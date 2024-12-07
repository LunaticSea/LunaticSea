return function(client)
	require('./event.lua')(client):run()
	require('./commands.lua')(client):run()
end
