local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Music:Shuffle')
local internal = require('internal')
local page_framework = internal.page
local format_duration = internal.format_duration
local get_title = internal.get_title

function get:name()
	return { 'shuffle' }
end

function get:description()
	return 'Shuffle song in queue!'
end

function get:category()
	return 'music'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return ''
end

function get:aliases()
	return {}
end

function get:config()
	return {
		lavalink = true,
		player_check = true,
		using_interaction = true,
		same_voice_check = true
	}
end

function get:permissions()
	return {}
end

function get:options()
	return {}
end

function command:run(client, handler)
	handler:defer_reply()

  local player = client.lunalink.players:get(handler.guild.id)

	local old_queue = {}

	for _, track in pairs(player.queue.list) do
		table.insert(old_queue, track)
	end

	player.data:set('old_queue', old_queue)

	local newQueue = player.queue:shuffle()

  local song = newQueue.current
  local thumbnail =
    song.artworkUrl or string.format('https://img.youtube.com/vi/%s/hqdefault.jpg', song.identifier)

	local page_num = math.ceil(#newQueue.list / 10)
	if page_num == 0 then page_num = 1 end

	local song_strings = {}
	for i = 1, #newQueue.list, 1 do
		local song_e = newQueue[i]
		local string_ele = string.format(
			'**%s.** %s `%s`', i, get_title(client, song_e), format_duration(song_e.duration)
		)
		table.insert(song_strings, string_ele)
	end

	local pages = {}

	for i = 1, page_num do
		local str = table.concat(table.slice(song_strings, i * 10, i * 10 + 10), "\n")

		local embed = {
			author = {
				name = client.i18n:get(handler.language, 'command.music', 'queue_author', {
					handler.guild.name
				})
			},
			color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
			thumbnail = { url = thumbnail },
			description = client.i18n:get(handler.language, 'command.music', 'queue_description', {
				get_title(client, song),
				song.requester.username,
				format_duration(newQueue.duration),
				str == "" and "  Nothing" or "\n" + str
			}),
			footer = {
				text = i .. "/" .. page_num
			}
		}

		table.insert(pages, embed)
	end

	if #pages == 1 or #pages == 0 then handler:edit_reply({ embeds = { pages[1] } })
	else page_framework(client, pages, 120000, handler):run() end
end

return command