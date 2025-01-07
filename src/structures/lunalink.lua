local class = require('class')
local lunalink = require('lunalink')

local Lunalink, get = class('Lunalink')

function Lunalink:__init(client)
  self._client = client
end

function get:wrapper()
  return lunalink.Core({
    nodes = self._client.config.player.NODES,
    library = lunalink.library.Discordia(self._client),
    config = self._client.config.utilities.AUTOFIX_LAVALINK.enable
      and self:merge(self.defaultConfig, self.autofixConfig)
      or self:merge(self.defaultConfig, self.nonAutoConfig)
  })
end

function get:defaultConfig()
  return {
    resume = true,
    resumeTimeout = 600,
    defaultSearchEngine = 'youtube',
    searchFallback = {
      enable = true,
      engine = 'youtube',
    },
  }
end

function get:nonAutoConfig()
  return {
    retryCount = math.huge,
    retryTimeout = 3000,
  }
end

function get:autofixConfig()
  return {
    retryCount = self._client.config.utilities.AUTOFIX_LAVALINK.retryCount,
    retryTimeout = self._client.config.utilities.AUTOFIX_LAVALINK.retryTimeout,
  }
end

function Lunalink:merge(maincfg, additionalcfg)
  for key, value in pairs(additionalcfg) do
    maincfg[key] = value
  end
  return maincfg
end

return Lunalink