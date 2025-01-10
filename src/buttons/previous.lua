local bc, get = require('class')('Button@Previous')
local reply_interaction = require('internal').reply_interaction


function get:name()
  return 'previous'
end

function bc:run(client, button, language, player, nplaying, collector)
end

return bc