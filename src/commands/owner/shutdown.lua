local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Owner:Shutdown')

function get:name()
	return { 'shutdown' }
end

function get:description()
	return 'Shuts down the client!'
end

function get:category()
	return 'owner'
end

function get:accessableby()
	return { accessableby.owner }
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

	local embed = {
		description = client.i18n:get(handler.language, 'command.admin', 'restart_msg'),
		color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
	}

	handler:edit_reply({ embeds = { embed } })

	os.exit()
end

return command