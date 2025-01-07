return function(client, log)
  if client.config.bot.DEBUG_MODE then client.logd:info('Lunalink Debug', log) end
end
