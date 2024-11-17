local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command = require('class'):create()

function command:init()
	self.name = { 'shutdown' }
	self.description = 'Shuts down the client!'
	self.category = 'owner'
	self.accessableby = { accessableby.owner }
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
	handler:defer_reply()

	local embed = {
		description = client._i18n:get(handler.language, 'command.admin', 'restart_msg'),
		color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
	}
	handler:edit_reply({
		embeds = { embed },
	})

	os.exit()
end

return command
