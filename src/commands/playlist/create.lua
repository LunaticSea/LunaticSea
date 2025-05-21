local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command, get = require('class')('Playlist:Create')
local uv = require('uv')
local json = require('json')

function get:name()
	return { 'pl', 'create' }
end

function get:description()
	return 'Create a new playlist'
end

function get:category()
	return 'playlist'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return '<playlist_name> <playlist_description>'
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
      name = 'name',
      description = 'The name of the playlist',
      type = applicationCommandOptionType.string,
      required = true,
    },
    {
      name = 'description',
      description = 'The description of the playlist',
      type = applicationCommandOptionType.string,
    }
  }
end

function command:run(client, handler)
  handler:defer_reply()

  local value = handler.args[1]
  local des = handler.args[2]

  if not value then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'invalid'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if #value > 16 then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'create_toolong'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if #value > 16 then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'create_toolong'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  if des and #des > 1000 then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'des_toolong'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

	local fulllist = client.db.playlist:all('playlist')
  local playlists = {}

	for i = 1, #fulllist, 1 do
		local value = fulllist[i]
		value.data = json.decode(value.data)
    if value.data.owner ~= handler.user.id then return end
    table.insert(playlists, value.data)
	end

  if #playlists >= client.config.player.LIMIT_PLAYLIST then
    local embed = {
      description = client.i18n:get(handler.language, 'command.playlist', 'create_limit_playlist', {
        client.config.player.LIMIT_PLAYLIST
      }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  local idgen = 'playlist-' .. self:code_gen(8, os.time())

  client.db.playlist:set(idgen, {
    id = idgen,
    name = value,
    owner = handler.user.id,
    tracks = {},
    private = true,
    created = uv.hrtime(),
    description = des and des or nil
  })

  local embed = {
    description = client.i18n:get(handler.language, 'command.playlist', 'create_created', {
      value, idgen
    }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }
  return handler:edit_reply({ embeds = { embed } })
end

function command:code_gen(length, seed)
  local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  local randomString = ''

  math.randomseed(seed)

  local charTable = {}
  for c in chars:gmatch"." do
    table.insert(charTable, c)
  end

  for i = 1, length do
    randomString = randomString .. charTable[math.random(1, #charTable)]
  end

  return randomString
end

return command