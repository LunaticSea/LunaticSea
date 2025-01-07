return function(client, node)
  client.logd:info('NodeClosed', string.format("Lavalink [%s] Closed", node.options.name))
end
