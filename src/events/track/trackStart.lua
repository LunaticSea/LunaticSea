local arb = require('internal').auto_reconnect_builder
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
      name = client.i18n.get(language, 'event.player', 'track_title'),
      iconURL = client.i18n.get(language, 'event.player', 'track_icon'),
    },
    description = {
      
    }
  }
end