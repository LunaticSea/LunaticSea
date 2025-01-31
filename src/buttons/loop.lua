local bc, get = require('class')('Button@Loop')
local reply_interaction = require('internal').reply_interaction

function get:name()
  return 'loop'
end

function bc:run(client, button, language, player, nplaying, collector)
  if not player and collector then collector:stop() end

  local function setLoop247(loop)
    local curr_data = client.db.autoreconnect:get(player.guildId)
    if curr_data then
      curr_data.config.loop = loop
      client.db.autoreconnect:set(player.guildId, curr_data)
    end
  end

  local function getOppositeMode()
    if player.loop == 'none' then
      return 'song', 'loop_current'
    elseif player.loop == 'song' then
      return 'queue', 'loop_current'
    elseif player.loop == 'queue' then
      return 'none', 'unloop_all'
    end
  end

  local mode, res_str = getOppositeMode()

  player:setLoop(mode)
  if client.config.utilities.AUTO_RESUME then setLoop247(mode) end

  return reply_interaction(client, button, client.i18n:get(language, 'button.music', res_str))
end

return bc