local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command = require('class')('cm_premium_profile')

function command:init()
	self.name = { 'pm', 'profile' }
	self.description = 'View your premium profile!'
	self.category = 'premium'
	self.accessableby = { accessableby.member }
	self.usage = ''
	self.aliases = {}
	self.lavalink = false
	self.playerCheck = false
	self.usingInteraction = true
	self.sameVoiceCheck = false
	self.permissions = {}
	self.options = {
	  {
      name = 'user',
      description = 'The code you want to redeem',
      type = applicationCommandOptionType.user,
      required = true,
    },
	}
end

function command:run(client, handler)
	handler:defer_reply()

	local user = handler.user
	local data = handler.args[0]
	local getData = handler:parseMentions(data)
	if data and get and getData.type == 1 then
	  user = getData.data
	end

	if user.id == client._bot_owner then
    local embed_args = { user.username, 'dreamvast@owner', 'lifetime' }
    local embed = self:embed_gen(client, handler, embed_args)
    return handler:edit_reply({ embeds = { embed } })
	end

	if table.includes(client.config.bot.ADMIN, user.id) then
	  local embed_args = { user.username, 'dreamvast@admin', 'lifetime' }
    local embed = self:embed_gen(client, handler, embed_args)
    return handler:edit_reply({ embeds = { embed } })
	end

	local premium_plan = client._db.premium:get(user.id)

	if not premium_plan then
	  local embed_args = { user.username }
    local embed = self:embed_gen(client, handler, embed_args, true)
    return handler:edit_reply({ embeds = { embed } })
	end

  local formated_time = string.format('<t:%s:F>', premium_plan.expiresAt)
  if premium_plan.expiresAt == 15052008 then formated_time = 'lifetime' end
	
	local embed_args = { user.username, premium_plan.plan, formated_time }
  local embed = self:embed_gen(client, handler, embed_args)

  return handler:edit_reply({ embeds = { embed } })
end

function command:embed_gen(client, handler, desc_args, is_err)
  local default_str = { handler.language,  'command.premium', 'profile_desc', desc_args }
  if is_err then
    default_str = { handler.language,  'command.premium', 'profile_error_desc', desc_args }
  end

  return {
    author = {
      name = client._i18n:get(handler.language, 'command.premium', 'profile_author'),
      iconURL = client.user:getAvatarURL()
    },
		description = client._i18n:get(table.unpack(default_str)),
		color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
		timestamp = discordia.Date():toISO('T', 'Z'),
	}
end

return command
