local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('cm_owner_blacklist')

function get:name()
	return { 'blacklist' }
end

function get:description()
	return 'Add user id to avoid them using bot!'
end

function get:category()
	return 'owner'
end

function get:accessableby()
	return { accessableby.admin }
end

function get:usage()
	return '< id > < add / remmove > < user/ guild >'
end

function get:aliases()
	return { 'bl' }
end

function get:config()
	return {
		lavalink = false,
		player_check = false,
		using_interaction = true,
		same_voice_check = false
	}
end

function get:permissions()
	return {}
end

function get:options()
	return {
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
      description = client.i18n:get(handler.language, 'command.admin', 'bl_invalid_mode'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
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
      description = client.i18n:get(handler.language, 'command.admin', 'bl_invalid_type'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  local key_data = string.format('%s_%s', type, id)
  if mode == 'remove' then return self:remove_data(client, handler, key_data, id) end

  client.db.blacklist:set(key_data, true)
  local embed = {
		description = client.i18n:get(handler.language, 'command.admin', 'bl_add', { id }),
		color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
	}
	handler:edit_reply({
		embeds = { embed },
	})
end

function command:remove_data(client, handler, key_data, id)
  client.db.blacklist:delete(key_data)

  local embed = {
		description = client.i18n:get(handler.language, 'command.admin', 'bl_remove', { id }),
		color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
	}
	handler:edit_reply({
		embeds = { embed },
	})
end

return command