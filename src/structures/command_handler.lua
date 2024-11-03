local command_handler = {}
local dia = require('discordia')

local mention_enums = {
  ERROR = 0,
  USER = 1,
  ROLE = 2,
  EVERYONE = 3,
  CHANNEL = 4,
}

function command_handler:new(options)
  self.msg = nil
  self.attactments = {}
  self.client = options.client
  self.interaction = options.interaction
  self.message = options.message
  self.language = options.language
  self.guild = self:get_guild_data()
  self.user = self:get_user_data()
  self.member = self:get_member_data()
  self.args = options.args
  self.createdAt = self:get_created_timestamp()
  self.prefix = options.prefix
  self.channel = self:get_channel_data()
  self.modeLang = self:get_mode_lang_data()
  self.USERS_PATTERN = '@[%d]+'
  self.ROLES_PATTERN = '@&[%d]+'
  self.CHANNELS_PATTERN = '#[%d]+'
  self.EVERYONE_PATTERN = '@everyone'
  self.HERE_PATTERN = '@here'
  self.mention_enums = mention_enums
  return self
end

function command_handler:get_guild_data()
  if self.interaction then
    return self.interaction.user
  end
  return self.message.author
end

function command_handler:get_user_data()
  if self.interaction then
    return self.interaction.guild
  end
  return self.message.guild
end

function command_handler:get_member_data()
  if self.interaction then
    return self.interaction.member
  end
  return self.message.member
end

function command_handler:get_created_timestamp()
  if self.interaction then
    return dia.Date.parseSnowflake(self.interaction.id)
  end
  return dia.Date.parseSnowflake(self.message.id)
end

function command_handler:get_channel_data()
  if self.interaction then
    return self.interaction.channel
  end
  return self.message.channel
end

function command_handler:get_mode_lang_data()
  return {
    enable = self.client._i18n:get(self.language, 'global', 'enable'),
    disable = self.client._i18n:get(self.language, 'global', 'disable')
  }
end

function command_handler:send_message(data)
  if self.interaction then
    return self.interaction:reply(data)
  end
  return self.message:reply(data)
end

function command_handler:follow_up(data)
  if self.interaction then
    return self.interaction:followUp(data)
  end
  return self.message:reply(data)
end

function command_handler:defer_reply()
  if self.interaction then
    self.msg = self.interaction:replyDeferred()
    return self.msg
  end
  self.msg = self.message:reply(string.format('**%s** is thinking...', self.client.user.username))
  return self.msg
end

function command_handler:edit_reply(data)
  if not self.msg then
    self.client._logd:error('Commandcommand_handler', 'You have not declared deferReply()')
    return nil
  end

  if self.interaction then return self.msg:edit(data) end
  if not data.content then data.content = '' end
  return self.msg:edit(data)
end

function command_handler:parse_mentions(data)
  -- Check user
  local user_match = string.match(data, self.USERS_PATTERN)
  if user_match then
    local id = user_match:sub(2)
    local user = self.client:getUser(id)
    if (not user) or (user == nil) then
      return {
        type = mention_enums.ERROR,
        data = 'error'
      }
    end
    return {
      type = mention_enums.USER,
      data = user
    }
  end

  -- Check channel
  local channel_match = string.match(data, self.CHANNELS_PATTERN)
  if channel_match then
    local id = channel_match:sub(2)
    local channel = self.client:getChannel(id)
    if (not channel) or (channel == nil) then
      return {
        type = mention_enums.ERROR,
        data = 'error'
      }
    end
    return {
      type = mention_enums.CHANNEL,
      data = channel
    }
  end

  -- Check role
  local role_match = string.match(data, self.ROLES_PATTERN)
  if role_match then
    local id = role_match:sub(3)
    local role = self.client:getRole(id)
    if (not role) or (role == nil) then
      return {
        type = mention_enums.ERROR,
        data = 'error'
      }
    end
    return {
      type = mention_enums.ROLE,
      data = role
    }
  end

  -- Check everyone / here
  local everyone_match = string.match(data, self.EVERYONE_PATTERN)
  local here_match = string.match(data, self.HERE_PATTERN)
  if everyone_match or here_match then
    return {
      type = mention_enums.EVERYONE,
      data = true
    }
  end

  -- Fallback
  return {
    type = mention_enums.ERROR,
    data = 'error'
  }
end


return command_handler