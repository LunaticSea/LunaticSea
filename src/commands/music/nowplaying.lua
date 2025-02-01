local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Music:Nowplaying')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local internal = require('internal')
local page_framework = internal.page
local format_duration = internal.format_duration
local get_title = internal.get_title


function get:name()
	return { 'nowplaying' }
end

function get:description()
	return 'Display the song currently playing.'
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
	return { 'np' }
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
  local song = player.queue.current
  local position = player.position
  local CurrentDuration = format_duration(position)
  local TotalDuration =  format_duration(song.duration)
  local Part = math.floor((position / song.duration) * 30)

  local fieldDataGlobal = {
    {
      name = client.i18n:get(handler.language, 'event.player', 'author_title'),
      value = song.author,
      inline = true,
    },
    {
      name = client.i18n:get(handler.language, 'event.player', 'duration_title'),
      value = format_duration(song.duration),
      inline = true,
    },
    {
      name = client.i18n:get(handler.language, 'event.player', 'volume_title'),
      value = player.volume,
      inline = true,
    },
    {
      name = client.i18n:get(handler.language, 'event.player', 'queue_title'),
      value = #player.queue.list,
      inline = true,
    },
    {
      name = client.i18n:get(handler.language, 'event.player', 'total_duration_title'),
      value = format_duration(player.queue.duration),
      inline = true,
    },
    {
      name = client.i18n:get(handler.language, 'event.player', 'request_title'),
      value = song.requester.mentionString,
      inline = true,
    },
    {
      name = client.i18n:get(handler.language, 'event.player', 'download_title'),
      value =  string.format('**[%s](%s})**', song.title, 'https://www.000tube.com/watch?v=' .. song.identifier),
      inline = false,
    },
    {
      name = client.i18n:get(handler.language, 'command.music', 'np_current_duration', {
        CurrentDuration,
        TotalDuration,
      }),
      value = string.format('``` 🔴 | %s```', string.rep('─', Part) .. '🎶' .. string.rep('-', 30 - Part)),
      inline = false,
    },
  }

  local embed = {
    author = {
      name = client.i18n:get(handler.language, 'command.music', 'np_title'),
      icon_url = client.i18n:get(handler.language, 'command.music', 'np_icon'),
    },
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    description = get_title(client, song),
    thumbnail = {
      url = song.artworkUrl or string.format('https://img.youtube.com/vi/%s/maxresdefault.jpg', song.identifier)
    },
    fields = fieldDataGlobal,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command