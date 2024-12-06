local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command = require('class'):create()
local page_framework = require('../../structures/page')

function command:init()
	self.name = { 'pm', 'guild', 'list' }
	self.description = 'View all existing premium guild!'
	self.category = 'premium'
	self.accessableby = { accessableby.admin }
	self.usage = ''
	self.aliases = { 'pmgl' }
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

	local guilds = table.map(client._db.preGuild:all(), function (element)
	  return element.data
	end)

	local page_num = math.ceil(#guilds / 10)
	if page_num == 0 then page_num = 1 end

	local guild_strings = {}
	for i = 1, #guilds, 1 do
	  local guild = guilds[i]
	  local string_ele = string.format('`%s. %s/%s - %s`', i, guild.redeemedBy.name, guild.plan)
	  table.insert(guild_strings, string_ele)
	end

	local pages = {}

  for i = 1, page_num do
    local str = table.concat(table.slice(guild_strings, i * 10, i * 10 + 10), "\n")

    local embed = {
      author = {
        name = client._i18n:get(handler.language, "command.premium", "guild_list_title")
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
      description = client._i18n:get(handler.language, 'command.premium', 'guild_list_page_notfound', page_num),
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
