-- local discordia = require('discordia')
-- local arb = require('../../utils/arb.lua')
-- local cms = require('../../services/clear_message_service.lua')
-- local setTimeout = require('timer').setTimeout

return function(client, player)
--   -- client:update_music(player)

--   local guild = client:getGuild(player.guildId)

--   if player.data:get('autoplay') == true then
--     local author = player.data:get('author')
--     local title = player.data:get('title')
--     local requester = player.data:get('requester')
--     local identifier = player.data:get('identifier')
--     local source = player.data:get('source')
--     if string.gsub(source, "%f[%a]%u+%f[%A]", string.lower) ~= 'youtube' then
--       local internalQuery = table.filter({ author, title }, function (x) return x end)
--       local findQuery = 'directSearch=ytsearch:' +  table.concat(internalQuery, ' - ')
--       local preRes = player:search(findQuery, { requester = requester })
--       if preRes.tracks.length ~= 0 and preRes.tracks[0].identifier then
--         identifier = preRes.tracks[0].identifier
--       end
--     end
--     local search = string.format("https://www.youtube.com/watch?v=%s&list=RD%s", identifier, identifier)
--     local res = player:search(search, { requester = requester })
--     local finalRes = talbe.filter(res.tracks, function(track) 
--       local req1 = table.s !player.queue.some((s) => s.encoded === track.encoded)
--       local req2 = !player.queue.previous.some((s) => s.encoded === track.encoded)
--       return req1 && req2
--     end)
--     if (finalRes.length !== 0) {
--       player.play(finalRes.length <= 1 ? finalRes[0] : finalRes[1])
--       const channel = (await client.channels
--         .fetch(player.textId)
--         .catch(() => undefined)) as TextChannel
--       if (channel) return new ClearMessageService(client, channel, player)
--       return
--     }
--   end

--   -- client.logger.info('QueueEmpty', `Queue Empty in @ ${guild!.name} / ${player.guildId}`)

--   -- const data = await new AutoReconnectBuilderService(client, player):get(player.guildId)
--   -- const channel = (await client.channels
--   --   .fetch(player.textId)
--   --   .catch(() => undefined)) as TextChannel
--   -- if (data !== null && data && data.twentyfourseven && channel)
--   --   return new ClearMessageService(client, channel, player)

--   -- if (player.state !== RainlinkPlayerState.DESTROYED) await player.destroy().catch(() => {})
end
