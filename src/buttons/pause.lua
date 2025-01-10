local bc, get = require('class')('Button@Pause')
local reply_interaction = require('internal').reply_interaction


function get:name()
  return 'pause'
end

function bc:run(client, button, language, player, nplaying, collector)
end

return bc