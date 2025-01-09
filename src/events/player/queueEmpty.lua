local arb = require('../../utils/arb.lua')
local cms = require('../../services/clear_message_service.lua')
local PlayerState = require('lunalink').enums.PlayerState

return function(client, player)
  -- client:update_music(player)

  local guild = client:getGuild(player.guildId)

  if player.data:get('autoplay') == true then
    local author = player.data:get('author')
    local title = player.data:get('title')
    local requester = player.data:get('requester')
    local identifier = player.data:get('identifier')
    local source = player.data:get('source')

    if string.gsub(source, "%f[%a]%u+%f[%A]", string.lower) ~= 'youtube' then
      local internalQuery = table.filter({ author, title }, function (x) return x end)
      local findQuery = 'directSearch=ytsearch:' +  table.concat(internalQuery, ' - ')
      local preRes = player:search(findQuery, { requester = requester })
      if preRes.tracks.length ~= 0 and preRes.tracks[0].identifier then
        identifier = preRes.tracks[0].identifier
      end
    end
  
    local search = string.format("https://www.youtube.com/watch?v=%s&list=RD%s", identifier, identifier)
    local res = player:search(search, { requester = requester })
    local finalRes = table.filter(res.tracks, function(track)
      local req1 = table.some(player.queue.list, function (s)
        return s.encoded == track.encoded
      end)
      local req2 = table.some(player.queue.previous, function (s)
        return s.encoded == track.encoded
      end)
      return req1 and req2
    end)

    if (#finalRes.length ~= 0) then
      player:play(finalRes.length <= 1 and finalRes[0] or finalRes[1])
      local channel = guild:getChannel(player.textId)
      if channel then return cms(client, channel, player) end
      return
    end
  end

  client.logger.info('QueueEmpty',  string.format("Queue Empty in @ %s / %s", guild.name, player.guildId))

  local data = arb(client, player):get(player.guildId)
  local channel = guild:getChannel(player.textId)
  if channel then return cms(client, channel, player) end
  if data and data.twentyfourseven and channel then return cms(client, channel, player) end

  if player.state ~= PlayerState.DESTROYED then player:destroy() end
end
