return function (client, message)
	local prefix = client._config.utilities.PREFIX
	local is_match_prefix = string.match(message.content, prefix ..'[^.]+')
	if (not is_match_prefix) then return end
	local command_req = string.sub(message.content, #prefix + 1)
	local command = client._commands[command_req]
	if (not command) then return end
	command.execute(client, message)
end