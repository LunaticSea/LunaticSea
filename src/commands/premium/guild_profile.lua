local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Premium:GuildProfile')

function get:name()
	return { 'pm', 'guild', 'profile' }
end

function get:description()
	return 'View your guild premium profile!'
end

function get:category()
	return 'premium'
end

function get:accessableby()
	return { accessableby.guild_premium }
end

function get:usage()
	return ''
end

function get:aliases()
	return {}
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
	return {}
end

function command:run(client, handler)
	handler:defer_reply()

	local premium_plan = client.db.preGuild:get(handler.guild.id)

	if not premium_plan then
    local embed = self:embed_gen(client, handler, {}, true)
    return handler:edit_reply({ embeds = { embed } })
	end

  local formated_time = string.format('<t:%s:F>', premium_plan.expiresAt)
  if premium_plan.expiresAt == 15052008 then formated_time = 'lifetime' end
	
	local embed_args = { handler.guild.name, premium_plan.plan, formated_time }
  local embed = self:embed_gen(client, handler, embed_args)

  return handler:edit_reply({ embeds = { embed } })
end

function command:embed_gen(client, handler, desc_args, is_err)
  local default_desc_str = { handler.language,  'command.premium', 'guild_profile_desc', desc_args }
  local default_title_str = { handler.language, 'command.premium', 'guild_profile_author' }

  if is_err then
    default_desc_str = { handler.language, 'error', 'no_premium_author' }
    default_title_str = { handler.language, 'error', 'no_guild_premium_desc' }
  end

  return {
    author = {
      name = client.i18n:get(table.unpack(default_desc_str)),
      iconURL = client.user:getAvatarURL()
    },
		description = client.i18n:get(table.unpack(default_desc_str)),
		color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		timestamp = discordia.Date():toISO('T', 'Z'),
	}
end

return command
