local bc, get = require('class')('Button@Queue')
local reply_interaction = require('internal').reply_interaction


function get:name()
  return 'queue'
end

function bc:run(client, button, language, player, nplaying, collector)
end

return bc