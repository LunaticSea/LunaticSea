local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')

return {
  info = {
    name =  {'ping'},
    description = 'Shows the ping of the Bot',
    category = 'info',
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
  execute = function (client, handler)
    handler:defer_reply()

    local msg_time = math.floor(handler.createdAt + 0.5)
    local ping = tostring(msg_time - os.time())

    local embed_data = {
      title = "🏓 " .. client.user.username,
      description = client._i18n:get(handler.language, 'command.info', 'ping_desc', { ping }),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
      timestamp = discordia.Date():toISO('T', 'Z')
    }
    handler:edit_reply({ embeds = {embed_data} })
  end
}