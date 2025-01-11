local bc, get = require('class')('Button@Stop')
local reply_interaction = require('internal').reply_interaction

function get:name()
  return 'stop'
end

function bc:run(client, button, language, player, nplaying, collector)
  if not player and collector then collector:stop() end

  player.data:set('sudo-destroy', true)
  local is247 = client.db.autoreconnect:get(button.guild.id)
  player.stop(not (is247 and is247.twentyfourseven))

  reply_interaction(
    client,
    button,
    client.i18n:get(language, 'button.music', 'stop_msg')
  )
end

return bc