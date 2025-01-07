return function(client, id)
  client.logd:info('Shard Resume', string.format("Shard %s Resumed!", id))
end
