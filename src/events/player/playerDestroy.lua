local discordia = require('discordia')
local arb = require('../../utils/arb.lua')
local cms = require('../../services/clear_message_service.lua')
local setTimeout = require('timer').setTimeout

return function(client, player)
  local guild = client:getGuild(player.guildId)

  client.logd:error('PlayerDestroy', string.format("Player Destroy in %s @ %s", guild.name, player.guildId))

  -- client:update_music(player)

  local text_channel = guild:getChannel(player.textId)
  client.sentQueue:set(player.guildId, false)
  local arbs = arb(client, player)
  local data = arbs:get(player.guildId)

  if not text_channel then return end

  if data and data.twentyfourseven then
    arbs:build247(player.guildId, true, data.voice)
    client.lunalink.players:create({
      guildId = data.guild,
      voiceId = data.voice,
      textId = data.text,
      shardId = guild.shardId or 0,
      deaf = true,
      volume = client.config.player.DEFAULT_VOLUME,
    })
  else
    client.db.autoreconnect:delete(player.guildId)
  end

  -- Get languages
	local language = client.db.language:get(player.guildId)
	if not language then language = client.i18n.default_locate end

  local isSudoDestroy = player.data:get('sudo-destroy')

  local embed = {
    description = client.i18n:get(language, 'event.player', 'queue_end_desc'),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  local setup = client.db.setup:get(player.guildId)

  if not isSudoDestroy then
    local msg = text_channel:send({ embeds = { embed } })
    setTimeout(client.config.utilities.DELETE_MSG_TIMEOUT, coroutine.wrap(function ()
      if not setup and setup.channel ~= text_channel.id then msg:delete() end
    end))
  end

  if setup and setup.channel == player.textId then return end
  cms(client, text_channel, player)
  player.data:clear()
end
