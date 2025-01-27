local arb = require('internal').auto_reconnect_builder
local cms = require('internal').clear_message
local PlayerState = require('lunalink').enums.PlayerState

return function(client, player)
  -- client:update_music(player)

  local guild = client:getGuild(player.guildId)

  if player.data:get('autoplay') == true then
    local author = player.data:get('author')
    local requester = player.data:get('requester')

    local res = player:search(author, { requester = requester, sourceID = 'ytsearch:' })

    local finalRes = res.tracks

    if (#finalRes ~= 0) then
      player:play(#finalRes <= 1 and finalRes[0] or finalRes[1])
      local channel = guild:getChannel(player.textId)
      if channel then return cms(client, channel, player) end
      return
    end
  end

  client.logd:info('QueueEmpty',  string.format("Queue Empty in @ %s / %s", guild.name, player.guildId))

  local data = arb(client, player):get(player.guildId)
  local channel = guild:getChannel(player.textId)
  if channel then return cms(client, channel, player) end
  if data and data.twentyfourseven and channel then return cms(client, channel, player) end

  if player.state ~= PlayerState.DESTROYED then player:destroy() end
end
