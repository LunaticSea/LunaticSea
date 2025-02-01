local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Music:Pause')

function get:name()
	return { 'pause' }
end

function get:description()
	return 'Pause the music!'
end

function get:category()
	return 'music'
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
		lavalink = true,
		player_check = true,
		using_interaction = true,
		same_voice_check = true
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

  local player = client.lunalink.players:get(handler.guild.id)

  player:pause()

  local embed = {
    description = client.i18n:get(handler.language, 'command.music', 'pause_msg'),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command