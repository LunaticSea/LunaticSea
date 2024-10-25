local discordia = require('discordia')
local Dotenv = require('Dotenv')
local client = discordia.Client({
	logFile = ".//",
	logLevel = 0
})
Dotenv.load_env()

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
	if message.content == '!ping' then
		message.channel:send('Pong!')
	end
end)

client:run("Bot " .. Dotenv.get_value("TOKEN"))