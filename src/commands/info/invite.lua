local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')

return {
  info = {
    name =  {'invite'},
    description = 'Shows the invite information of the Bot',
    category = 'Info',
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
    local desc = string.format(
      "[Click here to invite!](%s)\n**Thanks for Inviting me in advance! 💫**",
      link
    )

    local embed_data = {
      title = string.format("✉️ %s", client.user.username),
      description = desc,
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value
    }
    message.channel:send({ embed = embed_data })
  end
}