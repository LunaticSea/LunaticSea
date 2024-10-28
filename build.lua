local fs = require('fs')
local path = require('path')
local base_project_name = require('./package.lua').name
-- Constants
local bundlefs = require('./src/bundlefs.lua')
local req_fle_tree = './src/tree.lua'
local warnings = [[
-- THIS IS PROJECT TREE FILE
-- Do NOT delete this file or it will crash
-- Changes to this file may cause incorrect behavior
-- You will be responsible for this when changing any content in the file.
]]

-- Functions
local function table_print(tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, key .. " = {\n");
        table.insert(sb, table_print(value, indent + 2, done))
        table.insert(sb, string.rep("  ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("  \"%s\",\n", tostring(value)))
      else
        table.insert(sb, string.format(
        "%s = \"%s\",\n", tostring (key), tostring(value)))
      end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

local function convert_data(tbl)
  local pre = {}
  for k, v in pairs(tbl) do
    local final, _ = v:gsub(path.join(module.dir), "bundle:")
    pre[k] = final:gsub("\\", '/'):sub(1)
  end
  local res = table_print(pre)
  return 'return {\n' .. res .. '}'
end

local function get_os_pname()
  local BinaryFormat = package.cpath:match("%p[\\|/]?%p(%a+)")
  if BinaryFormat == "dll" then return base_project_name .. '.exe' end
  return base_project_name
end

local function is_github()
  if process.env["GITHUB_BUILD"] then return true, './lit make' end
  return false, 'lit make'
end

-- Main
local is_github_action, curr_cmd = is_github()

if (is_github_action) then print('INFO - Current mode: Github action')
else print('INFO - Current mode: Normal') end

print('INFO - Checking if ' .. req_fle_tree .. ' exist')
local is_exist = fs.existsSync(req_fle_tree)
if is_exist then
  print('INFO - ' .. req_fle_tree .. ' exist, delete...')
  fs.unlinkSync(req_fle_tree)
end


print('INFO - Reading dir tree...')
local dir_tree = bundlefs.get_all(true)

print('INFO - Finished reading dir tree, total: ' .. #dir_tree)
print('INFO - Converting tree...')

local final_data = warnings .. '\n' .. convert_data(dir_tree)

print('INFO - Convert complete, now writting changes to ' .. req_fle_tree)

fs.writeFileSync(req_fle_tree, final_data)

fs.writeFile(req_fle_tree, final_data, function (err)
  if (err) then error(err) end
  print('INFO - Writting complete!')
  print('INFO - Building project ...')

  local openPop = assert(io.popen(curr_cmd))
  local output = openPop:read('*all')
  openPop:close()
  print(output)

  print('INFO - Building complete!')
  print('INFO - Removing old builds...')
  fs.rmdirSync('./build')
  print('INFO - Apply new builds')
  local p_name = get_os_pname()
  fs.mkdirSync('./build')
  fs.renameSync('./' .. p_name, './build/' .. p_name)
  print('INFO - Finished 💫')
end)
