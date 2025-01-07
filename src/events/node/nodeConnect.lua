return function(client, node)
  table.insert(client._lavalink_using, {
    host = node.options.host,
    port = node.options.port or 0,
    pass = node.options.auth,
    secure = node.options.secure,
    name = node.options.name,
  })
  client.logd:info('NodeConnect', string.format("Lavalink [%s] connected.", node.options.name))
end
