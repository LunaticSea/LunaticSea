local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command = require('class')('cm_info_ping')
local stopwatch = discordia.Stopwatch()

function command:init()
	self.name = { 'ping' }
	self.description = 'Shows the ping of the Bot'
	self.category = 'info'
	self.accessableby = { accessableby.member }
	self.usage = ''
	self.aliases = {}
	self.lavalink = false
	self.playerCheck = false
	self.usingInteraction = true
	self.sameVoiceCheck = false
	self.permissions = {}
	self.options = {}
end

function command:run(client, handler)
	stopwatch:reset()
	stopwatch:start()
	handler:defer_reply()
	stopwatch:stop()

	local ping = math.floor(stopwatch:getTime():toMilliseconds()+0.5)

	local embed_data = {
		title = '🏓 ' .. client.user.username,
		description = client._i18n:get(handler.language, 'command.info', 'ping_desc', { ping }),
		color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
		timestamp = discordia.Date():toISO('T', 'Z'),
	}
	handler:edit_reply({
		embeds = { embed_data },
	})
end

return command
