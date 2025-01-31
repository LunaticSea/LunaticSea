local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local internal = require('internal')
local convert_time = internal.convert_time
local get_title = internal.get_title
local command, get = require('class')('Music:Remove')

function get:name()
	return { 'remove' }
end

function get:description()
	return 'Remove song from queue.'
end

function get:category()
	return 'music'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<position>'
end

function get:aliases()
	return { 'rm' }
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
      name = 'position',
      description = 'The position in queue want to remove.',
      type = applicationCommandOptionType.number,
      required = true,
    },
  }
end

function command:run(client, handler)
	handler:defer_reply()

  local player = client.lunalink.players:get(handler.guild.id)

  local tracks = tonumber(handler.args[1])

  if not tracks then
    local embed =  {
      description = client.i18n:get(handler.language, 'error', 'number_invalid'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if tracks == 0 then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'removetrack_already'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if tracks > #player.queue then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'removetrack_notfound'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  local song = player.queue.list[tracks]

  table.remove(player.queue.list, tracks)

  local embed = {
    description = client.i18n:get(handler.language, 'command.music', 'removetrack_desc', {
      get_title(client, song), convert_time(player.position), song.requester.mentionString
    }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command
