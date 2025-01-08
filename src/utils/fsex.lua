local fs = require('fs')
local path = require('path')
local fsex = require('class')('FSex')

function fsex:__init()
end

function fsex:readdir_recursive(dir)
	local results = {}
	local dir_list = path.join(table.unpack(dir))
	local files = fsex:load_dir(dir_list)

	table.foreach(files, function(_, name)
		local small_dir = path.join(dir_list, name)
		local dir_locate_status, err = fs.lstatSync(small_dir)
		if err then
			error(err)
		end
		if dir_locate_status.type ~= 'directory' then
			table.insert(results, small_dir)
		else
			local another_time = self:readdir_recursive({ dir_list, name })
			table.foreach(another_time, function(_, value)
				table.insert(results, value)
			end)
		end
	end)

	return results
end

function fsex:load_dir(dir)
	local files, err = fs.readdirSync(dir)
	if err then
		error(err)
	end
	return files
end

return fsex
