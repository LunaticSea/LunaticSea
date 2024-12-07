local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command = require('class')('cm_image_avatar')

function command:init()
	self.name = { 'avatar' }
	self.description = "Show your or someone else's profile picture"
	self.category = 'image'
	self.accessableby = { accessableby.member }
	self.usage = '<mention>'
	self.aliases = {}
	self.lavalink = false
	self.playerCheck = false
	self.usingInteraction = true
	self.sameVoiceCheck = false
	self.permissions = {}
	self.options = { {
		name = 'user',
		description = 'Type your user here',
		type = applicationCommandOptionType.user,
		required = false,
	} }
end

function command:run(client, handler)
	handler:defer_reply()
	local data = handler.args[1]
	local getData = handler:parse_mentions(data)

	if data and getData and getData.type ~= 1 then
		local embed = {
			description = client.i18n:get(handler.language, 'error', 'arg_error', { '**@mention**!' }),
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	end

	local value = getData.data
	local template = 'https://cdn.discordapp.com/avatars/%s/%s.jpeg?size=300'

	if value and value ~= 'error' then
		local embed = {
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
			timestamp = discordia.Date():toISO('T', 'Z'),
			title = value.username,
			image = { url = string.format(template, value.id, value.avatar) },
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	else
		local embed = {
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
			timestamp = discordia.Date():toISO('T', 'Z'),
			title = value.username,
			image = { url = string.format(template, handler.user.id, handler.user.avatar) },
		}
		return handler:edit_reply({
			embeds = { embed },
		})
	end
end

return command
