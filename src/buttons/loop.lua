local bc, get = require('class')('Button@Loop')
local reply_interaction = require('internal').reply_interaction


function get:name()
  return 'loop'
end

function bc:run(client, button, language, player, nplaying, collector)
end

return bc