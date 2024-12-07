local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command = require('class')('cm_premium_remove')

function command:init()
	self.name = { 'pm', 'remove' }
	self.description = 'Remove premium from members!'
	self.category = 'premium'
	self.accessableby = { accessableby.admin }
	self.usage = '<id>'
	self.aliases = {}
	self.lavalink = false
	self.playerCheck = false
	self.usingInteraction = true
	self.sameVoiceCheck = false
	self.permissions = {}
	self.options = {
    {
      name = 'id',
      description = 'The user id you want to remove!',
      type = applicationCommandOptionType.string,
      required = true,
    },
	}
end

function command:run(client, handler)
	handler:defer_reply()
	local id = handler.args[1]

  if not id then
    local embed = {
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
      description = client._i18n:get(handler.language, 'command.premium', 'remove_no_params'),
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  local db = client._db.premium:get(id)

  if not db then
    local embed = {
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
      description = client._i18n:get(handler.language, 'command.premium', 'remove_404', { id }),
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  client._db.premium:delete(id)
  local embed = {
    color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    description = client._i18n:get(handler.language, 'command.premium', 'remove_desc', {
      db.redeemedBy.username
    }),
  }
  return handler:edit_reply({
    embeds = { embed },
  })
end

return command
