return require('./wrapper.lua')(function (...)
  require("./src/init.lua")
end, ...)