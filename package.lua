  return {
    name = "LunaticSea",
    version = "0.0.1-unreleased",
    description = "ByteBlaze in lua version. Include sstaandalone packages",
    tags = { "lavalink", "discordbot", "discord" },
    license = "AGPL-3.0",
    author = { name = "RainyXeon", email = "xeondev@xeondex.onmicrosoft.com" },
    homepage = "https://github.com/RainyXeon/LunaticSea",
    dependencies = {
      "creationix/weblit@3.1.2",
      "creationix/coro-http@v3.2.3",
      "luvit/require@2.2.3",
      "luvit/process@2.1.3",
      "luvit/dns@2.0.4",
      "luvit/secure-socket@v1.2.3",
      "SinisterRectus/discordia@v2.12.0",
      "4keef/Dotenv@v0.0.6"
    },
    files = {
      "**.lua",
      "!test*"
    }
  }
  