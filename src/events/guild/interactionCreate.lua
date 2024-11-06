local convert_option = require('../../utils/convert_option')

local function get_command_name(data, subm)
  local res = {}

  if (not subm) and data.name and (data.type == 1 or data.type ==2) then
    table.insert(res, data.name)
  end

  if not data.options or #data.options == 0 then return res end

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


return function (client, interaction)
  if interaction.user.bot then return end
  if interaction.data.type ~= 1 then return end

  local command_name = table.concat(get_command_name(interaction.data), '-')
  local command = client._commands[command_name]
  if not command then return end

  local args = {}
  local function arg_convert(data)
    if not data.options or #data.options == 0 then return end

    if data.type == 1 or data.type == 2 then
      for _, sub_data in pairs(data.options) do
        arg_convert(sub_data)
      end
    end

    local check = convert_option({
      type = data.type,
      value = data.value
    })
    if check ~= 'error' then table.insert(args, check) end
  end
  arg_convert(interaction.data)

  client._logd:info('CommandManager | Interaction', string.format(
		"%s used by %s from %s (%s)",
		command_name,
		interaction.user.username,
		interaction.guild.name or nil,
		interaction.guild.id or nil
	))

  local handler = require('../../structures/command_handler'):new({
		interaction = interaction,
		language = client._i18n.default_locate,
		client = client,
		args = args,
		prefix = '/',
	})

  if command then return command:run(client, handler) end
end