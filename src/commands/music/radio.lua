local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('Music:Radio')
local internal = require('internal')
local radio_station = internal.radio_station
local setTimeout = require('timer').setTimeout

function get:name()
	return { 'radio' }
end

function get:description()
	return 'Play radio in voice channel'
end

function get:category()
	return 'music'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<radio_number>'
end

function get:aliases()
	return {}
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
      name = 'number',
      description = 'The number of radio to choose the radio station',
      type = applicationCommandOptionType.number,
      required = false,
    },
  }
end

function command:run(client, handler)
  local player = client.lunalink.players:get(handler.guild.id)
  local radioList = radio_station.RadioStationNewInterface()
  local radioArrayList = radio_station.RadioStationArray()
  local radioListKeys = {}
  for key, _ in pairs(radioList) do
    table.insert(radioListKeys, key)
  end

  handler:defer_reply()

  local getNum = tonumber(handler.args[1])
  -- Vitural
  if not getNum then return self:sendHelp(client, handler, radioList, radioListKeys) end

  local radioData = radioArrayList[getNum]
  -- Vitural
  if not radioData then return self:sendHelp(client, handler, radioList, radioListKeys) end

  local channel = handler.member.voiceChannel

  if not channel then
    local embed = {
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

  local result = player:search(radioData.link, { requester = handler.user })
  local tracks = result.tracks
  if #result.tracks == 0 then
    local embed = {
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

  local embed = {
    description = client.i18n:get(handler.language, 'command.music', 'radio_accept', {
      radioData.no, radioData.name, radioData.link
    }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  return handler:edit_reply({ embeds = { embed } })
end

function command:sendHelp(client, handler, radioList, radioListKeys)
  local pages = {}
  for i = 1, #radioListKeys, 1 do
    local radioListKey = radioListKeys[i]
    local stringArray = radioList[radioListKey]
    local converted = self:stringConverter(stringArray)

    table.insert(pages, {
      author = {
        name = client.i18n:get(handler.language, 'command.music', 'radio_list_author', { radioListKey }),
        icon_url = handler.user:getAvatarURL() or nil
      },
      fields = converted,
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    })
  end

  local function providerSelector(disable)
    return discordia.Components({
      discordia.SelectMenu({
        id = "provider",
        placeholder = client.i18n:get(handler.language, 'command.music', 'radio_list_placeholder'),
        options = self:getOptionBuilder(radioListKeys),
        disabled = disable
      })
    })
  end

  local msg = handler:edit_reply({
    embeds = { pages[1] },
    components = { providerSelector(false) },
  })

  local collector = msg:createCollector('stringSelect', 45000, function (interaction)
    return interaction.user.id == handler.user.id
  end)

  collector:on('collect', function (stringMenu)
    local providerId = tonumber(stringMenu.data.values[1])
    local providerName = radioListKeys[providerId]
    local getEmbed = pages[providerId]

    stringMenu.message:update({
      embeds = { getEmbed },
      components = { providerSelector(false) }
    })

    local embed = {
      description = client.i18n:get(handler.language, 'command.music', 'radio_list_move', {
        providerName,
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }

    local msgReply = stringMenu:reply({ embeds = { embed } })
    local timeout = client.config.utilities.DELETE_MSG_TIMEOUT
    setTimeout(timeout, coroutine.wrap(function () if msgReply then stringMenu:deleteReply() end end))
  end)

  collector:on('end', function ()
    handler:edit_reply({
      components = { providerSelector(true) },
    })
  end)
end

function command:getOptionBuilder(radioListKeys)
  local result = {}
  for i = 1, #radioListKeys, 1 do
    local key = radioListKeys[i]
    table.insert(result, {
      label = key,
			value = tostring(i),
    })
  end
  return result
end

function command:stringConverter(array)
  local radioStrings = {}
  for i = 1, #array, 1 do
    local radio = array[i]
    table.insert(radioStrings, {
      name =  string.format('**%s** %s', self:pad_end(tostring(radio.no), 3), radio.name),
      value = ' ',
      inline = true,
    })
  end
  return radioStrings
end

function command:pad_end(str, length)
	return str .. string.rep(' ', length - #str)
end

function command:check_same_voice(client, handler)
  local bot_voice_id = handler.guild.me.voiceChannel.id
  local user_voice_id = handler.member.voiceChannel.id

  if bot_voice_id ~= user_voice_id then
    local embed = {
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

return command