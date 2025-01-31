local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Music:Loop')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType

function get:name()
	return { 'loop' }
end

function get:description()
	return 'Loop song in queue type all/current!'
end

function get:category()
	return 'music'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<mode>'
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
      name = 'type',
      description = 'Type of loop',
      required = true,
      type = applicationCommandOptionType.string,
      choices = {
        {
          name = 'Song',
          value = 'song',
        },
        {
          name = 'Queue',
          value = 'queue',
        },
        {
          name = 'None',
          value = 'none',
        },
      },
    },
	}
end

function command:run(client, handler)
	handler:defer_reply()

  local avaliable_modes = { 'song', 'queue', 'none' }

  local player = client.lunalink.players:get(handler.guild.id)

  local mode = handler.args[1]

  if not table.includes(avaliable_modes, mode) then
    local bolded = table.map(avaliable_modes, function (v)
      return '**' .. v ..'**'
    end)
    local embed = {
      description = client.i18n:get(handler.language, 'command.music', 'loop_invalid', {
        table.concat(bolded, ', ')
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  if mode == player.loop then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'loop_already', { mode }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  local mode_map = {
    ['song'] = 'loop_current',
    ['queue'] = 'loop_all',
    ['none'] = 'unloop_all',
  }

  local get_mode_map = mode_map[mode]

  if client.config.utilities.AUTO_RESUME then
    self:setLoop247(client, player, mode)
  end

  local embed = {
    description = client.i18n:get(handler.language, 'command.music', get_mode_map),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  return handler:edit_reply({ content = ' ', embeds = { embed } })
end

function command:setLoop247(client, player, loop)
  local curr_data = client.db.autoreconnect:get(player.guildId)
  if curr_data then
    curr_data.config.loop = loop
    client.db.autoreconnect:set(player.guildId, curr_data)
  end
end

return command
