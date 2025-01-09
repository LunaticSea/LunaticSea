local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Utils:Prefix')

function get:name()
	return { 'prefix' }
end

function get:description()
	return 'Change the prefix for the bot'
end

function get:category()
	return 'utils'
end

function get:accessableby()
	return { accessableby.manager }
end

function get:usage()
	return '<input>'
end

function get:aliases()
	return { 'setprefix', 'pf' }
end

function get:config()
	return {
		lavalink = false,
		player_check = false,
		using_interaction = false,
		same_voice_check = false
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
	local input_prefix = handler.args[1]

	if not input_prefix then
		local embed = {
			description = client.i18n:get(handler.language, 'command.utils', 'prefix_arg'),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	end

	if string.len(input_prefix) > 10 then
		local embed = {
			description = client.i18n:get(handler.language, 'command.utils', 'prefix_length'),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	end

	local new_prefix = client.db.prefix:get(handler.guild.id)

	if not new_prefix then
		client.db.prefix:set(handler.guild.id, input_prefix)
		local embed = {
			description = client.i18n:get(handler.language, 'command.utils', 'prefix_set', {
				input_prefix,
			}),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	else
		client.db.prefix:set(handler.guild.id, input_prefix)
		local embed = {
			description = client.i18n:get(handler.language, 'command.utils', 'prefix_change', {
				input_prefix,
			}),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	end
end

return command
