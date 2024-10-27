local discordia = require('discordia')
local Dotenv = require('Dotenv')
local dir = require('./dir.lua')
Dotenv.load_env()

local client = discordia.Client({
	logFile = ".//",
	logLevel = 0
})

local TEST_MODE = Dotenv.get_value("TEST_MODE") == 'true'
client._ptree = dir.get_all(TEST_MODE)

require('./loader/main.lua')(client)

client:run("Bot " .. Dotenv.get_value("TOKEN"))