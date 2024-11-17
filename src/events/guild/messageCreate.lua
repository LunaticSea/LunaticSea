local discordia = require('discordia')
local permission_flags_bits = discordia.enums.permission
local command_handler = require('../../structures/command_handler')
local split = require('../../utils/split')
local accessableby = require('../../constants/accessableby.lua')

table.includes = function(t, e)
	for _, value in pairs(t) do
		if value == e then
			return e
		end
	end
	return nil
end

return function(client, message)
	-- Check valid message class
	if message.author.bot then return end

	-- Get Command Data From Cache
	local guild_prefix = client._db.prefix:get(message.guild.id)
	local prefix = guild_prefix or client._config.utilities.PREFIX

	local is_match_prefix = string.match(message.content, prefix .. '[^.]+')
	if not is_match_prefix then return end

	local content_without_prefix = string.sub(message.content, #prefix + 1)
	local args = split(content_without_prefix, '%S+')
	local command_req = args[1]
	table.remove(args, 1)

	local command_req_alias = client._c_alias[command_req]
	local command_name = command_req_alias or command_req

	local command = client._commands[command_name]
	if not command then return end

	-- Permission Checker
	if (table.includes(
		command.accessableby,
		accessableby.manager
	) and not message.member.hasPermission(permission_flags_bits.manageGuild)) then
		message:reply({
			embeds = { {
				description = client._i18n:get(client._i18n.default_locate, 'error', 'owner_only'),
				color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
			} },
		})
		return
	end

	-- Accessable Checker
	local is_owner = message.author.id == client._bot_owner
	local user_perm = { owner = is_owner }

	if table.includes(command.accessableby, accessableby.owner) and not user_perm.owner then
		message:reply({
			embeds = { {
				description = client._i18n:get(client._i18n.default_locate, 'error', 'owner_only'),
				color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
			} },
		})
		return
	end

	-- Command runner
	local handler = command_handler:new({
		message = message,
		language = client._i18n.default_locate,
		client = client,
		args = args,
		prefix = prefix or 'd!',
	})

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

	command:run(client, handler)
end
