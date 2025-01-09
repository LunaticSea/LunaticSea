local cms = require('class')('ClearMessageService')

function cms:__init(client, channel, player)
  self._channel = channel
  self._client = client
  self._player = player
  self:execute()
end

function cms:execute()
  local nplayingMsg = self._client.nplayingMsg:get(self._player and self._player.guildId or '')
  if not nplayingMsg then return end
  nplayingMsg.coll:stop()
  nplayingMsg.filterColl:stop()
  nplayingMsg.msg:delete()
  self._client.nplayingMsg:delete(self._player.guildId)
end

return cms