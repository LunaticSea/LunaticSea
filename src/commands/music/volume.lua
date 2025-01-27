local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('Music:Volume')

function get:name()
	return { 'volume' }
end

function get:description()
	return 'Adjusts the volume of the bot.'
end

function get:category()
	return 'music'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<number>'
end

function get:aliases()
	return { 'vol' }
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
      description = 'The amount of volume to set the bot to.',
      type = applicationCommandOptionType.number,
      required = true,
    },
  }
end

function command:run(client, handler)
	handler:defer_reply()

  local player = client.lunalink.players:get(handler.guild.id)

  local value = tonumber(handler.args[1])

  if not value then
    local embed =  {
      description = client.i18n:get(handler.language, 'error', 'number_invalid'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  if value <= 0 or value > 100 then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'volume_invalid'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  player:setVolume(value)

  local embed =  {
    description = client.i18n:get(handler.language, 'command.music', 'volume_msg', { value }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command
