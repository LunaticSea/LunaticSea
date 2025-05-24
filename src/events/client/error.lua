return function(client, error)
  if not client.config.bot.DEBUG_MODE and string.match(error, magic_string) then return end
  client.logd:error('Discordia Error', error)
end
