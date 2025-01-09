local dia = require('discordia')
local command_handler, get = require('class')('CommandHandler')

local mention_enums = {
	ERROR = 0,
	USER = 1,
	ROLE = 2,
	EVERYONE = 3,
	CHANNEL = 4,
}

function command_handler:__init(options)
	self._msg = nil
	self._attactments = {}
	self._client = options.client
	self._interaction = options.interaction
	self._message = options.message
	self._language = options.language
	self._args = options.args or {}
	self._prefix = options.prefix
	self._USERS_PATTERN = '@[%d]+'
	self._ROLES_PATTERN = '@&[%d]+'
	self._CHANNELS_PATTERN = '#[%d]+'
	self._EVERYONE_PATTERN = '@everyone'
	self._HERE_PATTERN = '@here'
	self._mention_enums = mention_enums
end

function get:client()
	return self._client
end

function get:attactments()
	return self._attactments
end

function get:message()
	return self._message
end

function get:language()
	return self._language
end

function get:args()
	return self._args
end

function get:prefix()
	return self._prefix
end

function get:guild()
	if self._interaction then
		return self._interaction.guild
	end
	return self._message.guild
end

function get:user()
	if self._interaction then
		return self._interaction.user
	end
	return self._message.author
end

function get:member()
	if self._interaction then
		return self._interaction.member
	end
	return self._message.member
end

function get:createdAt()
	if self._interaction then
		return dia.Date.parseSnowflake(self._interaction.id)
	end
	return dia.Date.parseSnowflake(self._message.id)
end

function get:channel()
	if self._interaction then
		return self._interaction.channel
	end
	return self._message.channel
end

function get:mode_lang()
	return {
		enable = self._client.i18n:get(self._language, 'global', 'enable'),
		disable = self._client.i18n:get(self._language, 'global', 'disable'),
	}
end

function command_handler:send_message(data)
	if self._interaction then
		return self._interaction:reply(data)
	end
	return self._message:reply(data)
end

function command_handler:follow_up(data)
	if self._interaction then
		return self._interaction:followUp(data)
	end
	return self._message:reply(data)
end

function command_handler:defer_reply()
	if self._interaction then
		self._deferred = self._interaction:replyDeferred()
		self._msg = self._deferred
		return self._msg
	end
	self._msg = self._message:reply({
		content = string.format('**%s** is thinking...', self._client.user.username),
		reference = {
			message = self._message,
			mention = false,
		},
	})
	return self._msg
end

function command_handler:edit_reply(data)
	if not self._msg then
		self._client.logd:error('CommandHandler', 'You have not declared deferReply()')
		return nil
	end
	if not data.content then
		data.content = ''
	end
	if self._interaction then
	  self._interaction:reply(data)
		return self._interaction
	end
	self._msg:update(data)
	return self._msg
end

function command_handler:parse_mentions(data)
	data = data or ''
	-- Check user
	local user_match = string.match(data, self._USERS_PATTERN)
	if user_match then
		local id = user_match:sub(2)
		local user = self._client:getUser(id)
		if not user or (user == nil) then
			return {
				type = mention_enums.ERROR,
				data = 'error',
			}
		end
		return {
			type = mention_enums.USER,
			data = user,
		}
	end

	-- Check channel
	local channel_match = string.match(data, self._CHANNELS_PATTERN)
	if channel_match then
		local id = channel_match:sub(2)
		local channel = self._client:getChannel(id)
		if not channel or (channel == nil) then
			return {
				type = mention_enums.ERROR,
				data = 'error',
			}
		end
		return {
			type = mention_enums.CHANNEL,
			data = channel,
		}
	end

	-- Check role
	local role_match = string.match(data, self._ROLES_PATTERN)
	if role_match then
		local id = role_match:sub(3)
		local role = self._client:getRole(id)
		if not role or (role == nil) then
			return {
				type = mention_enums.ERROR,
				data = 'error',
			}
		end
		return {
			type = mention_enums.ROLE,
			data = role,
		}
	end

	-- Check everyone / here
	local everyone_match = string.match(data, self._EVERYONE_PATTERN)
	local here_match = string.match(data, self._HERE_PATTERN)
	if everyone_match or here_match then
		return {
			type = mention_enums.EVERYONE,
			data = true,
		}
	end

	-- Fallback
	return {
		type = mention_enums.ERROR,
		data = 'error',
	}
end

return command_handler
