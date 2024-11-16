local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command = require('class'):create()

function command:init()
  self.name = {'developer'}
  self.description = 'Shows the developer information of the Bot (Credit)'
  self.category = 'info'
  self.accessableby = {accessableby.member}
  self.usage = ''
  self.aliases = {'dev'}
  self.lavalink = false
  self.playerCheck = false
  self.usingInteraction = true
  self.sameVoiceCheck = false
  self.permissions = {}
  self.options = {}
end

function command:run(client, handler)
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

return command