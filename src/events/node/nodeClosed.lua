return function(client, node)
  client.logd:warn('NodeClosed', string.format("Lavalink [%s] Closed", node.options.name))
end
