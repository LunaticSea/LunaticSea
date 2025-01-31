local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('Filter:Bassboost')

function get:name()
	return { 'bassboost' }
end

function get:description()
	return 'Turning on bassboost filter (extended by rainy)'
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
      description = 'The amount of the bassboost',
      type = applicationCommandOptionType.number,
      required = false,
    },
  }
end

function command:run(client, handler)
	handler:defer_reply()

  local player = client.lunalink.players:get(handler.guild.id)

  local value = handler.args[1]

  if not value then
    player.filter:set('bass')
    local embed = {
      description = client.i18n:get(handler.language, 'command.filter', 'filter_on', { 'bassboost' } ),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  value = tonumber(value)

  if not value then
    local embed = {
      description = client.i18n:get(handler.language, 'command.filter', 'filter_number'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  if value > 10 or value < -10 then
    local embed = {
      description = client.i18n:get(handler.language, 'command.filter', 'bassboost_limit'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  player.data:set('filter-mode', self.name[0])
  player.filter:setEqualizer({
    { band = 0, gain = value / 10 },
    { band = 1, gain = value / 10 },
    { band = 2, gain = value / 10 },
    { band = 3, gain = value / 10 },
    { band = 4, gain = value / 10 },
    { band = 5, gain = value / 10 },
    { band = 6, gain = value / 10 },
    { band = 7, gain = 0 },
    { band = 8, gain = 0 },
    { band = 9, gain = 0 },
    { band = 10, gain = 0 },
    { band = 11, gain = 0 },
    { band = 12, gain = 0 },
    { band = 13, gain = 0 },
  })

  local embed = {
    description = client.i18n:get(handler.language, 'command.filter', 'bassboost_set', { value }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command
