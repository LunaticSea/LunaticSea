local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command = require('class')('cm_owner_blacklist')

function command:init()
	self.name = { 'blacklist' }
	self.description = 'Add user id to avoid them using bot!'
	self.category = 'owner'
	self.accessableby = { accessableby.owner }
	self.usage = '< id > < add / remmove > < user/ guild >'
	self.aliases = { 'bl' }
	self.lavalink = false
	self.playerCheck = false
	self.usingInteraction = true
	self.sameVoiceCheck = false
	self.permissions = {}
	self.options = {
    {
      name = 'id',
      description = 'Action for this user or guild',
      type = applicationCommandOptionType.string,
      required = true,
    },
    {
      name = 'action',
      description = 'Action for this user or guild',
      type = applicationCommandOptionType.string,
      required = true,
      choices = {
        {
          name = 'Add',
          value = 'add',
        },
        {
          name = 'Remove',
          value = 'remove',
        },
      },
    },
    {
      name = 'type',
      description = 'User or Guild',
      type = applicationCommandOptionType.string,
      required = true,
      choices = {
        {
          name = 'User',
          value = 'user',
        },
        {
          name = 'Guild',
          value = 'guild',
        },
      },
    },
  }
end

function command:run(client, handler)
	handler:defer_reply()
  local id = handler.args[1]
  local mode = handler.args[2]
  local type = handler.args[3]

  local valid_input = table.filter(self.options[2].choices, function (e)
    return e.value == mode
  end)

  if #valid_input == 0 then
    local embed = {
      description = client._i18n:get(handler.language, 'command.admin', 'bl_invalid_mode'),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  local valid_type = table.filter(self.options[3].choices, function (e)
    return e.value == type
  end)

  if #valid_type == 0 then
    local embed = {
      description = client._i18n:get(handler.language, 'command.admin', 'bl_invalid_type'),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  local key_data = string.format('%s_%s', type, id)
  if mode == 'remove' then return self:remove_data(client, handler, key_data, id) end

  client._db.blacklist:set(key_data, true)
  local embed = {
		description = client._i18n:get(handler.language, 'command.admin', 'bl_add', { id }),
		color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
	}
	handler:edit_reply({
		embeds = { embed },
	})
end

function command:remove_data(client, handler, key_data, id)
  client._db.blacklist:delete(key_data)

  local embed = {
		description = client._i18n:get(handler.language, 'command.admin', 'bl_remove', { id }),
		color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
	}
	handler:edit_reply({
		embeds = { embed },
	})
end

return command