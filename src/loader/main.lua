local event_loader = require('./event.lua')

return function (client)
  local eventl = event_loader.new(client)
  eventl.run()
end