local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('cm_utils_language')

function get:name()
	return { 'language' }
end

function get:description()
	return 'Change the language for the bot'
end

function get:category()
	return 'utils'
end

function get:accessableby()
	return { accessableby.manager }
end

function get:usage()
	return '<language>'
end

function get:aliases()
	return { 'lang' }
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
		name = 'input',
		description = 'The new language',
		type = applicationCommandOptionType.string,
		required = true,
	} }
end

function command:run(client, handler)
	handler:defer_reply()
	local input_lang = handler.args[1]
	local languages = client.i18n:get_locates()

	local match_lang = table.filter(languages, function(value, key)
		if value == input_lang then
			return true
		end
	end)[1]

	if not match_lang then
		local embed = {
			description = client.i18n:get(handler.language, 'command.utils', 'provide_lang', {
				table.concat(languages, ', '),
			}),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	end

	local new_lang = client.db.language:get(handler.guild.id)

	if not new_lang then
		client.db.language:set(handler.guild.id, match_lang)
		local embed = {
			description = client.i18n:get(handler.language, 'command.utils', 'lang_set', { match_lang }),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	else
		client.db.language:set(handler.guild.id, match_lang)
		local embed = {
			description = client.i18n:get(handler.language, 'command.utils', 'lang_change', {
				match_lang,
			}),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	end
end

return command
