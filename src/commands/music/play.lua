local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local convert_time = require('internal').convert_time
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('Music:Play')

function get:name()
	return { 'play' }
end

function get:description()
	return 'Play a song from any types'
end

function get:category()
	return 'music'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<name_or_url>'
end

function get:aliases()
	return { 'p', 'pl', 'pp' }
end

function get:config()
	return {
		lavalink = true,
		player_check = false,
		using_interaction = true,
		same_voice_check = false
	}
end

function get:permissions()
	return {}
end

function get:options()
	return {
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

  local value = table.concat(handler.args, ' ')

  if not value then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'play_arg'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  local channel = handler.member.voiceChannel

  if not channel then
    local embed =  {
      description = client.i18n:get(handler.language, 'error', 'no_in_voice'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if not player then
    player = client.lunalink:create({
      guildId = handler.guild.id,
      textId = handler.channel.id,
      voiceId = channel.id,
      shardId = handler.guild.shardId,
      volume = 100
    })
  elseif player and (not self:check_same_voice(client, handler)) then return end

  player._textId = handler.channel.id

  local result = player:search(value, { requester = handler.user })
  local tracks = result.tracks
  if #result.tracks == 0 then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'play_match'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if result.type == 'PLAYLIST' then
    for _, track in pairs(tracks) do
      player.queue:add(track)
    end
  elseif player.playing and result.type == 'SEARCH' then
    player.queue:add(tracks[1])
  elseif player.playing and result.type ~= 'SEARCH' then
    for _, track in pairs(tracks) do
      player.queue:add(track)
    end
  else player.queue:add(tracks[1]) end

  if handler.message then handler.message:delete() end

  if not player.playing then player:play() end

  if result.type == 'TRACK' then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'play_track', {
        self:getTitle(client, result.type, tracks),
        convert_time(tracks[1].duration),
        tracks[1].requester.mentionString
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  elseif result.type == 'PLAYLIST' then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'play_playlist', {
        self:getTitle(client, result.type, tracks, value),
        convert_time(player.queue.duration), #tracks,
        tracks[1].requester.mentionString
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  elseif result.type == 'SEARCH' then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'play_result', {
        self:getTitle(client, result.type, tracks),
        convert_time(tracks[1].duration),
        tracks[1].requester.mentionString
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end
end

function command:check_same_voice(client, handler)
  local bot_voice_id = handler.guild.me.voiceChannel.id
  local user_voice_id = handler.member.voiceChannel.id

  if bot_voice_id ~= user_voice_id then
    local embed =  {
      description = client.i18n:get(handler.language, 'error', 'no_same_voice'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    handler:edit_reply({ embeds = { embed } })
    return false
  end

  return true
end

function command:getTitle(client, type, tracks, value)
  if client.config.player.AVOID_SUSPEND then return tracks[1].title
  else return type == 'PLAYLIST'
    and string.format('[%s](%s)', tracks[1].title, value)
    or string.format('[%s}](%s)', tracks[1].title, tracks[1].uri)
  end
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
