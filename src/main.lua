local discordia = require('discordia')
local Dotenv = require('Dotenv')
Dotenv.load_env()

local client = discordia.Client({
	logFile = ".//",
	logLevel = 0
})

Dotenv.load_env()

require('./loader/main.lua')(client)

client:run("Bot " .. Dotenv.get_value("TOKEN"))