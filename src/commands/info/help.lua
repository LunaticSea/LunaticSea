local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')

table.filter = function(t, filterIter)
  local out = {}
  for k, v in pairs(t) do
    if filterIter(v, k, t) then table.insert(out,v) end
  end
  return out
end

local function field_array(client, handler)
  local field_embed = {}
  for category, _ in pairs(client._command_categories) do
    local same_category_command = table.filter(client._commands, function (data)
      return data.info.category == category
    end)

    local all_command_name = {}
    for _, command_data in pairs(same_category_command) do
      local command_name = table.concat(command_data.info.name, '-')
      table.insert(all_command_name, command_name)
    end

    local obj = {
      name =  '❯  ' .. string.upper(category) .. '[' .. #same_category_command .. ']',
      value = '`' .. table.concat(all_command_name, ', ') .. '`',
      inline = false
    }

    table.insert(field_embed, obj)
  end
  return field_embed
end

return {
  info = {
    name =  {'help'},
    description = 'Displays all commands that the bot has.',
    category = 'info',
    accessableby = {accessableby.member},
    usage = '',
    aliases = {'h'},
  },
  config = {
    lavalink = false,
    playerCheck = false,
    usingInteraction = true,
    sameVoiceCheck = false,
    permissions = {},
    options = {},
  },
  execute = function (client, handler)
    handler:defer_reply()

    if #handler.args == 0 then
      local embed = {
        author = {
          name = client._i18n:get(handler.language, 'command.info', 'ce_name')
        },
        color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
        thumbnail = {
          url = client.user:getAvatarURL() or client.user:defaultAvatarURL()
        },
        fields = field_array(client, handler),
        footer = {
          text = client._i18n:get(handler.language, 'command.info', 'ce_total') .. tostring(client._total_commands),
          url = client.user:getDefaultAvatarURL()
        }
      }

      handler:edit_reply({ embeds = {embed} })
    end
  end
}