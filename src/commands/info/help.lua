local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('Info:Help')

function get:name()
	return { 'help' }
end

function get:description()
	return 'Displays all commands that the bot has.'
end

function get:category()
	return 'info'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<command_name_or_alias>'
end

function get:aliases()
	return { 'h' }
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
		name = 'command',
		description = 'The command name',
		type = applicationCommandOptionType.string,
		required = false,
	} }
end


function command:run(client, handler)
	self._client = client
	self._handler = handler

	handler:defer_reply()
	if #handler.args == 0 then
		return self:send_all_commands()
	end
	local arg = handler.args[1]
	local res_command = client.commands[client.alias[arg] or arg]

	if not res_command then
		local embed = {
			title = client.i18n:get(handler.language, 'command.info', 'ce_finder_invalid'),
			description = client.i18n:get(handler.language, 'command.info', 'ce_finder_example'),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		handler:edit_reply({
			embeds = { embed },
		})
		return
	end

	local e_string = self:translated_finder()
	local desc = self:generate_desc(e_string, res_command)

	local embed = {
		thumbnail = { url = self._client.user:getAvatarURL() or self._client.user:defaultAvatarURL() },
		description = desc,
		color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
	}

	handler:edit_reply({
		embeds = { embed },
	})
end

function command:generate_desc(e_string, res_command)
	local command_usage = e_string.usageNone
	local command_aliaes = e_string.aliasesNone
	local is_using_interaction = false

	if res_command.config._using_interaction then
		is_using_interaction = true
	end

	if res_command.usage and #res_command.usage ~= 0 then
		local connector = '-'
		if self._handler.interaction then
			connector = ' '
		end
		command_usage =
			self._handler.prefix .. table.concat(res_command.name, connector) .. ' ' .. res_command.usage
	end

	if res_command.aliases and #res_command.aliases ~= 0 then
		command_aliaes = table.concat(res_command.aliases, ', ') .. e_string.aliasesPrefix
	end

	local data_table =
		{
			e_string.name,
			table.concat(res_command.name, '-'),
			e_string.des,
			res_command.description or e_string.desNone,
			e_string.usage,
			command_usage,
			e_string.access,
			table.concat(res_command.accessableby, ', '),
			e_string.aliases,
			command_aliaes,
			e_string.slash,
			is_using_interaction,
		}

	return string.format([[
%s `%s`
%s `%s`
%s `%s`
%s `%s`
%s `%s`
%s `%s`]], table.unpack(data_table))
end

function command:send_all_commands()
	local field_embed = {}
	for category, _ in pairs(self._client._command_categories) do
		local same_category_command = command:table_filter(self._client.commands, function(data)
			return data.category == category
		end)

		local all_command_name = {}
		for _, command_data in pairs(same_category_command) do
			local command_name = table.concat(command_data.name, '-')
			if self._handler.interaction and command_data.usingInteraction then
				table.insert(all_command_name, command_name)
			elseif not self._handler.interaction then
				table.insert(all_command_name, command_name)
			end
		end

		local obj = {
			name = '❯  ' .. string.upper(category) .. ' [' .. #same_category_command .. ']',
			value = '`' .. table.concat(all_command_name, ', ') .. '`',
			inline = false,
		}

		table.insert(field_embed, obj)
	end

	local embed = {
		author = { name = self._client.i18n:get(self._handler.language, 'command.info', 'ce_name') },
		color = discordia.Color.fromHex(self._client.config.bot.EMBED_COLOR).value,
		thumbnail = { url = self._client.user:getAvatarURL() or self._client.user:defaultAvatarURL() },
		fields = field_embed,
		footer = {
			text = self._client.i18n:get(self._handler.language, 'command.info', 'ce_total') .. tostring(
				self._client._total_commands
			),
			url = self._client.user:getDefaultAvatarURL(),
		},
	}

	self._handler:edit_reply({
		embeds = { embed },
	})
end

function command:translated_finder()
	return {
		name = self._client.i18n:get(self._handler.language, 'command.info', 'ce_finder_name'),
		des = self._client.i18n:get(self._handler.language, 'command.info', 'ce_finder_des'),
		usage = self._client.i18n:get(self._handler.language, 'command.info', 'ce_finder_usage'),
		access = self._client.i18n:get(self._handler.language, 'command.info', 'ce_finder_access'),
		aliases = self._client.i18n:get(self._handler.language, 'command.info', 'ce_finder_aliases'),
		slash = self._client.i18n:get(self._handler.language, 'command.info', 'ce_finder_slash'),
		desNone = self._client.i18n:get(self._handler.language, 'command.info', 'ce_finder_des_no'),
		usageNone = self._client.i18n:get(self._handler.language, 'command.info', 'ce_finder_usage_no'),
		aliasesPrefix = self._client.i18n:get(
			self._handler.language,
			'command.info',
			'ce_finder_aliases_prefix'
		),
		aliasesNone = self._client.i18n:get(
			self._handler.language,
			'command.info',
			'ce_finder_aliases_no'
		),
		slashEnable = self._client.i18n:get(
			self._handler.language,
			'command.info',
			'ce_finder_slash_enable'
		),
		slashDisable = self._client.i18n:get(
			self._handler.language,
			'command.info',
			'ce_finder_slash_disable'
		),
	}
end

function command:table_filter(t, filterIter)
	local out = {}
	for k, v in pairs(t) do
		if filterIter(v, k, t) then
			table.insert(out, v)
		end
	end
	return out
end

return command
