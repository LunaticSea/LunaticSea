local discordia = require('discordia')

local function playerRowOne(client, disable, edited)
  return discordia.Components( {
    {
      id = "stop",
      type = "button",
      style = "secondary",
      emoji = client.config.emojis.PLAYER.stop,
      disabled = disable
    },
    {
      id = "replay",
      type = "button",
      style = "secondary",
      emoji = client.config.emojis.PLAYER.previous,
      disabled = disable
    },
    {
      id = "pause",
      type = "button",
      style = "secondary",
      emoji = client.config.emojis.PLAYER[edited and "play" or "pause"],
      disabled = disable
    },
    {
      id = "skip",
      type = "button",
      style = "secondary",
      emoji = client.config.emojis.PLAYER.skip,
      disabled = disable
    },
    {
      id = "loop",
      type = "button",
      style = "secondary",
      emoji = client.config.emojis.PLAYER.loop,
      disabled = disable
    },
  })
end

local function playerRowTwo(client, disable)
  return discordia.Components( {
    {
      id = "shuffle",
      type = "button",
      style = "secondary",
      emoji = client.config.emojis.PLAYER.shuffle,
      disabled = disable
    },
    {
      id = "voldown",
      type = "button",
      style = "secondary",
      emoji = client.config.emojis.PLAYER.voldown,
      disabled = disable
    },
    {
      id = "clear",
      type = "button",
      style = "secondary",
      emoji = client.config.emojis.PLAYER.clear,
      disabled = disable
    },
    {
      id = "volup",
      type = "button",
      style = "secondary",
      emoji = client.config.emojis.PLAYER.volup,
      disabled = disable
    },
    {
      id = "queue",
      type = "button",
      style = "secondary",
      emoji = client.config.emojis.PLAYER.queue,
      disabled = disable
    },
  })
end

local function filterSelect(client, disable)
  return discordia.Components({
    discordia.SelectMenu({
      id = "filter",
      placeholder = 'Choose a filter for better audio experience',
      options = client.selectMenuOptions,
      disabled = disable
    })
  })
end

return {
  playerRowOne = playerRowOne,
  playerRowTwo = playerRowTwo,
  filterSelect = filterSelect
}