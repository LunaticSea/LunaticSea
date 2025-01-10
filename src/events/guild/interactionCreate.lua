local discordia = require('discordia')
local permission_flags_bits = discordia.enums.permission
local command_handler = require('../../structures/command_handler.lua')
local accessableby = require('../../constants/accessableby.lua')
local arb = require('internal').auto_reconnect_builder

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

local function convert_option(data)
	if data.type == 6 then
		return string.format('<@%s>', data.value)
	end
	if data.type == 8 then
		return string.format('<@&%s>', data.value)
	end
	if data.type == 7 then
		return string.format('<#%s>', data.value)
	end
	return data.value
end


return function(client, interaction)
	-- Check valid interaction class
	if interaction.user.bot then return end
	if interaction.data.type ~= 1 then return end

	-- Get command data from cache
	local command_name = table.concat(get_command_name(interaction.data), '-')
	local command = client.commands[command_name]
	if not command then return end

	-- Get languages
	local language = client.db.language:get(interaction.guild.id)
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
	local is_premium = client.db.premium:get(interaction.user.id)
	local is_guild_premium = client.db.premium:get(interaction.guild.id)
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

	-- Ability checker
	if command.lavalink and #client._lavalink_using == 0 then
		local embed =  {
			description = client.i18n:get(language, 'error', 'no_node'),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return interaction:reply({ embeds = { embed } })
	end

	if command.player_check then
		local player = client.rainlink.players.get(interaction.guild.id)
		local twentyFourBuilder = arb(client)
		local is247 = twentyFourBuilder:get(interaction.guild.id)
		if (
			not player and
			(is247 and is247.twentyfourseven and player.queue.size == 0 and not player.queue.current)
		) then
			local embed = {
				description = client.i18n:get(language, 'error', 'no_player'),
				color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
			}
			return interaction:reply({ embeds = { embed } })
		end
	end

	if command.sameVoiceCheck then
		local channel = interaction.member.voiceChannel
		local bot_voice_id = interaction.guild.me.voiceChannel.id
		local user_voice_id = channel.id
		local embed = {
			description = client.i18n:get(language, 'error', 'no_voice'),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		if channel or (bot_voice_id ~= user_voice_id) then
			return interaction:reply({ embeds = { embed } })
		end
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

	local _, err = pcall(command.run, command, client, handler)

	if err then
		local embed = {
			title = string.format('Error on running %s command', command.__name),
			description = err,
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		interaction:reply({ embeds = { embed } })
		return client.logd:error('CommandManager | Interaction', err)
	end

	-- Log
	client.logd:info(
		'CommandManager | Interaction',
		string.format(
			'{ %s } used by %s from %s (%s)',
			command.__name,
			interaction.user.username,
			interaction.guild.name or nil,
			interaction.guild.id or nil
		)
	)
end
