local PlayerState = require('lunalink').enums.PlayerState
local arb = require('internal').auto_reconnect_builder
local timer = require('timer')
local discordia = require('discordia')
local setTimeout = timer.setTimeout

return function (client, member, channel)
  client.logd:info('VoiceLeave', string.format('%s leave %s (%s)', member.name, channel.name, channel.id))

  -- Check player avaliable
  local player = client.lunalink.players:get(member.guild.id)
  if not player then return end

  -- Check if voice empty but player not destroyed
  local isNoOneInChannel = table.filter(channel.connectedMembers, function (user)
    return not user.bot
  end)
  local isNotDestroy = not player.data:get('sudo-destroy') and player.state ~= PlayerState.DESTROYED
  if isNoOneInChannel == 0 and isNotDestroy then player:destroy() end

  -- Check if member is a bot
  if member.bot then return end

  -- Check if auto reconnect 247 still avaliable
  local auto_reconnect = arb(client):get(member.guild.id)
  if auto_reconnect and auto_reconnect.twentyfourseven then return end

  -- Get language
  local language = client.db.language:get(member.guild.id)
	if not language then language = client.i18n.default_locate end

  -- Check if bot not in voice but player not destroyed
  local botMemberStatus = member.guild:getMember(client.user.id)
  local isNotInChannel = not botMemberStatus or not botMemberStatus.voiceChannel

  if isNotInChannel and isNotDestroy then
    player.data:set('sudo-destroy', true)
    player:destroy()
  elseif isNotInChannel then return end

  -- Get text channel
  local textChannel = member.guild:getChannel(player.textId)

  -- Pause audio on leave feature
  local inVoiceUserList = table.filter(channel.connectedMembers, function (user)
    if user.id == client.user.id then return true end
    if user.bot then return false end
  end)

  if player.track and not player.paused and #inVoiceUserList <= 1 then
    player:setPause(true)

    local embed = {
      description = client.i18n:get(language, 'event.player', 'leave_pause'),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }

    local msg = textChannel and textChannel:send({ content = ' ', embeds = { embed } }) or true

    local msg_timeout_func = coroutine.wrap(function ()
      local setup = client.db.setup:get(msg.guild.id)
      if (not setup or setup.channel ~= msg.channel.id) and textChannel then
        msg:delete()
      end
    end)

    setTimeout(client.config.utilities.DELETE_MSG_TIMEOUT, msg_timeout_func)
  end

  -- Delay leave timeout
  local leave_delay_timeout = setTimeout(client.config.player.LEAVE_TIMEOUT, coroutine.wrap(function ()
    local is247 = client.db.autoreconnect:get(member.guild.id)

    if #inVoiceUserList <= 1 then
      player.data:set('sudo-destroy', true)
      if is247 and is247.twentyfourseven then player:stop()
      else player:destroy() end
    end

    local timeout_embed = {
      description = client.i18n:get(language, 'event.player', 'player_end', { channel.id }),
      color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
    }

    local msg = textChannel and textChannel:send({
      content = ' ', embeds = { timeout_embed }
    }) or nil

    local msg_timeout_func =  coroutine.wrap(function ()
      local setup = client.db.setup:get(msg.guild.id)
      if (not setup or setup.channel ~= msg.channel.id) and textChannel then
        msg:delete()
      end
    end)

    setTimeout(client.config.utilities.DELETE_MSG_TIMEOUT, msg_timeout_func)

    client.leaveDelay:delete(member.guild.id)
  end))
  client.leaveDelay:set(member.guild.id, leave_delay_timeout)
end