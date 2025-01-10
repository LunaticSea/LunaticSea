local arb = require('internal').auto_reconnect_builder
local cms = require('internal').clear_message

return function(client, player)
  local guild = client:getGuild(player.guildId)
  client.logd:info('TrackEnd', string.format("Track ended in %s @ %s", guild.name, player.guildId))

  -- client:update_music(player)

  local data = arb(client, player):get(player.guildId)
  local text_channel = guild:getChannel(player.textId)
  if text_channel then
    if data and data.twentyfourseven then return end

    if player.queue.size ~= 0 or player.queue.current then
      return cms(client, text_channel, player)
    end

    if player.loop ~= 'none' then return cms(client, text_channel, player) end
  end

  -- I don't trust my wrapper
  local currentPlayer = client.lunalink.players:get(player.guildId)
  if not currentPlayer then return end
  if not currentPlayer.sudoDestroy then return player:destroy() end
end