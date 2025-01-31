local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local internal = require('internal')
local convert_time = internal.convert_time
local get_title = internal.get_title
local command, get = require('class')('Music:Insert')

function get:name()
	return { 'insert' }
end

function get:description()
	return 'Insert a song into a specific position in queue.'
end

function get:category()
	return 'music'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<position> <name_or_url>'
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
      name = 'position',
      description = 'The position in queue want to remove.',
      type = applicationCommandOptionType.number,
      required = true,
    },
    {
      name = 'search',
      description = 'The song link or name',
      type = applicationCommandOptionType.string,
      required = true,
      autocomplete = true,
    },
  }
end

function command:run(client, handler)
  handler:defer_reply()

  local player = client.lunalink.players:get(handler.guild.id)
  local position = tonumber(handler.args[1])
  local song = table.concat(table.slice(handler.args, 1, #handler.args), ' ')

  if not position then
    local embed =  {
      description = client.i18n:get(handler.language, 'error', 'number_invalid'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if position == 0 then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'insert_already'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if position > #player.queue then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'insert_notfound'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  local result = player:search(song, { requester = handler.user })
  local track = result.tracks[1]

  table.insert(player.queue.list, position, track)

  local embed =  {
    description = client.i18n:get(handler.language, 'command.music', 'insert_desc', {
      get_title(client, track), convert_time(player.position), track.requester.mentionString
    }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }
  return handler:edit_reply({ embeds = { embed } })
end

function command:autocomplete(client, interaction, language)
  local choices = {}
  local input = interaction.data.options[1].value

  math.randomseed(os.time())

  local RandomNum = math.random(#client.config.player.AUTOCOMPLETE_SEARCH)
  local Random = client.config.player.AUTOCOMPLETE_SEARCH[RandomNum]

  if string.match(input, 'https?://') then
    table.insert(choices, { name = input, value = input })
    return interaction:autocomplete(choices)
  end

  if #client._lavalink_using == 0 then
    table.insert(choices, {
      name = client.i18n:get(language, 'command.music', 'no_node'),
      value = client.i18n:get(language, 'command.music', 'no_node')
    })
    return interaction:autocomplete(choices)
  end

  local searchRes = client.lunalink:search(input or Random)
  local tracks = searchRes.tracks

  if #tracks == 0 then
    table.insert(choices, {
      name = 'Error song not matches',
      value = input
    })
    return interaction:autocomplete(choices)
  end

  for i = 1, 10, 1 do
    local x = tracks[i]
    table.insert(choices, {
      name = (x and x.title) and x.title or 'Unknown track name',
      value = input
    })
  end

  return interaction:autocomplete(choices)
end

return command