return function (client, interaction)
  client._logd:info('Interaction', "Using interaction :0")
  require('pretty-print').prettyPrint(interaction.data)
end