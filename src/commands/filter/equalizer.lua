local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('Filter:Equalizer')

function get:name()
	return { 'equalizer' }
end

function get:description()
	return 'Custom Equalizer!'
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
      name = 'bands',
      description = 'Number of bands to use (max 14 bands.)',
      type = applicationCommandOptionType.string,
      required = false,
    },
  }
end

function command:run(client, handler)
	handler:defer_reply()

  local player = client.lunalink.players:get(handler.guild.id)

  local value = handler.args[1]

  if value and type(value) ~= "number" then
    local embed = {
      description = client.i18n:get(handler.language, 'error', 'number_invalid'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  if not value then return self:no_value_run(client, handler) end

  if value == 'off' or value == 'reset' then
    player.filter:clear()
    local embed = {
      description = client.i18n:get(handler.language, 'command.filter', 'eq_on', { 'reset' }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ content = ' ', embeds = { embed } })
  end

  -- Assume 'value' is the input string
  local bands = {}
  for band in string.gmatch(value, "%S+") do
    table.insert(bands, band)
  end

  local bandsStr = ""
  local maxBands = 13

  for i = 1, math.min(#bands, maxBands + 1) do
    local bandVal = tonumber(bands[i])
    if not bandVal then
      local embed = {
        description = client.i18n:get(handler.language, "command.filter", "eq_number"),
        color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      }
      return handler:edit_reply({ content = ' ', embeds = { embed } })
    end

    if bandVal > 10 then
      local embed = {
        description = client.i18n:get(handler.language, "command.filter", "eq_than"),
        color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      }
      return handler:edit_reply({ content = ' ', embeds = { embed } })
    end

    if bandVal < -10 then
      local embed = {
        description = client.i18n:get(handler.language, "command.filter", "eq_greater"),
        color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      }
      return handler:edit_reply({ content = ' ', embeds = { embed } })
    end
  end

  -- Apply equalizer and build response string
  for i = 1, math.min(#bands, maxBands + 1) do
    local gain = tonumber(bands[i]) / 10
    player.filter:setEqualizer({ { band = i - 1, gain = gain } }) -- Lua is 1-based, adjust index
    bandsStr = bandsStr .. bands[i] .. " "
  end

  player.data:set("filter-mode", self.name[1])

  local embed = {
    description = client.i18n:get(handler.language, "command.filter", "eq_on", {
      bands = bandsStr
    }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  return handler:editReply({ content = " ", embeds = { embed } })
end

function command:no_value_run(client, handler)
  local embed = {
    author = {
      name = client.i18n:get(handler.language, 'command.filter', 'eq_author'),
      icon_url = client.i18n:get(handler.language, 'command.filter', 'eq_icon'),
    },
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    description = client.i18n:get(handler.language, 'command.filter', 'eq_desc'),
    fields = {
      {
        name = client.i18n.get(handler.language, 'command.filter', 'eq_field_title'),
        value = client.i18n.get(handler.language, 'command.filter', 'eq_field_value', { handler.prefix })
      }
    },
    footer = {
      text = client.i18n.get(handler.language, 'command.filter', 'eq_footer', { handler.prefix })
    }
  }

  return handler:edit_reply({ content = ' ', embeds = { embed } })
end

return command