local bc, get = require('class')('Button@Pause')
local reply_interaction = require('internal').reply_interaction
local playerButton = require('internal').player_button

function get:name()
  return 'pause'
end

function bc:run(client, button, language, player, nplaying, collector)
  if not player and collector then collector:stop() end

  player.data.set('pause-from-button', true)

  local newPlayer = player:setPause(not player.paused)

  local new_component = {
    playerButton.filterSelect(client, false),
    playerButton.playerRowOne(client, false, player.paused),
    playerButton.playerRowTwo(client, false),
  }

  nplaying:update({ components = new_component })

  reply_interaction(
    client,
    button,
    client.i18n:get(language, 'button.music', newPlayer.paused and 'pause_msg' or 'resume_msg')
  )
end

return bc