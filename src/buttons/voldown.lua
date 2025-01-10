local bc, get = require('class')('Button@VolumeUp')
local reply_interaction = require('internal').reply_interaction


function get:name()
  return 'voldown'
end

function bc:run(client, button, language, player, nplaying, collector)
end

return bc