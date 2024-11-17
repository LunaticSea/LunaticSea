local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command = require('class'):create()

function command:init()
	self.name = { 'language' }
	self.description = 'Change the language for the bot'
	self.category = 'utils'
	self.accessableby = { accessableby.manager }
	self.usage = '<language>'
	self.aliases = { 'lang' }
	self.lavalink = false
	self.playerCheck = false
	self.usingInteraction = true
	self.sameVoiceCheck = false
	self.permissions = {}
	self.options = { {
		name = 'input',
		description = 'The new language',
		type = applicationCommandOptionType.string,
		required = true,
	} }
end

function command:run(client, handler)
	handler:defer_reply()
	local input_lang = handler.args[1]
	local languages = client._i18n:get_locates()

	local match_lang = table.filter(languages, function(value, key)
		if value == input_lang then
			return true
		end
	end)[1]

	if not match_lang then
		local embed = {
			description = client._i18n:get(handler.language, 'command.utils', 'provide_lang', {
				table.concat(languages, ', '),
			}),
			color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	end

	local new_lang = client._db.language:get(handler.guild.id)

	if not new_lang then
		client._db.language:set(handler.guild.id, match_lang)
		local embed = {
			description = client._i18n:get(handler.language, 'command.utils', 'lang_set', { match_lang }),
			color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	else
		client._db.language:set(handler.guild.id, match_lang)
		local embed = {
			description = client._i18n:get(handler.language, 'command.utils', 'lang_change', {
				match_lang,
			}),
			color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	end
end

return command
