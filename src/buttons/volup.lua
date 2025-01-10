local bc, get = require('class')('Button@VolumeDown')
local reply_interaction = require('internal').reply_interaction


function get:name()
  return 'volup'
end

function bc:run(client, button, language, player, nplaying, collector)
end

return bc