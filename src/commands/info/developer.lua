local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Info:Developer')

function get:name()
	return { 'developer' }
end

function get:description()
	return 'Shows the developer information of the Bot (Credit)'
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
	return { 'dev' }
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

	local linkActionRow = discordia.Components{ {
		type = 2,
		label = 'Github (RainyXeon)',
		style = 5,
		url = 'https://github.com/RainyXeon',
	}, {
		type = 2,
		label = 'Support Server (DeepinRain)',
		style = 5,
		url = 'https://discord.gg/xff4e2WvVy',
	} }

	local embed_data = {
		title = 'RainyXeon',
		description = client.i18n:get(handler.language, 'command.info', 'dev_footer'),
		color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		footer = { text = client.i18n:get(handler.language, 'command.info', 'dev_footer') },
	}

	handler:edit_reply({
		embeds = { embed_data },
		components = linkActionRow,
	})
end

return command
