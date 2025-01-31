local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local FilterData = require('lunalink').constants.FilterData
local command, get = require('class')('Filter:Filter')

function get:name()
	return { 'filter' }
end

function get:description()
	return 'Turning on some built-in filter'
end

function get:category()
	return 'filter'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<filter_name>'
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
      name = 'name',
      description = 'The name of filter',
      type = applicationCommandOptionType.string,
      required = false,
    },
  }
end

function command:run(client, handler)
	handler:defer_reply()

  local filterList = {}

  for key, _ in pairs(FilterData) do
    if key ~= 'clear' then table.insert(filterList, key) end
  end

  local filterName = handler.args[1]

  local player = client.lunalink.players:get(handler.guild.id)

  local isFoundFilter = table.filter(filterList, function (e)
    return e == filterName
  end)

  if not filterName or #isFoundFilter == 0 then
    local embed = {
      description = client.i18n:get(handler.language, 'command.filter', 'filter_avaliable', {
        #filterList, table.concat(filterList, ', ')
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }

    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  if not player.data:get('filter-mode') then
    local embed = {
      description = client.i18n:get(handler.language, 'command.filter', 'reset_already'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  if player.data:get('filter-mode') == filterName then
    local embed = {
      description = client.i18n:get(handler.language, 'command.filter', 'filter_already', { filterName }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  player.data:set('filter-mode', filterName)
  player.filter:set(filterName)

  local embed = {
    description = client.i18n:get(handler.language, 'command.filter', 'filter_on', { filterName }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command
