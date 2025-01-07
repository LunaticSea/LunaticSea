return function(client)
	require('./player_events.lua')(client):run()
	require('./client_events.lua')(client):run()
	require('./commands.lua')(client):run()
end
