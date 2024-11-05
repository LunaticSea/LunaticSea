local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')

return {
  info = {
    name =  {'developer'},
    description = 'Shows the developer information of the Bot (Credit)',
    category = 'info',
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
  execute = function (client, handler)
    handler:defer_reply()
    local linkActionRow = discordia.Components {
      {
        type = 2,
        label = "Github (RainyXeon)",
        style = 5,
        url = 'https://github.com/RainyXeon'
      },
      {
        type = 2,
        label = "Support Server (DeepinRain)",
        style = 5,
        url = 'https://discord.gg/xff4e2WvVy'
      }
    }

    local embed_data = {
      title = "RainyXeon",
      description = client._i18n:get(handler.language, 'command.info', 'dev_footer'),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
      footer = {
        text = client._i18n:get(handler.language, 'command.info', 'dev_footer')
      }
    }

    handler:edit_reply({
      embeds = {embed_data},
      components = linkActionRow
    })
  end
}