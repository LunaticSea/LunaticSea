local bc, get = require('class')('Button@Skip')
local reply_interaction = require('internal').reply_interaction

function get:name()
  return 'skip'
end

function bc:run(client, button, language, player, nplaying, collector)
  if not player and collector then collector:stop() end

  if (player.queue.size == 0 and player.data:get('autoplay') ~= true) then
    return reply_interaction(client, button, client.i18n:get(language, 'button.music', 'skip_notfound'))
  end

  player:skip()

  return reply_interaction(client, button, client.i18n:get(language, 'button.music', 'skip_msg'))
end

return bc