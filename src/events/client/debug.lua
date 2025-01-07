return function(client, debug)
  if client.config.bot.DEBUG_MODE then client.logd:debug('Discordia Debug', debug) end
end
