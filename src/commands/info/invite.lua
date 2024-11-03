local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')

return {
  info = {
    name =  {'invite'},
    description = 'Shows the invite information of the Bot',
    category = 'info',
    accessableby = {accessableby.member},
    usage = '',
    aliases = {'inv'},
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
    local link = string.format(
      "https://discord.com/api/oauth2/authorize?client_id=%s",
      client.user.id
    ) .. "&permissions=8&scope=bot%20applications.commands"

    local linkActionRow = discordia.Components {
      {
        type = 'button',
        label = "Invite Me",
        style = "link",
        url = link
      }
    }

    local embed_data = {
      title = string.format("✉️ %s", client.user.username),
      description = client._i18n:get('en_US', 'command.info', 'invite_desc'),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value
    }

    message:replyComponents({ embed = embed_data, components = linkActionRow })
  end
}