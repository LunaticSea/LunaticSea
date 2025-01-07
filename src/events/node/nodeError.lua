return function(client, node, err)
  client.logd:error('NodeError', string.format("Lavalink [%s] error %s", node.options.name, err))
end
