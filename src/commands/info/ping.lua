local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Info:Ping')
local stopwatch = discordia.Stopwatch()

function get:name()
	return { 'ping' }
end

function get:description()
	return 'Shows the ping of the Bot'
end

function get:category()
	return 'info'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return ''
end

function get:aliases()
	return {}
end

function get:config()
	return {
		lavalink = false,
		player_check = false,
		using_interaction = true,
		same_voice_check = false
	}
end

function get:permissions()
	return {}
end

function get:options()
	return {}
end

function command:run(client, handler)
	stopwatch:reset()
	stopwatch:start()
	handler:defer_reply()
	stopwatch:stop()

	local ping = math.floor(stopwatch:getTime():toMilliseconds()+0.5)

	local embed_data = {
		title = '🏓 ' .. client.user.username,
		description = client.i18n:get(handler.language, 'command.info', 'ping_desc', { ping }),
		color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		timestamp = discordia.Date():toISO('T', 'Z'),
	}
	handler:edit_reply({
		embeds = { embed_data },
	})
end

return command