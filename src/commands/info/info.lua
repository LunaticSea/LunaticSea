local accessableby = require('../../constants/accessableby.lua')
local discordia = require('discordia')
local lunalink = require('lunalink')
local command, get = require('class')('Info:Info')
local ms = require('ms')

function get:name()
	return { 'info' }
end

function get:description()
	return 'Shows the developer information of the Bot'
end

function get:category()
	return 'info'
end

function get:accessableby()
	return { accessableby.member }
end

function get:usage()
	return ''
end

function get:aliases()
	return {}
end

function get:config()
	return {
		lavalink = false,
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

function command:get_bot_info(client)
	local desc_template = [[
		```
- Codename: %s
- Version: %s
- Homepage: %s
- Build time: %s
- License: %s
- Guilds count: %s
- Users count: %s```]]

	return string.format(desc_template,
		client._manifest.codename,
		client._manifest.version,
		client._manifest.homepage,
		os.date("%Y-%m-%d %H:%M:%S", tonumber(client._manifest.buildTime)),
		client._manifest.license,
		#client.guilds, #client.users
	)
end

function command:get_git_info(client)
	local desc_template = [[
		```
- Branch: %s
- Commit: %s
- Commit Time: %s```]]

	return string.format(desc_template,
		client._manifest.git.branch,
		client._manifest.git.commit,
    ms(tonumber(client._manifest.git.commitTime))
	)
end

function command:get_runtime_lib_info(client)
	local desc_template = [[
		```
- Discordia: %s
- Lunalink: %s
- Luvi: %s
- Luvit: %s```]]

	return string.format(desc_template,
		client._manifest.runtime.luvi,
		client._manifest.runtime.luvit,
		discordia.package.version,
		lunalink.manifest.version
	)
end

function command:run(client, handler)
	handler:defer_reply()

	local embed_data = {
    title = client.user.username,
		fields = {
			{
				name = 'Bot info',
				value = self:get_bot_info(client)
			},
      {
				name = 'Git info',
				value = self:get_git_info(client)
			},
      {
				name = 'Runtime / Library info',
				value = self:get_runtime_lib_info(client)
			},
		},
		color = discordia.Color.fromHex(client.config.bot.EMBED_COLOR).value,
		timestamp = discordia.Date():toISO('T', 'Z'),
	}

	handler:edit_reply({
		embeds = { embed_data },
	})
end

return command