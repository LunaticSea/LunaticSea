return function(client, node)
  client.logd:info('NodeConnect', string.format("Lavalink [%s] connected.", node.options.name))
end
