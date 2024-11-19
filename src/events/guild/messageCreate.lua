local discordia = require('discordia')
local permission_flags_bits = discordia.enums.permission
local command_handler = require('../../structures/command_handler.lua')
local accessableby = require('../../constants/accessableby.lua')

return function(client, message)
	-- Check valid message class
	if message.author.bot then return end

	-- Get Command Data From Cache
	local guild_prefix = client._db.prefix:get(message.guild.id)
	local prefix = guild_prefix or client._config.utilities.PREFIX

	local is_match_prefix = string.match(message.content, prefix .. '[^.]+')
	if not is_match_prefix then return end

	local content_without_prefix = string.sub(message.content, #prefix + 1)
	local args = string.split(content_without_prefix, '%S+')
	local command_req = args[1]
	table.remove(args, 1)

	local command_req_alias = client._c_alias[command_req]
	local command_name = command_req_alias or command_req

	local command = client._commands[command_name]
	if not command then return end

	-- Get languages
	local language = client._db.language:get(message.guild.id)
	if not language then language = client._i18n.default_locate end

	-- Permission Checker
	if (table.includes(
		command.accessableby,
		accessableby.manager
	) and not message.member:hasPermission(permission_flags_bits.manageGuild)) then
		message:reply({
			embeds = { {
				description = client._i18n:get(language, 'error', 'owner_only'),
				color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
			} },
			reference = {
				message = message,
				mention = false,
			},
		})
		return
	end

	-- Accessable Checker
	local is_owner = message.author.id == client._bot_owner
	local user_perm = { owner = is_owner }

	if table.includes(command.accessableby, accessableby.owner) and not user_perm.owner then
		message:reply({
			embeds = { {
				description = client._i18n:get(language, 'error', 'owner_only'),
				color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
			} },
			reference = {
				message = message,
				mention = false,
			},
		})
		return
	end

	-- Command runner
	local handler = command_handler:new({
		message = message,
		language = language,
		client = client,
		args = args,
		prefix = prefix or 'd!',
	})

	command:run(client, handler)

	-- Log
	client._logd:info(
		'CommandManager | Message',
		string.format(
			'%s used by %s from %s (%s)',
			command_name,
			message.author.username,
			message.guild.name or nil,
			message.guild.id or nil
		)
	)
end
