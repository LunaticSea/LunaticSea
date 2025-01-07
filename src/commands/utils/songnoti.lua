local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('cm_utils_songnoti')

function get:name()
	return { 'songnoti' }
end

function get:description()
	return 'Enable or disable the player control notifications'
end

function get:category()
	return 'utils'
end

function get:accessableby()
	return { accessableby.manager }
end

function get:usage()
	return '<enable> or <disable>'
end

function get:aliases()
	return { 'song-noti', 'snt', 'sn' }
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
	return { {
		name = 'type',
		description = 'Choose enable or disable',
		type = applicationCommandOptionType.string,
		required = true,
    choices = {
      {
        name = 'Enable',
        value = 'enable',
      },
      {
        name = 'Disable',
        value = 'disable',
      },
    }
	} }
end


function command:run(client, handler)
	handler:defer_reply()
	local input_songnoti = handler.args[1]
  local original_value = client.db.songNoti:get(handler.guild.id)
  local is_satisfy = input_songnoti == 'enable' or input_songnoti == 'disable'

  if not input_songnoti or not is_satisfy then
    local embed = {
			description = client.i18n:get(handler.language, 'error', 'arg_error', { '**enable** or **disable**!' }),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
  end

  if original_value == input_songnoti then
    local mode = handler.modeLang.enable
    if original_value == 'disable' then mode = handler.modeLang.disable end
    local embed = {
			description = client.i18n:get(handler.language, 'command.utils', 'songnoti_already', { mode }),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
  end

  local mode = handler.modeLang.enable
  if input_songnoti == 'disable' then mode = handler.modeLang.disable end

  client.db.songNoti:set(handler.guild.id, input_songnoti)
  local embed = {
    description = client.i18n:get(handler.language, 'command.utils', 'songnoti_set', { mode }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }
  return handler:edit_reply({
    embeds = { embed },
  })
end

return command