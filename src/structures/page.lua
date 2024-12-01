local page = require('class'):create()
local discordia = require('discordia')

local default = {
  client = nil,
  pages = nil,
  timeout = 120000,
  language = nil,
  interaction = nil,
  message  = nil
}

function page:init(options)
  options = options or default
  self.client = assert(options.client, 'Client not found')
  self.pages = assert(type(options.pages) == 'table', 'Pages not found')
  self.language = assert(options.language, 'Language not found')
  self.timeout = options.timeout
  self.interaction = options.interaction
  self.message = options.message
end

function page:run()
  if not self.interaction and not self.message then
    error("Missing both message and interaction, please check again!")
  elseif self.interaction then
    self:slash(self.interaction)
  elseif self.message then
    self:message(self.message)
  end
end

function page:slash(interaction)
  if not interaction or not interaction.channel then error('Channel is inaccessible.') end
  if not this.pages then error('Pages are not given.') end
  if #this.page == 0 then return end

	local row = page:generate_button_array()

	local page = 1
	local init_page = this.pages[page]
	init_page.footer = {
	  text = string.format('%s/%s', page, #this.pages)
	}

	interaction:editReply({
	  embeds = { init_page },
	  components = { row }
	})

	local collector = interaction:createCollector('button')

	collector:on('collect', function (interaction) end)
end

function page:message(message)
  
end

function page:generate_button_array()
  local back_button = discordia.Button({
    id = "back",
    emoji = self.client._icons.GLOBAL.arrow_previous,
    style = "secondary"
  })

  local next_button = discordia.Button({
    id = "next",
    emoji = self.client._icons.GLOBAL.arrow_next,
    style = "secondary"
  })

  return discordia.Components({ back_button, next_button })
end

return page
