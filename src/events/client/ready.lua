return function(client)
	client.logd:info('Client Ready', 'Bot is ready! Welcome back ' .. client.user.username)
	require('../../services/deploy_service')(client):register()
end
