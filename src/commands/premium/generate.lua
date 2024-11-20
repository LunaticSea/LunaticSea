local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType
local command = require('class'):create()

function command:init()
	self.name = { 'pm', 'generate' }
	self.description = 'Generate a premium code!'
	self.category = 'premium'
	self.accessableby = { accessableby.admin }
	self.usage = '<type> <number>'
	self.aliases = { 'pmg' }
	self.lavalink = false
	self.playerCheck = false
	self.usingInteraction = true
	self.sameVoiceCheck = false
	self.permissions = {}
	self.options = {
		{
      name = 'plan',
      description = 'Avalible: daily, weekly, monthly, yearly',
      required = true,
      type = applicationCommandOptionType.string,
      choices = {
        {
          name = 'Daily',
          value = 'daily',
        },
        {
          name = 'Weekly',
          value = 'weekly',
        },
        {
          name = 'Monthly',
          value = 'monthly',
        },
        {
          name = 'Yearly',
          value = 'yearly',
        },
        {
          name = 'Lifetime',
          value = 'lifetime',
        },
      },
    },
    {
      name = 'amount',
      description = 'The amount of code you want to generate',
      type = applicationCommandOptionType.number,
      required = true,
    },
	}
end

function command:run(client, handler)
	handler:defer_reply()
	local plans = table.map(self.options[1].choices, function(data) return data.value end)
  local plan = handler.args[1]
  local amount = tonumber(handler.args[2])

  if not plan or not table.includes(plans, plan) then
    local embed = {
      description = client._i18n:get(handler.language, 'error', 'arg_error', {
        '**daily**, **weekly**, **monthly**, **yearly**, **lifetime**!'
      }),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  if not amount then
    local embed = {
      description = client._i18n:get(handler.language, 'error', 'arg_error', { '**Number**!' }),
      color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    }
    return handler:edit_reply({
      embeds = { embed },
    })
  end

  local codes = {}
  local time = 0

  local day = 86400
  if plan == 'daily' then time = os.time() + day end
  if plan == 'weekly' then time = os.time() + (day * 7) end
  if plan == 'monthly' then time = os.time() + (day * 30) end
  if plan == 'yearly' then time = os.time() + (day * 365) end
  if plan == 'lifetime' then time = 15052008 end

  for i = 1, amount, 1 do
    local code_premium = self:code_gen(32, i + time)
    local find = client._db.code:get(code_premium)
    if not find then
      client._db.code:set(code_premium, {
        code = code_premium,
        plan = plan,
        expiresAt = time
      })
    end
    table.insert(codes, string.format('%s - %s', i, code_premium))
  end

  local formated_time = string.format('<t:%s:F>', time)
  if time == 15052008 then formated_time = 'lifetime' end

	local embed = {
    author = {
      name = client._i18n:get(handler.language, 'command.premium', 'gen_author')
    },
		description = client._i18n:get(handler.language, 'command.premium', 'gen_desc', {
      #codes, table.concat(codes, '\n'), plan, formated_time
    }),
		color = discordia.Color.fromHex(client._config.bot.EMBED_COLOR).value,
    timestamp = discordia.Date():toISO('T', 'Z'),
    footer = {
      text = client._i18n:get(handler.language, 'command.premium', 'gen_footer', { '/' }),
      iconURL = client.user:getAvatarURL()
    }
	}
	handler:edit_reply({
		embeds = { embed },
	})
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
