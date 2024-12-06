local page = require('class'):create()
local discordia = require('discordia')

function page:init(client, pages, timeout, handler)
  self.client = assert(client, 'Client not found')
  self.handler = assert(handler, 'Command handler not found')
  self.pages = assert(pages, 'Pages not found')
  self.language = self.handler.language
  self.timeout = timeout
end

function page:run()
  if not self.handler or not self.handler.channel then error('Channel is inaccessible.') end
  if not self.pages then error('Pages are not given.') end
  if #self.pages == 0 then return end

	local row = self:generate_button_array()

	local page = 1
	local init_page = self.pages[page]
	init_page.footer = {
	  text = string.format('%s/%s', page, #self.pages)
	}

	local curPage = self.handler:edit_reply({
	  embeds = { init_page },
	  components = { row }
	})

	local collector = curPage:createCollector('button')

	collector:on('collect', function (interaction)
	  if not interaction._deferred then interaction:updateDeferred() end

	  if interaction.data.custom_id == 'back' then
	    if page > 1 then page = page - 1 else  page = #self.pages end
	  elseif interaction.data.custom_id == 'next' then
      if page < #self.pages then page = page + 1 else page = 1 end
	  end

	  local selected_page = self.pages[page]
    selected_page.footer = {
      text = string.format('%s/%s', page, #self.pages)
    }

	  local data, err = interaction.message:update({
	    embeds = { selected_page },
	    components = { row }
	  })
	end)
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
