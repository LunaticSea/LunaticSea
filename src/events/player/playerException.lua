local discordia = require('discordia')
local arb = require('internal').auto_reconnect_builder
local cms = require('internal').clear_message

return function(client, player, data)
  client.logd:error('PlayerException',
    string.format("Player get exception: %s", require('json').encode(data))
  )
  local guild = client:getGuild(player.guildId)

  -- client:update_music(player)

  local text_channel = guild:getChannel(player.textId)
  if text_channel then
    local embed =  {
      description = string.format("Player get exception, please contact with owner to fix this error\n\n", require('json').encode(data)),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }

    text_channel:send({ content = ' ', embeds = { embed } })
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
