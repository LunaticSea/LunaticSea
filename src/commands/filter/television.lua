local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Filter:Television')

function get:name()
	return { 'television' }
end

function get:description()
	return 'Turning on television filter (extended by rainy)'
end

function get:category()
	return 'filter'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return ''
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
	return {}
end

function command:run(client, handler)
	handler:defer_reply()

  local player = client.lunalink.players:get(handler.guild.id)

  if player.data:get('filter-mode') == self.name[0] then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.filter', 'filter_already', { self.name[0] }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  player.data:set('filter-mode', self.name[0])
  player.filter:setEqualizer({
    { band = 0, gain = 0 },
    { band = 1, gain = 0 },
    { band = 2, gain = 0 },
    { band = 3, gain = 0 },
    { band = 4, gain = 0 },
    { band = 5, gain = 0 },
    { band = 6, gain = 0 },
    { band = 7, gain = 0.65 },
    { band = 8, gain = 0.65 },
    { band = 9, gain = 0.65 },
    { band = 10, gain = 0.65 },
    { band = 11, gain = 0.65 },
    { band = 12, gain = 0.65 },
    { band = 13, gain = 0.65 },
  })

  local embed = {
    description = client.i18n:get(handler.language, 'command.filter', 'filter_on', { self.name[0] }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command
