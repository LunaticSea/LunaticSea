local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Info:Uptime')
local uv = require('uv')
local ms = require('ms')

function get:name()
	return { 'uptime' }
end

function get:description()
	return 'Shows the uptime information of the Bot'
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
	handler:defer_reply()

	local embed_data = {
		author = {
      name = client.i18n:get(handler.language, 'command.info', 'uptime_title') .. client.user.username
    },
		description = client.i18n:get(handler.language, 'command.info', 'uptime_desc', { ms(client.uptime) }),
		color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		timestamp = discordia.Date():toISO('T', 'Z'),
	}
	handler:edit_reply({
		embeds = { embed_data },
	})
end

return command