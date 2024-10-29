local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')

return {
  info = {
    name =  {'developer'},
    description = 'Shows the developer information of the Bot (Credit)',
    category = 'Info',
    accessableby = {accessableby.member},
    usage = '',
    aliases = {'dev'},
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

    local desc = string.format(
      "Powered by Salmon :)\n - **Github:** %s\n - **Support server:** %s",
      '[RainyXeon](https://github.com/RainyXeon)',
      '[DeepinRain](https://discord.gg/xff4e2WvVy)'
    )

    local embed_data = {
      title = "RainyXeon",
      description = desc,
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
      footer = {
        text = "Consider joining my server or inviting my bots :) This would help me a lot!"
      }
    }
    message.channel:send({ embed = embed_data })
  end
}