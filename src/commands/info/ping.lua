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
      description = string.format('**Ping:** `%s ms`', ping),
      color = discordia.Color.fromHex('#2B2D31').value,
      timestamp = discordia.Date():toISO('T', 'Z')
    }
    message.channel:send({ embed = embed_data })
  end
}