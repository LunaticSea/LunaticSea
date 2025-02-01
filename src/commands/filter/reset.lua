local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Filter:Reset')

function get:name()
	return { 'reset' }
end

function get:description()
	return 'Reset filter'
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

  if not player.data:get('filter-mode') then
    local embed = {
      description = client.i18n:get(handler.language, 'command.filter', 'reset_already'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  player.data:delete('filter-mode')
  player.filter:clear()
  player:setVolume(client.config.player.DEFAULT_VOLUME)

  local embed = {
    description = client.i18n:get(handler.language, 'command.filter', 'reset_on'),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command