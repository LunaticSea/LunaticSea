return function(client, node, code, reason)
  for _, data in pairs(client.lunalink.players:full()) do
    data[2]:destroy()
  end
  client.logd:warn(
    'NodeDisconnect',
    string.format(
      "Lavalink [%s] Disconnected, Code: %s, Reason: %s",
      node.options.name,
      code, reason
    )
  )
end
