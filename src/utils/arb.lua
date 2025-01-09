-- import { Manager } from '../manager.js'
-- import { RainlinkPlayer } from 'rainlink'

local arb, get = require('class')('AutoReconnectBuilder')

function arb:__init(client, player)
  self._client = client
  self._player = player
end

function arb:execute(guildId)
  local check = self._client.db.autoreconnect:get(guildId)
  if check then return check end
  if not self._player then
    return self:no_player_build(guildId)
  end
  return self:player_build(guildId)
end

function arb:get(guildId)
  return self._client.db.autoreconnect:get(guildId)
end

function arb:no_player_build(guildId)
  return self._client.db.autoreconnect:get(guildId, {
    guild = guildId,
    text = '',
    voice = '',
    current = '',
    config = {
      loop = 'none',
    },
    queue = {},
    twentyfourseven = false,
  })
end

function arb:player_nuild(guildId, two47mode)
  two47mode = two47mode or false
  return self._client.db.autoreconnect:get(guildId, {
    guild = self._player.guildId,
    text = self._player.textId,
    voice = self._player.voiceId,
    current = self._player.queue.current.uri or '',
    config = {
      loop = self._player.loop,
    },
    queue = self._player.queue.size ~= 0 and self:queue_uri() or {},
    previous = self._player.queue.previous.size ~= 0 and self:previousUri() or {},
    twentyfourseven = two47mode,
  })
end

function arb:build247(guildId, mode, voiceId)
  return self._client.db.autoreconnect:get(guildId, {
    guild = self._player.guildId,
    text = self._player.textId,
    voice = voiceId,
    current = '',
    config = {
      loop = 'none',
    },
    queue = {},
    twentyfourseven = mode,
  })
end

function arb:queue_uri()
  local res = {}
  for _, data in pairs(self._player.queue._list) do
    res.push(data.uri)
  end
  return res
end

function arb:previous_uri()
  local res = {}
  for _, data in pairs(self._player.queue.previous) do
    res.push(data.uri)
  end
  return res
end

return arb