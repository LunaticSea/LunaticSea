local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command = require('class')('cm_utils_songnoti')

function command:init()
	self.name = { 'songnoti' }
	self.description = 'Enable or disable the player control notifications'
	self.category = 'utils'
	self.accessableby = { accessableby.manager }
	self.usage = '<enable> or <disable>'
	self.aliases = { 'song-noti', 'snt', 'sn' }
	self.lavalink = false
	self.playerCheck = false
	self.usingInteraction = true
	self.sameVoiceCheck = false
	self.permissions = {}
	self.options = { {
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
  local original_value = client._db.songNoti:get(handler.guild.id)
  local is_satisfy = input_songnoti == 'enable' or input_songnoti == 'disable'

  if not input_songnoti or not is_satisfy then
    local embed = {
			description = client._i18n:get(handler.language, 'error', 'arg_error', { '**enable** or **disable**!' }),
			color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
  end

  if original_value == input_songnoti then
    local mode = handler.modeLang.enable
    if original_value == 'disable' then mode = handler.modeLang.disable end
    local embed = {
			description = client._i18n:get(handler.language, 'command.utils', 'songnoti_already', { mode }),
			color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
  end

  local mode = handler.modeLang.enable
  if input_songnoti == 'disable' then mode = handler.modeLang.disable end

  client._db.songNoti:set(handler.guild.id, input_songnoti)
  local embed = {
    description = client._i18n:get(handler.language, 'command.utils', 'songnoti_set', { mode }),
    color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
  }
  return handler:edit_reply({
    embeds = { embed },
  })
end

return command