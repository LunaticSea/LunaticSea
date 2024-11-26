local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command = require('class'):create()

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

	local embed = {
		description = 'Hi :D',
		color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
	}

	local row1 = discordia.Components({
    {
      id = "hi",
      type = "button",
      label = "Halo"
    }
  })

  local row2 = discordia.Components({
    {
      id = "halo",
      type = "button",
      label = "Halo"
    }
  })

	local msg = handler:edit_reply({
		embeds = { embed },
		components = { row1, row2 },
	})

	local collector = msg:createCollector("button")

	collector:on('collect', function (interaction)
	  interaction:reply('Halo :D ' .. interaction.data.custom_id)
	end)

	collector:on('end', function ()
	  p('See ya :D')
	end)
end

return command
