local fsex = require('./utils/fsex.lua')
local include = { '[^\\]+.lua' }
local exclude = { 'deps', 'build.lua', 'dev.lua', 'test.what.lua' }

local bundlefs = {}

function bundlefs.pattern_series_check(value, patterns, higher_mode)
  local length = 0
  local passed = 0

  for _, pattern in pairs(patterns) do
    local check = string.match(value, pattern)
    if check then passed = passed + 1 end
    length = length + 1
  end

  if (higher_mode and passed > 0) then return true
  else return length == passed end
end

function bundlefs.traditional_read()
  local res = {}
  local all_dir = fsex.readdir_recursive({ module.dir, '..' })

  table.foreach(all_dir, function (_, value)
    local check_if_pass_include = bundlefs.pattern_series_check(value, include)
    local check_if_pass_exclude = bundlefs.pattern_series_check(value, exclude, true)
    local is_pass = (check_if_pass_include == true) and (check_if_pass_exclude == false)
    if (is_pass) then table.insert(res, value) end
  end)

  return res
end

function bundlefs.get_all(if_build)
  local is_call_pcall = pcall(function () require('./tree.lua') end)
  if (if_build) then return bundlefs.traditional_read() end
  if (not is_call_pcall) then error('tree.lua not found! Please contact owner to rebuild the bot') end
  return require('./tree.lua')
end

function bundlefs.filter(req_data, pattern)
  local res = {}
  for _, value in pairs(req_data) do
    local is_match = string.match(value, pattern)
    if is_match then table.insert(res, value) end
  end
  return res
end

return bundlefs