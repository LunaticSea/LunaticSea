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
    config = {
      resume = true,
      resumeTimeout = 600,
      defaultSearchEngine = 'youtube',
      searchFallback = {
        enable = true,
        engine = 'youtube',
      },
      retryCount = math.huge,
      retryTimeout = 3000,
    }
  })
end

function Lunalink:merge(maincfg, additionalcfg)
  for key, value in pairs(additionalcfg) do
    maincfg[key] = value
  end
  return maincfg
end

return Lunalink