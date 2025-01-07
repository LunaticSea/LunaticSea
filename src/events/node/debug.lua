return function(client, log)
  if client.config.bot.DEBUG_MODE then client.logd:debug('Lunalink Debug', log) end
end
