local bc, get = require('class')('Button@Clear')
local reply_interaction = require('internal').reply_interaction


function get:name()
  return 'clear'
end

function bc:run(client, button, language, player, nplaying, collector)
  if not player and collector then collector:stop() end

  player.queue:clear()

  return reply_interaction(client, button, client.i18n:get(language, 'button.music', 'clear_msg'))
end

return bc