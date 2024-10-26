return function (client, message)
	if message.content == '!ping' then
		message.channel:send('Pong!')
	end
end