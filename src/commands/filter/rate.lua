local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('Filter:Rate')

function get:name()
	return { 'rate' }
end

function get:description()
	return 'Sets the rate of the song.'
end

function get:category()
	return 'filter'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<number>'
end

function get:aliases()
	return {}
end

function get:config()
	return {
		lavalink = true,
		player_check = true,
		using_interaction = true,
		same_voice_check = true
	}
end

function get:permissions()
	return {}
end

function get:options()
	return {
    {
      name = 'amount',
      description = 'The amount of rate to set the song to.',
      type = applicationCommandOptionType.number,
      required = false,
    },
  }
end

function command:run(client, handler)
	handler:defer_reply()

  local player = client.lunalink.players:get(handler.guild.id)

  local value = tonumber(handler.args[1])

  if not value then
    local embed = {
      description = client.i18n:get(handler.language, 'error', 'number_invalid'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  if value > 10 then
    local embed = {
      description = client.i18n:get(handler.language, 'command.filter', 'filter_less'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  if value < 0 then
    local embed = {
      description = client.i18n:get(handler.language, 'command.filter', 'filter_greater'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  player.data:set('filter-mode', self.name[0])
  player.filter:setTimescale({ rate = value })

  local embed = {
    description = client.i18n:get(handler.language, 'command.filter', 'rate_on', { value }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command