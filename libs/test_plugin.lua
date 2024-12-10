local client_plugin = require('plugins-api').client
local class = require('plugins-api').class

local test_plugin, get = class('test_plugin', client_plugin)

function test_plugin:init(original_client)
  client_plugin.init(self, original_client)
end

function test_plugin:load()
  return 'test_plugin'
end

function get:plugin_name()
  return 'test_plugin'
end

function get:target_bot_version()
  return '1.0.0'
end

function get:minimum_bot_version()
  return '1.0.0'
end

return test_plugin