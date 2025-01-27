local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Music:Forward')
local internal = require('internal')
local format_duration = internal.format_duration

function get:name()
	return { 'forward' }
end

function get:description()
	return 'Forward timestamp in the song! (10s)'
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
  local fastForwardNum = 10

	handler:defer_reply()

  local player = client.lunalink.players:get(handler.guild.id)
  local song = player.queue.current
  local song_position = player.position
  local current_duration = format_duration(song_position + fastForwardNum * 1000)

  if current_duration < song.duration then
    player:send({
      guildId = handler.guild.id,
      playerOptions = { position = current_duration },
    })
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'forward_msg', { current_duration }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }

    handler:edit_reply({ content = ' ', embeds = { embed } })
  else
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'forward_beyond'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }

    handler:edit_reply({ content = ' ', embeds = { embed } })
  end
end

return command
