return function(client, node, err)
  client.logd:info('NodeError', string.format("Lavalink [%s] error %s", node.options.name, err))
end
