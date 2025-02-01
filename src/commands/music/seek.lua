local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Music:Seek')
local time_pattern = '%d?%d?%d:[0-5][0-6]'
local internal = require('internal')
local format_duration = internal.format_duration
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType

function get:name()
	return { 'seek' }
end

function get:description()
	return 'Seek timestamp in the song!'
end

function get:category()
	return 'music'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<time_format. Ex: 999:59>'
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
	return {
    {
      name = 'time',
      description = 'Set the position of the playing track. Example: 0:10 or 120:10',
      type = applicationCommandOptionType.string,
      required = true,
    },
  }
end

function command:run(client, handler)
	handler:defer_reply()

  local player = client.lunalink.players:get(handler.guild.id)

  local value
  local time = handler.args[1]

  if not string.match(time, time_pattern) or player.queue.current.isSeekable then
    local embed = {
      description = client.i18n:get(handler.language, 'command.music', 'seek_invalid'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  else
    local te = string.split(time, ':')
    value = ((tonumber(te[1]) * 60) + tonumber(te[2])) * 1000
  end

  if value >= player.queue.current.duration or value < 0 then
    local embed = {
      description = client.i18n:get(handler.language, 'command.music', 'seek_beyond'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  player:seek(value)

  local song_position = player.position

  local final_res

  if song_position < value then
    final_res = song_position + value
  else final_res = value end

  local Duration = format_duration(final_res)

  local embed = {
    description = client.i18n:get(handler.language, 'command.music', 'seek_msg', { Duration }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command