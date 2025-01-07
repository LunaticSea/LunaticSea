return function(client, debug)
  if client.config.bot.DEBUG_MODE then client.logd:info('Client Debug', debug) end
end
