local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command = require('class')('cm_premium_redeem')

function command:init()
	self.name = { 'pm', 'redeem' }
	self.description = 'Redeem your premium!'
	self.category = 'premium'
	self.accessableby = { accessableby.member }
	self.usage = '<type> <input>'
	self.aliases = { 'pmr' }
	self.lavalink = false
	self.playerCheck = false
	self.usingInteraction = true
	self.sameVoiceCheck = false
	self.permissions = {}
	self.options = {
	  {
      name = 'type',
      description = 'Which type you want to redeem?',
      required = true,
      type = applicationCommandOptionType.string,
      choices = {
        {
          name = 'User',
          value = 'user',
        },
        {
          name = 'Guild',
          value = 'guild',
        },
      },
    },
    {
      name = 'code',
      description = 'The code you want to redeem',
      type = applicationCommandOptionType.string,
      required = true,
    },
	}
end

function command:run(client, handler)
	handler:defer_reply()
	local types = table.map(self.options[1].choices, function(data) return data.value end)
	local type = handler.args[1]
  local input_code = handler.args[2]

  if not type or not table.includes(types, type) then
    local embed = {
      description = client.i18n:get(handler.language, 'command.premium', 'redeem_invalid_mode'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  if not input_code then
    local embed = {
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      description = client.i18n:get(handler.language, 'command.premium', 'redeem_invalid'),
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  local pre_data = client.db.premium:get(handler.user.id)
  if (type == 'guild') then pre_data = client.db.preGuild:get(handler.guild.id) end

  if pre_data and pre_data.isPremium then
    local lang_key = 'redeem_already'
    if (type == 'guild') then lang_key = 'redeem_already_guild' end
  
    local embed = {
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      description = client.i18n:get(handler.language, 'command.premium', lang_key),
    }

    return handler:edit_reply({
      embeds = { embed },
    })
  end

  local premium = client.db.code:get(input_code)
  local is_expired = premium and premium.expiresAt ~= 15052008 and premium.expiresAt < os.time()

  if not premium or is_expired then
    local embed = {
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      description = client.i18n:get(handler.language, 'command.premium', 'redeem_invalid'),
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  local formated_time = string.format('<t:%s:F>', premium.expiresAt)
  if premium.expiresAt == 15052008 then formated_time = 'lifetime' end

	local embed = {
	  author = {
	    name = client.i18n:get(handler.language, 'command.premium', 'redeem_title'),
	    iconURL = client.user:getAvatarURL()
	  },
		description = client.i18n:get(handler.language, 'command.premium', 'redeem_desc', {
		  premium.plan, formated_time
		}),
		color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		timestamp = discordia.Date():toISO('T', 'Z'),
	}

	client.db.code:delete(input_code)

	handler:edit_reply({
		embeds = { embed },
	})

	local target_db = client.db.premium
	local target_id = handler.user.id
	local target_redeemed_by = {
	  id = handler.user.id,
    username = handler.user.username,
    displayName = handler.user.displayName,
    avatarURL = handler.user:getAvatarURL() or nil,
    createdAt = handler.user.createdAt,
    mention =  string.format('<@%s>', handler.user.id),
	}

  if (type == 'guild') then
    target_db = client.db.preGuild
    target_id = handler.guild.id
    target_redeemed_by = {
      id = handler.guild.id,
      name = handler.guild.name,
      createdAt = handler.guild.createdAt,
      ownerId = handler.guild.ownerId,
    }
  end

  target_db:set(target_id, {
    id = target_id,
    redeemedBy = target_redeemed_by,
    redeemedAt = os.time(),
    expiresAt = premium.expiresAt,
    plan = premium.plan
  })
end

return command
