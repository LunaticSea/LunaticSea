local deploy_service = require('class')('deploy_service')
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType

function deploy_service:__init(client)
	self._client = client
end

function deploy_service:register()
	self._client.logd:info('DeployService', 'Finding interaction commands...')

	local store = table.filter(self._client._commands, function(command)
		if command.config.using_interaction then
			return true
		end
	end)

	if #store == 0 then
		return self._client.logd:info('DeployService', 'No interactions found. Exiting auto deploy...')
	end

	self._client.logd:info(
		'DeployService',
		'Finding interaction commands completed, converting ' .. #store .. ' commands...'
	)
	local commands = self:parseEngine(store)

	self._client.logd:info(
		'DeployService',
		'Convert commands to body completed, now register all commands to discord'
	)
	self._client._api:registerApplicationCommands(self._client.user.id, commands)

	self._client.logd:info('DeployService', 'Interactions deployed! Exiting auto deploy...')
end

function deploy_service:parseEngine(store)
	return table.reduce(
		store,
		function(all, current)
			return self:commandReducer(all, current)
		end,
		{}
	)
end

function deploy_service:commandReducer(all, current)
	-- Push single name command
	if #current.name == 1 then
		table.insert(all, self:singleCommandMaker(current))
	end

	-- Push double name command
	if #current.name == 2 then
		local baseItem = table.filter(all, function(i)
			return i.name == current.name[1] and i.type == current.type
		end)
		if not baseItem or #baseItem == 0 then
			table.insert(all, self:doubleCommandMaker(current))
		else
			table.insert(baseItem[1].options, self:singleItemMaker(current, 2))
		end
	end

	-- Push trible name command

	if #current.name == 3 then
		local GroupItem = nil
		local SubItem = table.filter(all, function(i)
			return i.name == current.name[1] and i.type == current.type
		end)

		if SubItem and #SubItem > 0 then
			GroupItem = table.filter(SubItem[1].options, function(i)
				return i.name == current.name[2] and i.type == applicationCommandOptionType.subcommandGroup
			end)
		end

		if not SubItem or #SubItem == 0 then
			table.insert(all, self:tribleCommandMaker(current))
		elseif (SubItem and #SubItem > 0) and not GroupItem then
			table.insert(SubItem[1].options, self:doubleSubCommandMaker(current))
		elseif (SubItem and #SubItem > 0) and (GroupItem and #GroupItem > 0) then
			table.insert(GroupItem[1].options, self:singleItemMaker(current, 3))
		end
	end

	return all
end

function deploy_service:singleCommandMaker(current)
	return {
		type = current.type,
		name = current.name[1],
		description = current.description,
		defaultPermission = current.defaultPermission or nil,
		options = current.options,
	}
end

function deploy_service:doubleCommandMaker(current)
	return {
		type = current.type,
		name = current.name[1],
		description = current.name[1] .. ' commands.',
		defaultPermission = current.defaultPermission or nil,
		options = { self:singleItemMaker(current, 2) },
	}
end

function deploy_service:singleItemMaker(current, nameIndex)
	return {
		type = applicationCommandOptionType.subcommand,
		description = current.description,
		name = current.name[nameIndex],
		options = current.options,
	}
end

function deploy_service:tribleCommandMaker(current)
	return {
		type = current.type,
		name = current.name[1],
		description = current.name[1] .. ' commands.',
		defaultPermission = current.defaultPermission or nil,
		options = { self:doubleSubCommandMaker(current) },
	}
end

function deploy_service:doubleSubCommandMaker(current)
	return {
		type = applicationCommandOptionType.subcommandGroup,
		description = current.name[2] .. ' commands.',
		name = current.name[2],
		options = { self:singleItemMaker(current, 3) },
	}
end

return deploy_service
