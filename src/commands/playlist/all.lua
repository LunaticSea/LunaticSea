local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('Playlist:All')
local internal = require('internal')
local json = require('json')
local uv = require('uv')
local page_framework = internal.page
local ms = require('ms')

function get:name()
	return { 'pl', 'all' }
end

function get:description()
	return 'View all your playlist'
end

function get:category()
	return 'playlist'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<pages>'
end

function get:aliases()
	return {}
end

function get:config()
	return {
		lavalink = true,
		player_check = false,
		using_interaction = true,
		same_voice_check = false
	}
end

function get:permissions()
	return {}
end

function get:options()
	return {
    {
      name = 'page',
      description = 'The page you want to view',
      type = applicationCommandOptionType.number,
      required = false,
    },
  }
end

function command:run(client, handler)
  handler:defer_reply()

  local number = handler.args[1]
	local fulllist = client.db.playlist:all('playlist')
  local playlists = {}

	for i = 1, #fulllist, 1 do
		local value = fulllist[i]
		value.data = json.decode(value.data)
    if value.data.owner ~= handler.user.id then return end
    table.insert(playlists, value.data)
	end

  local page_num = math.ceil(#playlists / 10)
	if page_num == 0 then page_num = 1 end

	local playlist_strings = {}
	for i = 1, #playlists, 1 do
		local playlist = playlists[i]
		local created = ms((uv.hrtime() - playlists[i].created) / 1e6)
		local string_ele = client.i18n:get(handler.language, 'command.playlist', 'view_embed_playlist', {
      i, playlist.id, #playlist.tracks, created,
    })
		table.insert(playlist_strings, string_ele)
	end

	local pages = {}

	for i = 1, page_num do
		local str = table.concat(table.slice(playlist_strings, i, i * 10), "\n")

		local embed = {
			author = {
				name = client.i18n:get(handler.language, 'command.playlist', 'view_embed_title', {
					handler.guild.name
				})
			},
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
			description = str == "" and "  Nothing" or "\n" .. str,
		}

		table.insert(pages, embed)
	end

	if not number then
		if #pages == 1 or #pages == 0 then handler:edit_reply({ embeds = { pages[1] } })
		else page_framework(client, pages, 120000, handler):run() end
	else self:send_specific_page(client, handler, pages, page_num, number) end
end

function command:send_specific_page(client, handler, pages, page_num, value)
  if value > page_num then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'view_page_notfound', page_num),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  return handler.editReply({ embeds = { pages[page_num] } })
end

return command