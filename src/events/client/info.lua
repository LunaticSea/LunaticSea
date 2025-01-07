return function(client, info)
  if client.config.bot.DEBUG_MODE then client.logd:info('Discordia Verbose', info) end
end
