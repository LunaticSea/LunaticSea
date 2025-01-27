local bc, get = require('class')('Button@Shuffle')
local format_duration = require('internal').format_duration
local get_title = require('internal').get_title
local page = require('internal').page
local discordia = require('discordia')

function get:name()
  return 'shuffle'
end

function bc:run(client, button, language, player, nplaying, collector)
  if not player and collector then collector:stop() end
  local newQueue = player.queue:shuffle()

  local song = newQueue.current
  local thumbnail = song.artworkUrl
    or string.format("https://img.youtube.com/vi/%s/hqdefault.jpg", song.identifier)

  local pagesNum = math.ceil(newQueue.size / 10)
  if pagesNum == 0 then pagesNum = 1 end

  local songStrings = {}

  for song_id, song_data in pairs(newQueue.list) do
    table.includes(songStrings, string.format(
      "**%s** %s `[%s}]`",
      song_id,
      get_title(client, song_data),
      format_duration(song_data.duration)
    ))
  end

  local pages = {}

  for i = 1, pagesNum do
    local str = table.concat(table.slice(songStrings, i * 10, i * 10 + 10), "\n")

    local embed = {
      thumbnail = {
        url = thumbnail
      },
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
      author = {
        name = client.i18n:get(language, 'button.music', 'shuffle_msg')
      },
      description = client.i18n:get(language, 'button.music', 'queue_description', {
        get_title(client, song),
        format_duration(song.duration),
        song.requester.mentionString,
        (str == '') and '  Nothing' or '\n' + str,
      }),
      footer = {
        text = i .. "/" .. pagesNum
      }
    }

    table.insert(pages, embed)
  end

  if #pages == pagesNum and #newQueue > 10 then
    page(client, pages, 60000, button, language):run()
  else button:reply({ embeds = { pages[1] }, ephemeral = true }) end
end

return bc