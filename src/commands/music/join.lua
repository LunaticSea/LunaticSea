local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local command, get = require('class')('Music:Join')

function get:name()
	return { 'join' }
end

function get:description()
	return 'Make the bot join the voice channel.'
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
	return { 'j' }
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
	return {}
end

function command:run(client, handler)
	handler:defer_reply()

  local channel = handler.member.voiceChannel
  if not channel then
    local embed =  {
      description = client.i18n:get(handler.language, 'error', 'no_in_voice'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({ embeds = { embed } })
  end

  local player = client.lunalink.players:get(handler.guild.id)
  if not player then
    player = client.lunalink:create({
      guildId = handler.guild.id,
      textId = handler.channel.id,
      voiceId = channel.id,
      shardId = handler.guild.shardId,
      volume = 100
    })
  elseif player and (not self:check_same_voice(client, handler)) then return end

  player._textId = handler.channel.id

  local embed =  {
    description = client.i18n:get(handler.language, 'command.music', 'join_msg', {
      string.format('<#%s>', channel.id)
    }),
    color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
  }

  handler:edit_reply({ content = ' ', embeds = { embed } })
end

function command:check_same_voice(client, handler)
  local bot_voice_id = handler.guild.me.voiceChannel.id
  local user_voice_id = handler.member.voiceChannel.id
  if bot_voice_id ~= user_voice_id then
    local embed =  {
      description = client.i18n:get(handler.language, 'error', 'no_same_voice'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    handler:edit_reply({ embeds = { embed } })
    return false
  elseif bot_voice_id == user_voice_id then
    local embed =  {
      description = client.i18n:get(handler.language, 'command.music', 'join_already'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }
    handler:edit_reply({ embeds = { embed } })
    return false
  end

  return true
end

return command
