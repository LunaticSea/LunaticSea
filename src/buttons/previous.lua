local bc, get = require('class')('Button@Previous')
local reply_interaction = require('internal').reply_interaction


function get:name()
  return 'previous'
end

function bc:run(client, button, language, player, nplaying, collector)
  if not player and collector then collector:stop() end

  if #player.queue.previous == 0 then
    return reply_interaction(client, button, client.i18n:get(language, 'button.music', 'previous_notfound'))
  end

  player:previous()

  player.data:set('endMode', 'previous')

  return reply_interaction(
    client,
    button,
    client.i18n:get(language, 'button.music', 'previous_msg')
  )
end

return bc