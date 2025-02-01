local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Filter:Earrape')

function get:name()
	return { 'earrape' }
end

function get:description()
	return 'Turning on earrape filter (extended by rainy)'
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
    local embed = {
      description = client.i18n:get(handler.language, 'command.filter', 'filter_already', { self.name[0] }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  player.data:set('filter-mode', self.name[0])
  player.filter:setVolume(500)

  local embed = {
    description = client.i18n:get(handler.language, 'command.filter', 'filter_on', { self.name[0] }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command