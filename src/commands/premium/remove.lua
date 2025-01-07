local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('cm_premium_remove')

function get:name()
	return { 'pm', 'remove' }
end

function get:description()
	return 'Remove premium from members!'
end

function get:category()
	return 'premium'
end

function get:accessableby()
	return { accessableby.admin }
end

function get:usage()
	return '<id>'
end

function get:aliases()
	return {}
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
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      description = client.i18n:get(handler.language, 'command.premium', 'remove_no_params'),
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  local db = client.db.premium:get(id)

  if not db then
    local embed = {
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      description = client.i18n:get(handler.language, 'command.premium', 'remove_404', { id }),
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  client.db.premium:delete(id)
  local embed = {
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    description = client.i18n:get(handler.language, 'command.premium', 'remove_desc', {
      db.redeemedBy.username
    }),
  }
  return handler:edit_reply({
    embeds = { embed },
  })
end

return command
