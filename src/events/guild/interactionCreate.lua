local discordia = require('discordia')
local permission_flags_bits = discordia.enums.permission
local command_handler = require('../../structures/command_handler.lua')
local accessableby = require('../../constants/accessableby.lua')
local convert_option = require('../../utils/convert_option')

local function get_command_name(data, subm)
	local res = {}

	if not subm and data.name and (data.type == 1 or data.type == 2) then
		table.insert(res, data.name)
	end

	if not data.options or #data.options == 0 then
		return res
	end

	for _, value in pairs(data.options) do
		if value.type == 2 or value.type == 1 then
			table.insert(res, value.name)
		end

		if value.options and #value.options ~= 0 then
			local pre_res = get_command_name(value, true)
			for _, n_value in pairs(pre_res) do
				table.insert(res, n_value)
			end
		end
	end

	return res
end

return function(client, interaction)
	-- Check valid interaction class
	if interaction.user.bot then return end
	if interaction.data.type ~= 1 then return end

	-- Get command data from cache
	local command_name = table.concat(get_command_name(interaction.data), '-')
	local command = client._commands[command_name]
	if not command then return end

	-- Get languages
	local language = client._db.language:get(interaction.guild.id)
	if not language then language = client._i18n.default_locate end

	-- Permission Checker
	if (table.includes(
		command.accessableby,
		accessableby.manager
	) and not interaction.member:hasPermission(permission_flags_bits.manageGuild)) then
		interaction:reply({
			embeds = { {
				description = client._i18n:get(language, 'error', 'owner_only'),
				color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
			} },
		})
		return
	end

	-- Accessable Checker
	local is_owner = interaction.user.id == client._bot_owner
	local user_perm = { owner = is_owner }

	if table.includes(command.accessableby, accessableby.owner) and not user_perm.owner then
		interaction:reply({
			embeds = { {
				description = client._i18n:get(language, 'error', 'owner_only'),
				color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
			} }
		})
		return
	end

	-- Convert args
	local args = {}
	local function arg_convert(data, bypass)
		if not bypass and (not data.options or #data.options == 0) then return end

		if data.type == 1 or data.type == 2 then
			for _, sub_data in pairs(data.options) do
				arg_convert(sub_data, true)
			end
		end

		local converted = convert_option({
			type = data.type,
			value = data.value,
		})
		table.insert(args, converted)
	end
	arg_convert(interaction.data)

	-- Command runner
	local handler = command_handler:new({
		interaction = interaction,
		language = client._i18n.default_locate,
		client = client,
		args = args,
		prefix = '/',
	})

	command:run(client, handler)

	-- Log
	client._logd:info(
		'CommandManager | Interaction',
		string.format(
			'%s used by %s from %s (%s)',
			command_name,
			interaction.user.username,
			interaction.guild.name or nil,
			interaction.guild.id or nil
		)
	)
end
