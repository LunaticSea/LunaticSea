local PlayerState = require('lunalink').enums.PlayerState
local timer = require('timer')
local discordia = require('discordia')
local setTimeout = timer.setTimeout
local clearTimeout = timer.clearTimeout

return function (client, member, channel)
  client.logd:info('VoiceJoin', string.format('%s join %s (%s)', member.name, channel.name, channel.id))

  -- Check player avaliable
  local player = client.lunalink.players:get(member.guild.id)
  if not player then return end

  -- Check if voice empty but player not destroyed
  local isNoOneInChannel = table.filter(channel.connectedMembers, function (user)
    return not user.bot
  end)
  local isNotDestroy = not player.data:get('sudo-destroy') and player.state ~= PlayerState.DESTROYED

  if isNoOneInChannel == 0 and isNotDestroy then
    player:destroy()
  end

  -- Check if member is a bot
  if member.bot and  member.id ~= client.user.id then return end

  -- Get language
  local language = client.db.language:get(member.guild.id)
	if not language then language = client.i18n.default_locate end

  -- Check if bot not in voice but player not destroyed
  local botMemberStatus = member.guild:getMember(client.user.id)
  local isNotInChannel = not botMemberStatus or not botMemberStatus.voiceChannel

  if isNotInChannel and isNotDestroy then
    player.data.set('sudo-destroy', true)
    player:destroy()
  elseif isNotInChannel then return end

  -- Get text channel
  local textChannel = member.guild:getChannel(player.textId)

  -- Resume audio on join feature
  local inVoiceUserList = table.filter(channel.connectedMembers, function (user)
    if user.id == client.user.id then return true end
    if user.bot then return false
    else return true end
  end)

  if player.track and player.paused and #inVoiceUserList >= 2 then
    player:setPause(false)

    local embed = {
      description = client.i18n:get(language, 'event.player', 'leave_resume'),
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

  -- Remove current timeout
  local leave_delay_timeout = client.leaveDelay:get(member.guild.id)
  if not leave_delay_timeout then return end
  clearTimeout(leave_delay_timeout)
  client.leaveDelay:delete(member.guild.id)
end