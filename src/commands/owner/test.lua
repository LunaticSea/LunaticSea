local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command = require('class'):create()
local page_framework_class = require('../../structures/page')

function command:init()
	self.name = { 'test' }
	self.description = 'Test command'
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

	local embeds = {
	  {
      description = 'Hey :O',
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    },
    {
      description = 'Hi :D',
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    },
	}

	local page_framework = page_framework_class:new({
    client = client,
    pages = embeds,
    timeout = 120000,
    handler = handler
  })

  page_framework:run()
end

return command
