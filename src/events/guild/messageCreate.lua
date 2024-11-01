return function (client, message)
	local prefix = client._config.utilities.PREFIX
	local is_match_prefix = string.match(message.content, prefix ..'[^.]+')
	if (not is_match_prefix) then return end

	local command_req = string.sub(message.content, #prefix + 1)
	local command_req_alias = client._c_alias[command_req]
	local command_name = command_req_alias or command_req

	local command = client._commands[command_name]
	local command_via_alias = client._commands[command_name]

	client._logd:info('CommandManager | Message', string.format(
		"%s used by %s from %s (%s)",
		command_name,
		message.author.username,
		message.guild.name or nil,
		message.guild.id or nil
	))

	if command then return command.execute(client, message) end
	if command_via_alias then return command_via_alias.execute(client, message) end
end