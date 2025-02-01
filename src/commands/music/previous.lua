local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Music:Previous')

function get:name()
	return { 'previous' }
end

function get:description()
	return 'Play the previous song in the queue.'
end

function get:category()
	return 'music'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return ''
end

function get:aliases()
	return { 'pre' }
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

  local previousIndex = #player.queue.previous

  if (
    #player.queue.previous == 0 or
    player.queue.previous[1].uri == player.queue.current.uri or
    previousIndex < 0
  ) then
    local embed = {
      description = client.i18n:get(handler.language, 'command.music', 'previous_notfound'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  player:previous()

  player.data:set('endMode', 'previous')

  local embed = {
    description = client.i18n:get(handler.language, 'command.music', 'previous_msg'),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command