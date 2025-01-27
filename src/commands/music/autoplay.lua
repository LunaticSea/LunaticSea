local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Music:Autoplay')

function get:name()
	return { 'autoplay' }
end

function get:description()
	return 'Autoplay music (Random play songs)'
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

  if player.data:get('autoplay') == true then
    player.data:set('autoplay', false)
    player.data:delete('requester')
    player.data:delete('author')
    player.queue:clear()

    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'autoplay_off', {
        handler.mode_lang.disable
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }

    handler:edit_reply({ content = ' ', embeds = { embed } })
  else
    player.data:set('autoplay', true)
    player.data:set('requester', handler.user)
    player.data:set('author', player.queue.current.author)

    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'autoplay_on', {
        handler.mode_lang.enable
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }

    handler:edit_reply({ content = ' ', embeds = { embed } })
  end
end

return command
