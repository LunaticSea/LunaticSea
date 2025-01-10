local discordia = require('discordia')
local arb = require('internal').auto_reconnect_builder
local cms = require('internal').clear_message
local setTimeout = require('timer').setTimeout

return function(client, player)
  local guild = client:getGuild(player.guildId)

  client.logd:info('PlayerStop', string.format("Player Stop in %s @ %s", guild.name, player.guildId))

  -- client:update_music(player)

  local text_channel = guild:getChannel(player.textId)
  client.sentQueue:set(player.guildId, false)
  local arbs = arb(client, player)
  local data = arbs:get(player.guildId)

  if not text_channel then return end

  if data and data.twentyfourseven then
    arb:build247(player.guildId, true, data.voice)
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
