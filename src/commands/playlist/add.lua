local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local convert_time = require('internal').convert_time
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('Playlist:Add')

function get:name()
	return { 'pl', 'add' }
end

function get:description()
	return 'Add song to a playlist'
end

function get:category()
	return 'playlist'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<playlist_id> <url_or_name>'
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

  local PlaylistID = handler.args[1]
  local SongName = table.concat(table.slice(handler.args, 2, #handler.args), ' ')
  local Playlist = client.db.playlist:get(PlaylistID)

  if not Playlist then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'invalid'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if Playlist.owner ~= handler.user.id then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'add_owner'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if not SongName then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'add_match'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  local result = client.lunalink:search(SongName, { requester = handler.user })
  local tracks = result.tracks
  if #result.tracks == 0 then
    local embed = {
      description = client.i18n:get(handler.language, 'command.music', 'play_match'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  local TrackAdd = {}

  if result.type == 'PLAYLIST' then
    for _, track in pairs(result.tracks) do table.insert(TrackAdd, track) end
  else table.insert(TrackAdd, result.tracks[1]) end

  local Duration = convert_time(tracks[1].duration)
  local TotalDuration = table.reduce(tracks, function (acc, cur)
    return acc + (cur.duration or 0)
  end, tracks[1].duration or 0)

  if result.type == 'TRACK' then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'add_track', {
        self:getTitle(client, result.type, tracks),
        Duration, tracks[1].requester.mentionString
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    handler:edit_reply({ embeds = { embed } })
  elseif result.type == 'PLAYLIST' then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'add_playlist', {
        self:getTitle(client, result.type, tracks, SongName),
        convert_time(TotalDuration), #tracks,
        tracks[1].requester.mentionString
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    handler:edit_reply({ embeds = { embed } })
  elseif result.type == 'SEARCH' then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'add_search', {
        self:getTitle(client, result.type, tracks),
        Duration, tracks[1].requester.mentionString
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    handler:edit_reply({ embeds = { embed } })
  else
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'add_match'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  local LimitTrack = #Playlist.tracks + #TrackAdd

  if LimitTrack > client.config.player.LIMIT_TRACK then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'add_limit_track', {
        client.config.player.LIMIT_TRACK
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  local req_user = {
    id = TrackAdd[1].requester.id,
    defaultAvatarURL = TrackAdd[1].requester:defaultAvatarURL(),
    avatarURL = TrackAdd[1].requester:avatarURL(),
    mentionString = TrackAdd[1].requester.mentionString,
    name = TrackAdd[1].requester.name,
    username = TrackAdd[1].requester.username,
  }

  for _, track in pairs(TrackAdd) do
    table.insert(Playlist.tracks, {
      title = track.title,
      uri = track.uri,
      length = track.duration,
      thumbnail = track.artworkUrl,
      author = track.author,
      requester = req_user,
    })
  end

  local embed = {
    description = client.i18n:get(handler.language, 'command.playlist', 'add_added', {
      #TrackAdd, PlaylistID
    }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }
  return handler:follow_up({ embeds = { embed } })
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