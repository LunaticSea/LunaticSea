local page = require('class'):create()

local default = {
  client = nil,
  pages = nil
  timeout = 120000
  language = nil
}

function page:init(options)
  options = options or default
  self.client = assert(options.client, 'Client not found')
  self.pages = assert(options.pages, 'Pages not found')
  self.language = assert(options.language, 'Language not found')
  self.timeout = options.timeout
end

function page:slash(interaction)
  
end

function page:message(message)
  
end

return page
