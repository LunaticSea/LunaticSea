local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command = require('class'):create()
local page_framework = require('../../structures/page')

function command:init()
	self.name = { 'pm', 'list' }
	self.description = 'View all existing premium user!'
	self.category = 'premium'
	self.accessableby = { accessableby.admin }
	self.usage = ''
	self.aliases = { 'pml' }
	self.lavalink = false
	self.playerCheck = false
	self.usingInteraction = true
	self.sameVoiceCheck = false
	self.permissions = {}
	self.options = {
	  {
      name = 'page',
      description = 'Page number to show.',
      type = applicationCommandOptionType.number,
      required = false,
    },
	}
end

function command:run(client, handler)
	handler:defer_reply()

	local value = tonumber(handler.args[0])

	if value and type(value) ~= 'number' then
	  local embed = {
      description = client._i18n:get(handler.language, 'error', 'number_invalid'),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({
      embeds = { embed },
    })
	end

	local users = table.map(client._db.premium:all(), function (element)
	  return element.data
	end)

	local page_num = math.ceil(#users / 10)
	if page_num == 0 then page_num = 1 end

	local user_strings = {}
	for i = 1, #users, 1 do
	  local user = users[i]
	  local string_ele = string.format('`%s. %s/%s - %s`', i, user.redeemedBy.username, user.id, user.plan)
	  table.insert(user_strings, string_ele)
	end

	local pages = {}

  for i = 1, page_num do
    local str = table.concat(table.slice(user_strings, i * 10, i * 10 + 10), "\n")

    local embed = {
      author = {
        name = client._i18n:get(handler.language, "command.premium", "list_title")
      },
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
      description = str == "" and "  Nothing" or "\n" + str,
      footer = {
        text = i .. "/" .. page_num
      }
    }

    table.insert(pages, embed)
  end

  if not value then
    if #pages == 1 or #pages == 0 then handler:edit_reply({ embeds = { pages[1] } })
    else page_framework:new(client, pages, 120000, handler):run() end
  else self:send_specific_page(client, handler, pages, page_num, value) end
end


function command:send_specific_page(client, handler, pages, page_num, value)
  if value > page_num then
    local embed = {
      description = client._i18n:get(handler.language, 'command.premium', 'list_page_notfound', page_num),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  local pageNum = value == 0 and 1 or tonumber(value)
  return handler.editReply({ embeds = { pages[page_num] } })
end

return command
