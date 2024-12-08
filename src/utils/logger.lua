local logger = require('class')('logger')

function logger:init(client)
	self._preLog = client._logger
end

function logger:pad_end(str, length)
	return str .. string.rep(' ', length - #str)
end

function logger:error(class, msg)
	self._preLog:log(1, class, msg)
end

function logger:warn(class, msg)
	self._preLog:log(2, class, msg)
end

function logger:info(class, msg)
	self._preLog:log(3, class, msg)
end

function logger:debug(class, msg)
	self._preLog:log(4, class, msg)
end

return logger
