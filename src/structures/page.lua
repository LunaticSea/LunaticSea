local page = require('class')('Page')
local discordia = require('discordia')

function page:__init(client, pages, timeout, handler)
  self._client = assert(client, 'Client not found')
  self._handler = assert(handler, 'Command handler not found')
  self._pages = assert(pages, 'Pages not found')
  self._language = self._handler.language
  self._timeout = timeout
end

function page:run()
  if not self._handler or not self._handler.channel then error('Channel is inaccessible.') end
  if not self._pages then error('Pages are not given.') end
  if #self._pages == 0 then return end

	local row = self:generate_button_array()

	local currpage = 1
	local init_page = self._pages[currpage]
	init_page.footer = {
	  text = string.format('%s/%s', currpage, #self._pages)
	}

	local curPage = self._handler:edit_reply({
	  embeds = { init_page },
	  components = { row }
	})

	local collector = curPage:createCollector('button')

	collector:on('collect', function (interaction)
	  if not interaction._deferred then interaction:updateDeferred() end

	  if interaction.data.custom_id == 'back' then
	    if currpage > 1 then currpage = currpage - 1 else currpage = #self._pages end
	  elseif interaction.data.custom_id == 'next' then
      if currpage < #self._pages then currpage = currpage + 1 else page = 1 end
	  end

	  local selected_page = self._pages[currpage]
    selected_page.footer = {
      text = string.format('%s/%s', currpage, #self._pages)
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
    emoji = self._client.icons.GLOBAL.arrow_previous,
    style = "secondary"
  })

  local next_button = discordia.Button({
    id = "next",
    emoji = self._client.icons.GLOBAL.arrow_next,
    style = "secondary"
  })

  return discordia.Components({ back_button, next_button })
end

return page
