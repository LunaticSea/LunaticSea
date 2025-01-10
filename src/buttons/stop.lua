local bc, get = require('class')('Button@Stop')
local reply_interaction = require('internal').reply_interaction


function get:name()
  return 'stop'
end

function bc:run(client, button, language, player, nplaying, collector)
end

return bc