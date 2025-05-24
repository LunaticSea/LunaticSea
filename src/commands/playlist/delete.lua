local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('Playlist:Delete')
local json = require('json')

function get:name()
	return { 'pl', 'delete' }
end

function get:description()
	return 'Delete a playlist'
end

function get:category()
	return 'playlist'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<playlist_id>'
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
      description = 'The id of the playlist',
      required = true,
      type = applicationCommandOptionType.string,
    }
  }
end

function command:run(client, handler)
  handler:defer_reply()

  local value = handler.args[1]

  if not value then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'invalid'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  local playlist = client.db.playlist:get(value)

  if not playlist then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'delete_notfound'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if playlist.owner ~= handler.user.id then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'delete_owner'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  local action = discordia.Components({
    {
      id = "yes",
      type = 2,
      style = 2,
      emoji = '✅',
    },
    {
      id = "no",
      type = 2,
      style = 2,
      emoji = '❌',
    },
  })

  local embed = {
    description = client.i18n:get(handler.language, 'command.playlist', 'delete_confirm', { value }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  local msg = handler:edit_reply({
    embeds = { embed },
    components = { action }
  })

  local collector = msg:createCollector('button', 20000, function (m)
    return m.user.id == handler.user.id
  end)

  collector:on('collect', function (interaction)
    local id = interaction.data.custom_id
    if id == "yes" then
      client.db.playlist:delete(value)
      local res_embed = {
        description = client.i18n:get(handler.language, 'command.playlist', 'delete_deleted', { value }),
        color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      }
      interaction:reply({ embeds = { res_embed } })
      collector:stop(true)
    elseif id == "no" then
      local res_embed = {
        description = client.i18n:get(handler.language, 'command.playlist', 'delete_no'),
        color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      }
      interaction:reply({ embeds = { res_embed } })
      collector:stop(true)
    end
  end)

  collector:on('end', function (deleted)
    if deleted then return end
    local res_embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'delete_no'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    handler:edit_reply({ embeds = { res_embed }, components = {} })
  end)

end

return command