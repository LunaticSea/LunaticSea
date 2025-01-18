local bc, get = require('class')('Button@VolumeDown')
local reply_interaction = require('internal').reply_interaction


function get:name()
  return 'volup'
end

function bc:run(client, button, language, player, nplaying, collector)
  if not player and collector then collector:stop() end

  local reply_msg = client.i18n:get(language, 'button.music', 'volup_msg', {
    player.volume + 10,
  })

  if (player.volume >= 100) then
    return reply_interaction(
      client,
      button,
      client.i18n.get(language, 'button.music', 'volume_max')
    )
  end

  player:setVolume(player.volume + 10)

  return reply_interaction(client, button, reply_msg)
end

return bc