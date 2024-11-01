local logger = {
  preLog = nil,
  typePad = 28
}

function logger:new(client)
  self = logger
  self.preLog = client._logger
  return self
end

function logger:log(level, class, msg)
  local class_padded = logger:pad_end(class, self.typePad)
  local final_result = string.format('%s| %s', class_padded, msg)
  self.preLog:log(level, final_result)
end

function logger:pad_end(str, length)
  return str .. string.rep(' ', length - #str)
end

function logger:error(class, msg)
  logger:log(1, class, msg)
end

function logger:warn(class, msg)
  logger:log(2, class, msg)
end

function logger:info(class, msg)
  logger:log(3, class, msg)
end

function logger:debug(class, msg)
  logger:log(4, class, msg)
end

return logger