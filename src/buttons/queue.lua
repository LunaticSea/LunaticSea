local bc, get = require('class')('Button@Queue')
local format_duration = require('internal').format_duration
local get_title = require('internal').get_title
local discordia = require('discordia')

function get:name()
  return 'queue'
end

function bc:run(client, button, language, player, nplaying, collector)
  if not player and collector then collector:stop() end

  local song = player.queue.current
  local thumbnail = song.artworkUrl
    or string.format("https://img.youtube.com/vi/%s/hqdefault.jpg", song.identifier)

  local pagesNum = math.ceil(player.queue.size / 10)
  if pagesNum == 0 then pagesNum = 1 end

  local songStrings = {}

  for song_id, song_data in pairs(player.queue.list) do
    table.includes(songStrings, string.format(
      "**%s** %s `[%s}]`",
      song_id,
      get_title(client, song_data),
      format_duration(song_data.duration)
    ))
  end

  local str = table.concat(table.slice(songStrings, 1 * 10, 1 * 10 + 10), "\n")
  local show_page_embed = {
    thumbnail = {
      url = thumbnail
    },
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    author = {
      name = client.i18n:get(language, 'button.music', 'queue_author')
    },
    description = client.i18n:get(language, 'button.music', 'queue_description', {
      get_title(client, song),
      format_duration(song.duration),
      song.requester.mentionString,
      (str == '') and '  Nothing' or '\n' + str,
    }),
    footer = {
      text = 1 .. "/" .. pagesNum
    }
  }

  button:reply({ embeds = { show_page_embed }, ephemeral = true })
end

return bc