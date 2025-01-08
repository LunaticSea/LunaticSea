local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Info:Invite')

function get:name()
	return { 'invite' }
end

function get:description()
	return 'Shows the invite information of the Bot'
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
	return { 'inv' }
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

	local link =
		string.format(
			'https://discord.com/api/oauth2/authorize?client_id=%s',
			client.user.id
		) .. '&permissions=8&scope=bot%20applications.commands'

	local linkActionRow = discordia.Components{ {
		type = 'button',
		label = 'Invite Me',
		style = 'link',
		url = link,
	} }

	local embed_data = {
		title = string.format('✉️ %s', client.user.username),
		description = client.i18n:get(handler.language, 'command.info', 'invite_desc'),
		color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
	}

	handler:edit_reply({
		embeds = { embed_data },
		components = linkActionRow,
	})
end

return command
