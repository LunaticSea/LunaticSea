return function(client, id)
  client.logd:info('Shard Ready', string.format("Shard %s ready!", id))
end
