local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')

return {
  info = {
    name =  {'ping'},
    description = 'Shows the ping of the Bot',
    category = 'Info',
    accessableby = {accessableby.member},
    usage = '',
    aliases = {},
  },
  config = {
    lavalink = false,
    playerCheck = false,
    usingInteraction = true,
    sameVoiceCheck = false,
    permissions = {},
    options = {},
  },
  execute = function (client, message)
    local msg_time = math.floor(message.createdAt + 0.5)
    local ping = tostring(msg_time - os.time())

    local embed_data = {
      title = "🏓 " .. client.user.username,
      description = client._i18n.get('en_US', 'command.info', 'ping_desc', { ping }),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
      timestamp = discordia.Date():toISO('T', 'Z')
    }
    message.channel:send({ embed = embed_data })
  end
}