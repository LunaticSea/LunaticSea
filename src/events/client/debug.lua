return function(client, debug)
  if client.config.bot.DEBUG_MODE then client.logd:info('Discordia Debug', debug) end
end
