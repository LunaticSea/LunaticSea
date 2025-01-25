local arb = require('internal').auto_reconnect_builder
local cms = require('internal').clear_message
local discordia = require('discordia')
local setTimeout = require('timer').setTimeout

return function(client, player)
  local guild = client:getGuild(player.guildId)
  client.logd:error('TrackResolveError', "Track Error in %s @ %s", guild.name, player.guildId)

  -- client:update_music(player)

  local text_channel = guild:getChannel(player.textId)

  -- Get languages
	local language = client.db.language:get(player.guildId)
	if not language then language = client.i18n.default_locate end

  local embed = {
    description = client.i18n:get(language, 'event.player', 'error_desc'),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  if text_channel then
    local setup = client.db.setup:get(player.guildId)
    local msg = text_channel:send({ embeds = { embed } })
    setTimeout(client.config.utilities.DELETE_MSG_TIMEOUT, coroutine.wrap(function ()
      if not setup or setup.channel ~= text_channel.id then msg:delete() end
    end))
  end

  local data247 = arb(client, player):get(player.guildId)
  if data247 and data247.twentyfourseven and text_channel then
    cms(client, text_channel, player)
  end

  -- I don't trust my wrapper
  local currentPlayer = client.lunalink.players:get(player.guildId)
  if not currentPlayer then return end
  if currentPlayer.queue.size > 0 then return player:skip() end
  if not currentPlayer.sudoDestroy then return player:destroy() end
end