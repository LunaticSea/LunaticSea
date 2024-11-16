local logger = require('class'):create()

function logger:init(client)
  self.preLog = client._logger
end

function logger:pad_end(str, length)
  return str .. string.rep(' ', length - #str)
end

function logger:error(class, msg)
  self.preLog:log(1, class, msg)
end

function logger:warn(class, msg)
  self.preLog:log(2, class, msg)
end

function logger:info(class, msg)
  self.preLog:log(3, class, msg)
end

function logger:debug(class, msg)
  self.preLog:log(4, class, msg)
end

return logger