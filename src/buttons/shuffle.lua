local bc, get = require('class')('Button@Shuffle')
local reply_interaction = require('internal').reply_interaction


function get:name()
  return 'shuffle'
end

function bc:run(client, button, language, player, nplaying, collector)
end

return bc