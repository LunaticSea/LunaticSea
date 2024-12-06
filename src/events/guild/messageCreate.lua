local discordia = require('discordia')
local permission_flags_bits = discordia.enums.permission
local command_handler = require('../../structures/command_handler.lua')
local accessableby = require('../../constants/accessableby.lua')

local function special_prefix(prefix)
  local special = { '()', ')', '.', '%', '+', '-', '*', '?', '[', '^', '$' }
  local res_pattern = ''
  local res = {}

  for pre_character in string.gmatch(prefix, '.') do
    if table.includes(special, pre_character) then 
      res_pattern = res_pattern .. '%' .. pre_character
    end
    res_pattern = res_pattern .. pre_character
  end

  res.pattern = res_pattern
  res.original = prefix

  return res
end

return function(client, message)
	-- Check valid message class
	if message.author.bot then return end

	-- Get Command Data From Cache
	local guild_prefix = client._db.prefix:get(message.guild.id)
	local prefix = guild_prefix or client._config.utilities.PREFIX
	local special_prefix = special_prefix(prefix)
	prefix = special_prefix.original

	local is_match_prefix = string.match(message.content, special_prefix.pattern .. '[^.]+')
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
	local is_admin = table.includes(client._config.bot.ADMIN, message.author.id)
	local is_premium = client._db.premium:get(message.author.id)
	local is_guild_premium = client._db.premium:get(message.guild.id)
	local is_user_premium_access = table.includes(command.accessableby, accessableby.premium)
	local is_guild_premium_access = table.includes(command.accessableby, accessableby.guild_premium)
	local is_both_user_and_guild = is_user_premium_access and is_guild_premium_access

	local user_perm = {
		owner = is_owner,
		admin = is_admin or is_owner,
		premium = is_premium or is_admin or is_owner,
		guild_pre = is_guild_premium or is_premium or is_admin or is_owner
	}

	local ref = {
		message = message,
		mention = false,
	}

	if table.includes(command.accessableby, accessableby.owner) and not user_perm.owner then
	  local embed = {
      description = client._i18n:get(language, 'error', 'owner_only'),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
	  }
		return message:reply({ embeds = { embed }, reference = ref, })
	end

	if table.includes(command.accessableby, accessableby.admin) and not user_perm.admin then
		local embed = {
			description = client._i18n:get(language, 'error', 'user_no_perms', { 'dreamvast@admin' }),
			color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
		}
		return message:reply({ embeds = { embed }, reference = ref, })
	end

	function no_pre_embed(is_guild)
		local no_pre_string = client._i18n:get(language, 'error', 'no_premium_desc')
		if is_guild then
			no_pre_string = client._i18n:get(language, 'error', 'no_guild_premium_desc')
		end

		local res = {
		  author = {
				name = client._i18n:get(language, 'error', 'no_premium_author'),
				iconURL = interaction.usetr:getAvatarURL()
			},
			description = no_pre_string,
			color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
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

	-- Command runner
	local handler = require('../../structures/command_handler.lua'):new({
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
