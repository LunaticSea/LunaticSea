local arb = require('internal').auto_reconnect_builder
local get_title = require('internal').get_title
local format_duration = require('internal').format_duration
local playerButton = require('internal').player_button
local discordia = require('discordia')
local setTimeout = require('timer').setTimeout
local sf = string.format

return function (client, player, track)
  local guild = client:getGuild(player.guildId)
  client.logd:info('TrackStart', sf("Track Started in @ %s / %s", guild.name, player.guildId))

  local SongNoti = client.db.songNoti:get(player.guildId)
  if not SongNoti then
    SongNoti = client.db.songNoti:set(player.guildId, 'enable')
  end

  if SongNoti == 'disable' then return end

  if not player then return end

  -- client:UpdateQueueMsg(player)

  local channel = guild:getChannel(player.textId)
  if not channel then return end

  if (client.config.utilities.AUTO_RESUME) then
    local autoreconnect = arb(client, player)
    autoreconnect:playerBuild(player.guildId)
  end

  local data = client.db.setup:get(channel.guild.id)
  if data and player.textId == data.channel then return end

  local language = client.db.language:get(player.guildId)
	if not language then language = client.i18n.default_locate end

  local song = player.queue.current

  local embedded = {
    author = {
      name = client.i18n:get(language, 'event.player', 'track_title'),
      icon_url = client.i18n:get(language, 'event.player', 'track_icon'),
    },
    description = string.format("**%s**", get_title(client, track)),
    fields = {
      {
        name = client.i18n:get(language, 'event.player', 'author_title'),
        value = song.author,
        inline = true
      },
      {
        name = client.i18n:get(language, 'event.player', 'duration_title'),
        value = format_duration(song.duration),
        inline = true
      },
      {
        name = client.i18n:get(language, 'event.player', 'request_title'),
        value = string.format('<@%s>', song.requester.id),
        inline = true
      },
    },
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    thumbnail = {
      url = track.artworkUrl or string.format("https://img.youtube.com/vi/%s/hqdefault.jpg", track.identifier)
    }
  }

  local nplaying = channel:send({
    embeds = { embedded },
    components = {
      playerButton.filterSelect(client, false),
      playerButton.playerRowOne(client, false),
      playerButton.playerRowTwo(client, false),
    },
  })

  local collector = nplaying:createCollector('button', nil, function (interaction)
    if (
      interaction.guild.me.voiceChannel and interaction.member.voiceChannel and
      interaction.guild.me.voiceChannel.id == interaction.member.voiceChannel.id
    ) then return true end
    interaction:reply({
      content = client.i18n:get(language, 'event.player', 'join_voice'),
      ephemeral = true,
    })
    return false
  end)

  local collectorFilter = nplaying:createCollector('stringSelect', nil, function (interaction)
    if (
      interaction.guild.me.voiceChannel and interaction.member.voiceChannel and
      interaction.guild.me.voiceChannel.id == interaction.member.voiceChannel.id
    ) then return true end
    interaction:reply({
      content = client.i18n:get(language, 'event.player', 'join_voice'),
      ephemeral = true,
    })
    return false
  end)

  client.nplayingMsg:set(player.guildId, {
    coll = collector,
    msg = nplaying,
    filterColl = collectorFilter,
  })

  collectorFilter:on('collect', function (stringMenu)
    local filterMode = stringMenu.data.values[1]

    if player.data:get('filter-mode') ==  filterMode then
      local embed = {
        description = client.i18n:get(language, 'button.music', 'filter_already', { filterMode }),
        color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      }
      local msg = stringMenu:reply({ embeds = { embed } })
      local timeout = client.config.utilities.DELETE_MSG_TIMEOUT
      setTimeout(timeout, coroutine.wrap(function () if msg then msg:delete() end end))
    end

    if filterMode == 'clear' then
      player.data:delete('filter-mode')
      player.filter:clear()
    else
      player.data:set('filter-mode', filterMode)
      player.filter:set(filterMode)
    end

    local embed = {
      description = client.i18n:get(language, 'button.music',
        filterMode == 'clear' and 'reset_on' or 'filter_on',
        filterMode == 'clear' and nil or { filterMode }
      ),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    local msg = stringMenu:reply({ embeds = { embed } })
    local timeout = client.config.utilities.DELETE_MSG_TIMEOUT
    setTimeout(timeout, coroutine.wrap(function () if msg then msg:delete() end end))
  end)

  collector:on('collect', function (button)
    local id = button.data.custom_id
    local target_button = client.plButton[id]

    local success, res = pcall(
      target_button.run,
      target_button,
      client, button,
      language, player,
      nplaying, collector
    )

    if not success then
      local embed = {
        title = string.format('Error on running { %s } player button', target_button.__name),
        description = res,
        color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      }
      button:reply({ embeds = { embed } })
      return client.logd:error('ButtonError', res)
    end
  end)
end