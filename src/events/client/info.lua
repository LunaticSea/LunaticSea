return function(client, info)
  if client.config.bot.DEBUG_MODE then client.logd:verbose('Discordia Verbose', info) end
end
