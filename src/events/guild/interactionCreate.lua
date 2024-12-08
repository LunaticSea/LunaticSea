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
	local language = client.database.language:get(interaction.guild.id)
	if not language then language = client.i18n.default_locate end

	-- Permission Checker
	if (table.includes(
		command.accessableby,
		accessableby.manager
	) and not interaction.member:hasPermission(permission_flags_bits.manageGuild)) then
		interaction:reply({
			embeds = { {
				description = client.i18n:get(language, 'error', 'owner_only'),
				color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
			} },
		})
		return
	end

	-- Accessable Checker
	local is_owner = interaction.user.id == client.bot_owner
	local is_admin = table.includes(client.config.bot.ADMIN, interaction.user.id)
	local is_premium = client.database.premium:get(interaction.user.id)
	local is_guild_premium = client.database.premium:get(interaction.guild.id)
	local is_user_premium_access = table.includes(command.accessableby, accessableby.premium)
	local is_guild_premium_access = table.includes(command.accessableby, accessableby.guild_premium)
	local is_both_user_and_guild = is_user_premium_access and is_guild_premium_access

	local user_perm = {
		owner = is_owner,
		admin = is_admin or is_owner,
		premium = is_premium or is_admin or is_owner,
		guild_pre = is_guild_premium or is_premium or is_admin or is_owner
	}

	if table.includes(command.accessableby, accessableby.owner) and not user_perm.owner then
		local embed = {
			description = client.i18n:get(language, 'error', 'owner_only'),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return interaction:reply({ embeds = { embed } })
	end

	if table.includes(command.accessableby, accessableby.admin) and not user_perm.admin then
		local embed = {
			description = client.i18n:get(language, 'error', 'user_no_perms', { 'dreamvast@admin' }),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return interaction:reply({ embeds = { embed } })
	end

	local function no_pre_embed(is_guild)
		local no_pre_string = client.i18n:get(language, 'error', 'no_premium_desc')
		if is_guild then
			no_pre_string = client.i18n:get(language, 'error', 'no_guild_premium_desc')
		end

		local res = {
		  author = {
				name = client.i18n:get(language, 'error', 'no_premium_author'),
				iconURL = interaction.usetr:getAvatarURL()
			},
			description = no_pre_string,
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
			timestamp = discordia.Date():toISO('T', 'Z'),
		}

		return res
	end

	if not is_both_user_and_guild and is_user_premium_access and not user_perm.premium then
		return interaction:reply({ embeds = { no_pre_embed() } })
	end

	if not is_both_user_and_guild and is_guild_premium_access and not user_perm.guild_pre then
		return interaction:reply({ embeds = { no_pre_embed(true) } })
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
	local handler = command_handler({
		interaction = interaction,
		language = client.i18n.default_locate,
		client = client,
		args = args,
		prefix = '/',
	})

	command:run(client, handler)

	-- Log
	client.logd:info(
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
