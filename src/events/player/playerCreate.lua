return function(client, player)
  local guild = client.guilds:get(player.guildId)
  client.logger.info('PlayerCreate',
    string.format("Player Created in @ %s / %s", guild.name, player.guildId)
  )
end
