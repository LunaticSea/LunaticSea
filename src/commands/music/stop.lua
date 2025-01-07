local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('cm_music_stop')

function get:name()
	return { 'stop' }
end

function get:description()
	return 'Stop music and make the bot leave the voice channel.'
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

  local player = client.lunalink.players:get(handler.guild.id)

  player.data:set('sudo-destroy', true)
  local is247 = client.db.autoreconnect:get(handler.guild.id)
  player:stop((is247 and is247.twentyfourseven) and false or true)

  local embed = {
    description = client.i18n:get(handler.language, 'command.music', 'stop_msg'),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }
  return handler:edit_reply({ embeds = { embed } })
end

return command