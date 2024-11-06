local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')

local command = {}

function command:new()
  self.name = {'invite'}
  self.description = 'Shows the invite information of the Bot'
  self.category = 'info'
  self.accessableby = {accessableby.member}
  self.usage = ''
  self.aliases = {'inv'}
  self.lavalink = false
  self.playerCheck = false
  self.usingInteraction = true
  self.sameVoiceCheck = false
  self.permissions = {}
  self.options = {}
  return self
end

function command:run(client, handler)
  handler:defer_reply()

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
    description = client._i18n:get(handler.language, 'command.info', 'invite_desc'),
    color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value
  }

  handler:edit_reply({
    embeds = {embed_data},
    components = linkActionRow
  })
end

return command