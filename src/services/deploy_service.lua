local deploy_service = require('class'):create()
local discordia = require('discordia')
local applicationCommandOptionType = discordia.enums.applicationCommandOptionType

function deploy_service:init(client)
	self.client = client
end

function deploy_service:register()
	self.client._logd:info('DeployService', 'Finding interaction commands...')

	local store = table.filter(self.client._commands, function(command)
		if command.usingInteraction then
			return true
		end
	end)

	if #store == 0 then
		return self.client._logd:info('DeployService', 'No interactions found. Exiting auto deploy...')
	end

	self.client._logd:info('DeployService', 'Reading interaction commands completed, converting...')
	local commands = self:parseEngine(store)

	self.client._logd:info(
		'DeployService',
		'Convert to body completed, now register all commands to discord'
	)
	self.client._api:registerApplicationCommands(self.client.user.id, commands)

	self.client._logd:info('DeployService', 'Interactions deployed! Exiting auto deploy...')
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
			table.insert(baseItem.options, self:singleItemMaker(current, 2))
		end
	end

	-- Push trible name command

	if #current.name == 3 then
		local GroupItem = nil
		local SubItem = table.filter(all, function(i)
			return i.name == current.name[1] and i.type == current.type
		end)

		if SubItem and #SubItem > 0 then
			GroupItem = table.filter(SubItem.options, function(i)
				return i.name == current.name[1] and i.type == applicationCommandOptionType.subcommandGroup
			end)
		end

		if not SubItem or #SubItem == 0 then
			table.insert(all, self:tribleCommandMaker(current))
		elseif (SubItem and #SubItem > 0) and not GroupItem then
			table.insert(SubItem.options, self:doubleSubCommandMaker(current))
		elseif (SubItem and #SubItem > 0) and (GroupItem and #GroupItem > 0) then
			table.insert(GroupItem.options, self:singleItemMaker(current, 3))
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
