local playerButton = require('../../utils/player_button.lua')

return function(client, player)
  if player.voiceId == nil then return end

  local nowPlaying = client.nplayingMsg:get(player.guildId)
  if nowPlaying then
    nowPlaying.msg:update({
      components = {
        playerButton.filterSelect(client, false),
        playerButton.playerRowOne(client, false),
        playerButton.playerRowTwo(client, false),
      },
    })
  end

  local setup = client.db.setup:get(player.guildId)
  if not setup or not setup.playmsg then return end

  local guild = client.getGuild(player.guildId)
  if not guild then return end
  local channel = guild:getChannel(setup.channel)
  if player.data:get('pause-from-button') then return player.data:delete('pause-from-button') end

  local msg = channel:getMessage(setup.playmsg)
  if not msg then return end

  msg:update({
    components = {
      playerButton.filterSelect(client, false),
      playerButton.playerRowOne(client, false),
      playerButton.playerRowTwo(client, false),
    },
  })
end
