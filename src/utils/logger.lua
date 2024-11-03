local logger = {
  preLog = nil,
}

function logger:new(client)
  self = logger
  self.preLog = client._logger
  return self
end

function logger:log(level, class, msg)
  local final_result = string.format('[ %s ] %s', class, msg)
  self.preLog:log(level, final_result)
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