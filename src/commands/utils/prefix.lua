local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command = require('class'):create()

function command:init()
  self.name = {'prefix'}
  self.description = 'Change the prefix for the bot'
  self.category = 'utils'
  self.accessableby = {accessableby.member}
  self.usage = '<input>'
  self.aliases = {'setprefix', 'pf'}
  self.lavalink = false
  self.playerCheck = false
  self.usingInteraction = false
  self.sameVoiceCheck = false
  self.permissions = {}
  self.options = {}
end

function command:run(client, handler)
  handler:defer_reply()
  local input_prefix = handler.args[1]

  if not input_prefix then
    local embed = {
      description = client._i18n:get(handler.language, 'command.utils', 'prefix_arg'),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if string.len(input_prefix) > 10 then
    local embed = {
      description = client._i18n:get(handler.language, 'command.utils', 'prefix_length'),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = {embed} })
  end

  local new_prefix = client._db.prefix:get(handler.guild.id)

  if not new_prefix then
    client._db.prefix:set(handler.guild.id, input_prefix)
    local embed = {
      description = client._i18n:get(handler.language, 'command.utils', 'prefix_set', { input_prefix }),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = {embed} })
  else
    client._db.prefix:set(handler.guild.id, input_prefix)
    local embed = {
      description = client._i18n:get(handler.language, 'command.utils', 'prefix_change', { input_prefix }),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = {embed} })
  end
end

return command