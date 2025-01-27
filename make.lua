local fs = require('fs')
local path = require('path')
local base_project_name = require('./package.lua').name
local binary_format = package.cpath:match('%p[\\|/]?%p(%a+)')
local bundlefs = require('./src/bundlefs.lua')
local package_file = require('./package.lua')
local json = require('json')

local make = {
	tree_file_dir = './src/tree.lua',
	manifest_file_dir = './manifest.json',
	warnings = [[
-- THIS IS PROJECT TREE FILE
-- Do NOT delete this file or it will crash
-- Changes to this file may cause incorrect behavior
-- You will be responsible for this when changing any content in the file.
]],
	version = 'v1.0.0',
	args = {
		build = {
			type = 1,
			desc = 'Build the bot and dir tree to standalone executable file',
		},
		dir = {
			type = 2,
			desc = 'Build the bot dir tree only',
		},
		manifest = {
			type = 3,
			desc = 'Build the bot manifest only',
		},
	},
	bundlefs = bundlefs()
}

function make.run()
	local cli_data = make.get_cli_data()
	make.l('INFO', 'LunaticSea make')
	make.l('INFO', 'Version: ' .. make.version)

	local base_command = process.env["DOT_ENABLE"] and './lit make' or 'lit make'
	if process.env["TIMEOUT_MODE"] then
		base_command = 'timeout 7s ' .. base_command
	end

	make.manifest_file()
	if cli_data.type == 3 then
		return make.l('INFO', 'Finished 💫')
	end
	make.tree_file(cli_data, base_command)
end

function make.tree_file(cli_data, curr_cmd)
	make.l('INFO', 'Checking if ' .. make.tree_file_dir .. ' exist')
	local is_exist = fs.existsSync(make.tree_file_dir)
	if is_exist then
		make.l('INFO', make.tree_file_dir .. ' exist, delete...')
		fs.unlinkSync(make.tree_file_dir)
	end

	make.l('INFO', 'Reading dir tree...')

	local dir_tree = make.bundlefs:get_all(true)

	make.l('INFO', 'Finished reading dir tree, total: ' .. #dir_tree)
	make.l('INFO', 'Converting tree...')

	local final_data = make.warnings .. '\n' .. make.convert_data(dir_tree)

	make.l('INFO', 'Convert complete, now writting changes to ' .. make.tree_file_dir)

	fs.writeFile(make.tree_file_dir, final_data, function(err)
		make.build_project(err, cli_data, curr_cmd)
	end)
end

function make.manifest_file()
	make.l('INFO', 'Checking if ' .. make.manifest_file_dir .. ' exist')
	local is_exist = fs.existsSync(make.manifest_file_dir)
	if is_exist then
		make.l('INFO', make.manifest_file_dir .. ' exist, delete...')
		fs.unlinkSync(make.manifest_file_dir)
	end

	make.l('INFO', 'Making manifest file...')

  -- Get git data
  local gitobj = {
    branch = "git rev-parse --abbrev-ref HEAD",
    commit = "git rev-parse HEAD",
    commitTime = "git show -s --format=%ct HEAD",
  }

  for key, command in pairs(gitobj) do
    local openPop = assert(io.popen(command))
    local output = openPop:read('*all')
    openPop:close()
    gitobj[key] = output:sub(1, -2)
  end

  -- Get luvit data
  local runtimeObj = {}
  local openLuvit = assert(io.popen(
		process.env["DOT_ENABLE"] and './luvit --version' or 'luvit --version'
	))
	local outputLuvit = openLuvit:read('*all')
	openLuvit:close()
  outputLuvit = make.split(outputLuvit, '%a+ %a+: v?%d+.%d+.%d+')
  for _, data in pairs(outputLuvit) do
    data = make.split(data, '%S+')
    runtimeObj[data[1]] = data[3]
  end

  -- Build object
  local obj = {
    name = package_file.name,
    codename = package_file.codename,
    author = package_file.author,
    homepage = package_file.homepage,
    license = package_file.license,
    version = package_file.version,
    runtime = runtimeObj,
    buildTime = os.time(),
    git = gitobj
  }

  make.l('INFO', 'Making manifest file complete')

	fs.writeFile(make.manifest_file_dir, json.encode(obj), function(err)
		p(err)
	end)
end

function make.build_project(err, cli_data, curr_cmd)
	if err then
		error(err)
	end
	make.l('INFO', 'Writting complete!')

	if cli_data.type == 2 then
		return make.l('INFO', 'Finished 💫')
	end

	make.l('INFO', 'Building project ...')

	local openPop = assert(io.popen(curr_cmd))
	local output = openPop:read('*all')
	openPop:close()

	print(output)

	make.l('INFO', 'Building complete!')
	make.l('INFO', 'Removing old builds...')
	fs.rmdirSync('./build')
	make.l('INFO', 'Apply new builds')
	local p_name = make.pname_output()
	fs.mkdirSync('./build')
	fs.renameSync('./' .. p_name, './build/' .. p_name)
	make.l('INFO', 'Finished 💫')
end

function make.doc()
	print('\n\nInvalid arg, choose only some mode below:\n')
	for name, data in pairs(make.args) do
		print(' - ' .. name .. ': ' .. data.desc)
	end
	print('')
	print('')
	os.exit()
end

function make.get_cli_data()
	local get_mode = process.argv[2]
	if not get_mode then
		get_mode = 'build'
	end
	local arg_mode = make.args[get_mode]
	if not arg_mode then
		return make.doc()
	end
	return arg_mode, get_mode
end

function make.l(type, msg)
	print(type .. ' - ' .. msg)
end

function make.value_extractor(tt, indent, done)
	done = done or {}
	indent = indent or 0
	if type(tt) == 'table' then
		local sb = {}
		for key, value in pairs(tt) do
			table.insert(sb, string.rep(' ', indent)) -- indent it
			if type(value) == 'table' and not done[value] then
				done[value] = true
				table.insert(sb, key .. ' = {\n')
				table.insert(sb, make.value_extractor(value, indent + 2, done))
				table.insert(sb, string.rep('  ', indent)) -- indent it
				table.insert(sb, '}\n')
			elseif 'number' == type(key) then
				table.insert(sb, string.format('  "%s",\n', tostring(value)))
			else
				table.insert(sb, string.format('%s = "%s",\n', tostring(key), tostring(value)))
			end
		end
		return table.concat(sb)
	else
		return tt .. '\n'
	end
end

function make.convert_data(tbl)
	local pre = {}
	for k, v in pairs(tbl) do
		local final, _ = v:gsub(path.join(module.dir), 'bundle:')
		pre[k] = final:gsub('\\', '/'):sub(1)
	end
	local res = make.value_extractor(pre)
	return 'return {\n' .. res .. '}'
end

function make.pname_output()
	if binary_format == 'dll' then
		return base_project_name .. '.exe'
	end
	return base_project_name
end

function make.split(string, pattern)
	local t = {}
	for i in string.gmatch(string, pattern) do
		t[#t + 1] = i
	end
	return t
end

make.run()